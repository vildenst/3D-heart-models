classdef VectorPatchType < VectorImageType
    
    properties(GetAccess = 'public', SetAccess = 'public')
        border =0;
        borderIndex1 = []; % The index of the first control node of the patch accounting for the border
        borderIndex2 = []; % The index of the last control node of the patch accounting for the border
        size_parent = [];
    end
    
    methods(Access = public)
        %constructor
        function obj = VectorPatchType(size,origin,spacing,orientation)
            if (nargin==1)
                % argument "size" is another images
                obj = VectorPatchType(size.size,size.origin,size.spacing,size.orientation);
            elseif(nargin > 0)
                obj.size = size(:);
                obj.spacing =  spacing(:);
                obj.origin = origin(:);
                obj.orientation = orientation;
                s = obj.size;
                obj.data = zeros(s(:)');
                obj.datax = zeros(s(:)');
                obj.datay = zeros(s(:)');
                obj.dataz = zeros(s(:)');
                obj.paddingValue = s*0;
                obj.D = orientation;
                for i=1:numel(obj.size)
                    obj.D(:,i)=obj.D(:,i)*obj.spacing(i);
                end
                
                % patch specific stuff
                obj.border =0;
                obj.borderIndex1 = size(:)*0+1; % The index of the first control node of the patch accounting for the border
                obj.borderIndex2 = size(:); % The index of the last control node of the patch accounting for the border
                obj.index = size(:)*0+1; % The index where this patch starts
                
                if isa(size,'PatchType') ||  isa(size,'VectorPatchType')
                    obj.size_parent = obj.size_parent;
                elseif isa(size,'ImageType')
                    obj.size_parent = obj.size;
                end
            end
            obj.ndimensions = numel(obj.origin);
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
            
            
            patch = VectorPatchType(s,obj.origin,obj.spacing,obj.orientation);
            patch.data = zeros((s+preborder+postborder)');
            patch.datax = zeros((s+preborder+postborder)');
            patch.datay = zeros((s+preborder+postborder)');
            patch.dataz = zeros((s+preborder+postborder)');
            
            patch.borderIndex1=index-preborder;
            patch.borderIndex2=index+(s-1)+postborder;
            patch.index=index;
            patch.origin=obj.origin; % origin is always associated to the index [1 1 1], not (necessarily) to the first index of the patch
            ngridpoints =numel(patch.data); % m_ngridpoints DOES account for the border
            
            nd_indices = patch.oned_to_nd_index(1:ngridpoints);
            
            patch.Set(nd_indices,obj.Get(nd_indices,'data'),'data');
            patch.Set(nd_indices,obj.Get(nd_indices,'datax'),'datax');
            patch.Set(nd_indices,obj.Get(nd_indices,'datay'),'datay');
            patch.Set(nd_indices,obj.Get(nd_indices,'dataz'),'dataz');
            
        end
        
        function gr = GetFullGrid(obj)
            s = obj.borderIndex2-obj.borderIndex1+1;
            o = obj.GetPosition(ones(ndims(obj.data),1));
            gr = VectorPatchType(s,o,obj.spacing,obj.orientation);
            gr.index = obj.borderIndex1;
        end
        
        function gr = GetFullPatch(obj)
            s = obj.borderIndex2-obj.borderIndex1+1;
            o = obj.GetPosition(ones(ndims(obj.data),1));
            gr = VectorPatchType(s,o,obj.spacing,obj.orientation);
            gr.borderIndex1 = obj.borderIndex1;
            gr.borderIndex2 = obj.borderIndex2;
            gr.index = gr.borderIndex1;
        end
        
        
         function Set(obj, ndindex, data, fld)
            index1D = obj.nd_to_oned_index(ndindex);
            obj.(fld)(index1D) = data;
        end
        
        function data = Get(obj, nd_index, fld)
            index1D = obj.nd_to_oned_index(nd_index);
            data = obj.(fld)(index1D);
        end
        
        function onedindex = nd_to_oned_index(obj, nd_index_patch)
            tmp = PatchType(obj);
            onedindex = tmp.nd_to_oned_index(nd_index_patch);
        end
        
        function onedindex = nd_to_oned_index_noBorders(obj, nd_index_patch)
            tmp = PatchType(obj);
            onedindex = tmp.nd_to_oned_index_noBorders(nd_index_patch);
        end
        
        function b = GetBoundsFull(obj)
            tmp = PatchType(obj);
            b = tmp.GetBoundsFull();
        end
        
        function ndindex = oned_to_nd_index(obj, oned_index_patch)
            tmp = PatchType(obj);
            ndindex = tmp.oned_to_nd_index(oned_index_patch);
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
    
end