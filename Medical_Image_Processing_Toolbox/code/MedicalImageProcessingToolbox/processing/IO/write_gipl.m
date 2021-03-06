function write_gipl(fname,im,varargin)
% Function for writing Guys Image Processing Lab (Gipl) files.
%
% gipl_write_volume(volume, filename, voxelsize in mm)
%
% im must be of ImageType class
%

forceuint= false;
 for i=1:size(varargin,2)    
    if (strcmp(varargin{i},'ushort'))
        forceuint= true;
    end
    
 end

if forceuint
    disp('Converting image to uint16');
    im.data = uint16(im.data);
end

image_types=struct('double',65,'float',65,'single',64,'logical',1,'int8',7,'uint8',8,'int16',15,'uint16',16,'int32',32,'uint32',31);
bit_lengths=struct('double',64,'float',64,'single',32,'logical',1,'int8',8,'uint8',8,'int16',16,'uint16',16,'int32',32,'uint32',32);


% Sizes
sizes=im.size';
while(length(sizes)<4), sizes=[sizes 1]; end
% Scales
scales = im.spacing';
while(length(scales)<4), scales=[scales 0]; end
% Offset
offset=256;
% Image Type
image_type=getfield(image_types,class(im.data));
% File size
fsize=offset+prod(sizes)*getfield(bit_lengths,class(im.data))/8;
% Patient
patient='Generated by Matlab';
while(length(patient)<80), patient=[patient ' ']; end
% Matrix
matrix=[1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 1];
% orientation
orientation=0;
% voxel_min
voxmin=min(im.data(:));
% voxel_max
voxmax=max(im.data(:));
% origing
origin=[im.origin' 0];
% pixval_offset
pixval_offset=0;
% pixval_cal
pixval_cal=0;
% interslicegap
interslicegap=0;
% user_def2
user_def2=0;
% par2
par2=0;
% magic_number
magic_number=4026526128;

trans_type{1}='binary'; trans_type{7}='char'; trans_type{8}='uchar'; trans_type{15}='short';
trans_type{16}='ushort'; trans_type{31}='uint'; trans_type{32}='int'; trans_type{64}='float';
trans_type{65}='double'; trans_type{144}='C_short'; trans_type{160}='C_int'; trans_type{192}='C_float';
trans_type{193}='C_double'; trans_type{200}='surface'; trans_type{201}='polygon';

trans_orien{0+1}='UNDEFINED'; trans_orien{1+1}='UNDEFINED_PROJECTION'; trans_orien{2+1}='AP_PROJECTION';
trans_orien{3+1}='LATERAL_PROJECTION'; trans_orien{4+1}='OBLIQUE_PROJECTION';  trans_orien{8+1}='UNDEFINED_TOMO';
trans_orien{9+1}='AXIAL'; trans_orien{10+1}='CORONAL'; trans_orien{11+1}='SAGITTAL'; trans_orien{12+1}='OBLIQUE_TOMO';

verbose=false;
if (verbose)
    disp(['filename : ' num2str(fname)]);
    disp(['filesize : ' num2str(fsize)]);
    disp(['sizes : ' num2str(sizes)]);
    disp(['scales : ' num2str(scales)]);
    disp(['image_type : ' num2str(image_type) ' - ' trans_type{image_type}]);
    disp(['patient : ' patient]);
    disp(['matrix : ' num2str(matrix)]);
    disp(['orientation : ' num2str(orientation) ' - ' trans_orien{orientation+1}]);
    disp(['voxel min : ' num2str(voxmin)]);
    disp(['voxel max : ' num2str(voxmax)]);
    disp(['origing : ' num2str(origin)]);
    disp(['pixval_offset : ' num2str(pixval_offset)]);
    disp(['pixval_cal : ' num2str(pixval_cal)]);
    disp(['interslicegap : ' num2str(interslicegap)]);
    disp(['user_def2 : ' num2str(user_def2)]);
    disp(['par2 : ' num2str(par2)]);
    disp(['offset : ' num2str(offset)]);
end


% write *.raw file
%mytype=class(image.data);
%fid=fopen(rawfile,'w','native');
%if (ElementNumberOfChannels ==1)
%    fwrite(fid,image.data,mytype);

%fout=fopen(fname,'w','native');
fout=fopen(fname,'wb','ieee-be');
fwrite(fout,uint16(sizes),'ushort'); % 4
fwrite(fout,uint16(image_type),'ushort'); % 1
fwrite(fout,single(scales),'float'); % 4
fwrite(fout,patient,'char'); % 80
fwrite(fout,single(matrix),'float'); % 20
fwrite(fout,uint8(orientation),'uint8'); % 1
fwrite(fout,uint8(par2),'uint8'); % 1
fwrite(fout,double(voxmin),'double'); % 1
fwrite(fout,double(voxmax),'double'); % 1
fwrite(fout,double(origin),'double'); % 4
fwrite(fout,single(pixval_offset),'float'); % 1
fwrite(fout,single(pixval_cal),'float'); % 1
fwrite(fout,single(interslicegap),'float'); % 1
fwrite(fout,single(user_def2),'float'); % 1
fwrite(fout,uint32(magic_number),'uint'); % 1
%fwrite(fout,im.data, trans_type{image_type});
fwrite(fout,im.data, class(im.data));
fclose('all');



