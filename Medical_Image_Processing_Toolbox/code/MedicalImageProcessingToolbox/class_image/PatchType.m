classdef PatchType < ImageType
    
    properties(GetAccess = 'public', SetAccess = 'public')
        border =0;
        borderIndex1 = []; % The index of the first control node of the patch accounting for the border
        borderIndex2 = []; % The index of the last control node of the patch accounting for the border
        size_parent = [];
    end
    
    methods(Access = public)
        %constructor
        function obj = PatchType(size,origin,spacing,orientation)
            if (nargin==1)
                % argument "size" is another patch
                obj = PatchType(size.size,size.origin,size.spacing,size.orientation);
                if isa(size,'PatchType') || isa(size,'VectorPatchType')
                    obj.index = size.index;
                    obj.borderIndex1 = size.borderIndex1;
                    obj.borderIndex2 = size.borderIndex2;
                    obj.border= size.border;
                    obj.size_parent = size.size_parent;
                else
                    obj.size_parent = size.size;
                end
                
            elseif(nargin > 0)
                obj.size = size(:);
                obj.spacing =  spacing(:);
                obj.origin = origin(:);
                obj.orientation = orientation;
                s = obj.size;
                if numel(s)==1
                    obj.data = zeros(s,1);
                else
                    obj.data = zeros(s');
                end
                
                obj.paddingValue = 0;
                obj.D = orientation;
                for i=1:numel(obj.spacing)
                    obj.D(:,i)=obj.D(:,i)*obj.spacing(i);
                end
                
                % patch specific stuff
                obj.border =0;
                obj.borderIndex1 = spacing(:)*0+1; % The index of the first control node of the patch accounting for the border
                obj.borderIndex2 = size(1:numel(spacing)); % The index of the last control node of the patch accounting for the border
                obj.index = obj.borderIndex1; % The index where this patch starts
                obj.ndimensions = numel(obj.origin);
                if isa(size,'PatchType') ||  isa(size,'VectorPatchType')
                    obj.size_parent = obj.size_parent;
                elseif isa(size,'ImageType')
                    obj.size_parent = obj.size;
                end
            end
        end
        
        function im = force2D(obj)
            im = obj.force2D();
            im.borderIndex1 = im.borderIndex1(1:2);
            im.borderIndex2 = im.borderIndex2(1:2);
            im.index = im.index(1:2);
        end
        
        function patch = extractPatch(obj, index, s, border)
            
            preborder = ( index-border >= obj.borderIndex1)*border +  ( index-border < obj.borderIndex1).*(index-obj.borderIndex1);
            postborder = ( index+s-1+border <= obj.borderIndex2)*border + ( index+s-1+border > obj.borderIndex2).*(obj.borderIndex2 - (s-1) - index);
            
            
            
            if numel(obj.spacing)==1
                patch_data = zeros((s+preborder+postborder),1);
            else
                patch_data = zeros((s+preborder+postborder)');
            end
            
            patch = PatchType(size(patch_data)',obj.origin,obj.spacing,obj.orientation);
            patch.data = patch_data;
            
            patch.borderIndex1=index-preborder;
            patch.borderIndex2=index+(s-1)+postborder;
            patch.index=index;
            patch.origin=obj.origin; % origin is always associated to the index [1 1 1], not (necessarily) to the first index of the patch
            ngridpoints =numel(patch.data); % m_ngridpoints DOES account for the border
            
            nd_indices = patch.oned_to_nd_index(1:ngridpoints);
            patch.Set(nd_indices,obj.Get(nd_indices));
            
        end
        
          function Set(obj, ndindex, data)
            index1D = obj.nd_to_oned_index(ndindex);
            obj.data(index1D(index1D==index1D)) = data(index1D==index1D);
        end
        
        function data = Get(obj, nd_index)
            index1D = obj.nd_to_oned_index(nd_index);
            data = NaN(size(index1D));
            good_indices = ~isnan(index1D);
            data(~isnan(index1D)) = obj.data(index1D(~isnan(index1D)));
        end
        
%         % In this function, nd_index_patch must be, each index, in a column
%         function onedindex = nd_to_oned_index(obj, nd_index_patch)
%             
%             index_local = nd_index_patch - obj.borderIndex1*ones(1,size(nd_index_patch,2))+1;
%             total_size = (obj.borderIndex2 - obj.borderIndex1+1)';
%             
%             [~,out1] = find(index_local<=0);
%             [~,out2]= find(repmat(obj.size,1,size(index_local,2))-index_local<0);
%             into_account = setdiff(1:size(index_local,2),unique([out1(:)'  out2(:)']));
%             
%             if obj.ndimensions==1
%                 tmp = index_local(1,into_account)';
%             else
%                 str = [];
%                 for ii=1:ndims(obj.data)
%                     str = [str 'index_local(' num2str(ii) ',into_account)'','];
%                 end
%                 %[~,out1] = find(index_local - obj.index*ones(1,size(index_local,2))<=0);
%                 eval(['tmp = sub2ind(total_size,' str(1:end-1) ');' ]);
%             end
%             
%             onedindex = NaN(size(index_local,2),1);
%             onedindex(into_account) = tmp;
%             
%         end
        
        function b = GetBoundsFull(obj)
            s = obj.borderIndex2-obj.borderIndex1+1;
            o = obj.GetPosition(ones(numel(obj.spacing),1));
            tmp = ImageType(s,o,obj.spacing,obj.orientation);
            tmp.index = ones(numel(obj.spacing),1); %obj.borderIndex1;
            b = tmp.GetBounds();
           
        end
        
        function gr = GetFullGrid(obj)
            s = obj.borderIndex2-obj.borderIndex1+1;
            o = obj.GetPosition(ones(numel(obj.spacing),1));
            gr = PatchType(s,o,obj.spacing,obj.orientation);
            gr.index = obj.borderIndex1;
            gr.borderIndex1 = obj.borderIndex1;
            gr.borderIndex2 = obj.borderIndex2;  
        end
        
        function gr = GetFullPatch(obj)
            s = obj.borderIndex2-obj.borderIndex1+1;
            o = obj.GetPosition(ones(numel(obj.spacing),1));
            gr = PatchType(s,o,obj.spacing,obj.orientation);
            gr.index = obj.borderIndex1;
            gr.borderIndex1 = obj.borderIndex1;
            gr.borderIndex2 = obj.borderIndex2;  
        end
        
        function ndindex = oned_to_nd_index(obj, oned_index_patch)
            
            total_size = (obj.borderIndex2 - obj.borderIndex1+1)';
            
            str = [];
            str2 =[];
            for ii=1:numel(obj.spacing)
                str = [str 'i' num2str(ii) ','];
                str2 = [str2 'i' num2str(ii) '(:) '];
            end
            eval(['['  str(1:end-1) '] = ind2sub(total_size,oned_index_patch); index = [' str2(1:end-1) ']'';' ]);
            ndindex = index + obj.borderIndex1*ones(1,size(index,2))-1;
        end
        
        function ndindex = oned_to_nd_index_noBorders(obj, oned_index_patch)
            
            total_size = obj.size';
            
            str = [];
            str2 =[];
            for ii=1:numel(obj.spacing)
                str = [str 'i' num2str(ii) ','];
                str2 = [str2 'i' num2str(ii) '(:) '];
            end
            eval(['['  str(1:end-1) '] = ind2sub(total_size,oned_index_patch); index = [' str2(1:end-1) ']'';' ]);
            ndindex = index+ obj.index*ones(1,size(index,2))-1;
        end
        
    end
    
    methods(Access = private)
        
    end
end