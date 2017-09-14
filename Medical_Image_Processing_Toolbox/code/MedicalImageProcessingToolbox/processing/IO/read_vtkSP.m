function [img, info]=read_vtkSP(filename)
% This function is based upon "read_mhd" function from the package
% ReadData3D_version1 from the matlab exchange.
% Copyright (c) 2010, Dirk-Jan Kroon
% [image info ] = read_mhd(filename)

info = vtkSPreadheader(filename);

img = VectorImageType(info.Dimensions',info.Offset',info.PixelDimensions',reshape(info.TransformMatrix,numel(info.PixelDimensions),numel(info.PixelDimensions)));
img.datax(:) = info.field1(:,1);
img.datay(:) = info.field1(:,2);
img.dataz(:) = info.field1(:,3);
img.data = img.datax.^2+img.datay.^2+img.dataz.^2;


 

end


function info =vtkSPreadheader(filename)
% Function for reading the header of a VTK legacy (.vtk) image file

info = [];
if(exist('filename','var')==0)
    [filename, pathname] = uigetfile('*.vtk', 'Read vtk-file');
    filename = [pathname filename];
end

fid=fopen(filename,'rb');
if(fid<0)
    fprintf('could not open file %s\n',filename);
    return
end

info.Filename=filename;
info.Format='VTK';
info.CompressedData='false';
info.TransformMatrix = [];
info.CenterOfRotation=[];
readelementdatafile=false;
while(~readelementdatafile)
    str=fgetl(fid);
    if str==-1 
        readelementdatafile =true;
        continue;
    end
    
    if  numel(str)==0
        readelementdatafile =true;
        continue;
    end
        
    s=find(str==' ',1,'first');
    if(~isempty(s))
        type=str(1:s-1); 
        if isempty(type)
            readelementdatafile =true;
            continue;
        end
        data=str(s+1:end);
        if isempty(data)
            readelementdatafile =true;
            continue;
        end
        while(type(end)==' '); type=type(1:end-1); end
        while(data(1)==' '); data=data(2:end); end
    else
        if strcmp(str(1),'#')
            if strcmp(str(2:6),'FORCE')
                type='force';
                data = str(7:end);
            elseif strcmp(str(2:9),'POSITION')
                type='position';
                data = str(10:end);
            elseif strcmp(str(2:10),'TIMESTAMP')
                type='timestamp';
                data = str(11:end);
            elseif strcmp(str(2:11),'PERCEIVEDF')
                type='perceivedf';
                data = str(12:end);
            else
                type='comment'; data=str;
            end
        else
            type=''; data=str;
        end
    end
    if ~numel(type)
        continue;
    end
    switch(lower(type))
        case 'ndims'
            info.NumberOfDimensions=sscanf(data, '%d')';
        case 'dimensions'
            info.Dimensions=sscanf(data, '%d')';
        case 'spacing'
            info.PixelDimensions=sscanf(data, '%lf')';
        case 'elementbyteordermsb'
            info.ByteOrder=lower(data);
        case 'point_data'
            info.npoints=sscanf(data, '%lf')';
        case 'field'
            info.fielddata=sscanf(data, '%s');
            info.nfielddata=str2num(info.fielddata(end));
            %for i=1:info.nfielddata
            for i=1
              str=fgetl(fid);
              s=find(str==' ',3,'first');
              if(~isempty(s))
                type=str(1:s(1)-1); 
                ncomponents=str2num(str(s(1)+1:s(2)-1));
                nvectors=str2num(str(s(2)+1:s(3)-1));
                vectortype=str(s(3)+1:end);
                info.DataType = vectortype;
              else
                  continue;
              end
              
              %data_read = fread(fid, [nvectors*ncomponents ],vectortype)';
              data_read = fscanf(fid, '%lf', [ncomponents nvectors  ]);
              info.(['field' num2str(i)]) = data_read';
            end
        case 'origin'
            info.Offset=sscanf(data, '%lf')';
        % Custom fields
        case 'force'
            info.Force=sscanf(data, '%lf')';
        case 'position'
            info.Position=sscanf(data, '%lf')';
        case 'timestamp'
            info.Timestamp=sscanf(data, '%lf')';
        case '#'
            info.comment = data;
        case 'perceivedf'
            info.perceivedf=data;
        otherwise
            info.(type)=data;
    end
end

if ~numel(info.TransformMatrix)
   info.TransformMatrix = reshape(eye(3), 1,3*3);
end

if ~numel(info.CenterOfRotation)
  info.CenterOfRotation = zeros(1,3);
end


switch(info.DataType)
    case 'char', info.BitDepth=8;
    case 'uchar', info.BitDepth=8;
    case 'short', info.BitDepth=16;
    case 'ushort', info.BitDepth=16;
    case 'int', info.BitDepth=32;
    case 'uint', info.BitDepth=32;
    case 'float', info.BitDepth=32;
    case 'double', info.BitDepth=64;
    otherwise, info.BitDepth=0;
end
if(~isfield(info,'HeaderSize'))
    info.HeaderSize=ftell(fid);
end
fclose(fid);
end