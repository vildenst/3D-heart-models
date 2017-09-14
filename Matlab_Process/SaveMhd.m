%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%%%                 SAVE .MHD FILE IN PROPER FORMAT                     %%%
%                                                                         %              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULA Research Laboratory
% For TOF and MI patients at ED only (bi-ventricle)
% Contact - kristin@simula.no, maciej.mar92@gmail.com
% July 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function SaveMhd(subjNo, filen)

global SEG % Comes from global workspace
localSEG = SEG{subjNo}; 

% For further processing purposes, values are changed to maximum 8-bit value
% Preparing binary array
% resVector = [localSEG.ResolutionX localSEG.ResolutionY 1];
pixSize = int16([localSEG.XSize, localSEG.YSize, localSEG.ZSize]);%.*resVector);
pix=zeros(pixSize);

%Finding slices with scar pixels
temp=round(localSEG.ScarMhd/[localSEG.ResolutionX 0 0; 0 localSEG.ResolutionY 0;...
    0 0 1]);
temp(:)=temp(:);
z=max(temp(:,3));

for i=1:localSEG.ZSize
    temp1=find(temp(:,3)==z);
    [c,~]=size(temp1);
    for j=1:c
        x=temp(temp1(j),1);
        y=temp(temp1(j),2);
        
          pix(x,y,i)=255;
        
    end
    z = z-localSEG.SliceThickness;
    
end

% Information for .mhd file.
pixImage(:,:,1,:) = uint8(pix);
orig = [0 0 -localSEG.EndoPoints.Frame{1}(1,3);]';
sp = [localSEG.ResolutionX localSEG.ResolutionY localSEG.SliceGap+...
    localSEG.SliceThickness]';
orient = eye(3);
image = ImageType(size(squeeze(pixImage))', orig, sp, orient);
image.data = squeeze(pixImage);

% Saving image
[~,name,~] = fileparts(filen);
fileName=['Data/ScarImages/MetaImages/' name '.mhd'];
write_mhd(fileName, image, 'elementtype', 'uint8');