%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PRE-PROCESS AND ALIGN ALL TO REFERENCE                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULA Research Laboratory
% For GOSH TOF patients at ED only (bi-ventricle)
% Contact - kristin@simula.no
% July 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
noSubjects = 3;  % Total number of subjects 
RVyes = 1;
IsFullTemporal = 0;
filename = cell(noSubjects,1);

% NOTE: Change the SEG indexing to make it usable wihtout f eval
% Possibly with cell array.

%% First give filenames for all subjects

% Excluding not existing subjects
% Check the possibility to load it from file
Subjects = 1:noSubjects;
notIncluded = [2]; % Indices of not segmented subjects
Subjects(notIncluded) = [];

% Find files
for i = Subjects
    filename{i} = strcat('Data/Seg/CPH_', num2str(i), '.mat');
end

% Load files
for i = Subjects
    eval(['tmp = load(filename{' num2str(i) '},''-mat'',''setstruct'');']);
    eval(['SEGold' int2str(i) ' = tmp.setstruct;']); 
end
clear tmp

%% Run sliceAlignment.m to remove slice mis-alignments

% NOTE: To be combined and exported to SEGx.ScarMhd. Resolution information
% will be added in pairwiseAlignment

% Alignment for scar
% for i = Subjects
%     eval(['SEG' int2str(i) '_shift = autoAlignScar(SEGold' int2str(i) ');']); 
% end

%Alignment for ventricles
for i = Subjects
    eval(['SEG' int2str(i) '_shift=sliceAlignmentwithBivEpi(SEGold' int2str(i) ',RVyes,IsFullTemporal);']);
end
 

 
%% Run cleanPointIndices.m to fix the point indexing

% Note!!! There is a problem with the biventricle indices... TO FIX or in
% the meantime, be careful when segmenting to start at (approx) the same point for
% each slice and do one full round first, then correct ^^
for i = Subjects
    eval(['SEG' int2str(i) '_shift_clean=cleanPointIndiceswithBivEpi(SEG' int2str(i) '_shift,RVyes,IsFullTemporal);']);
end

%% Run temporalResampling.m to resample all to have the same no. of frames
for i = Subjects
    %eval(['SEG' int2str(i) '_shift_resampled=temporalResample(SEG' int2str(i) '_shift,Nnew);']); % Without temporal alignment
    eval(['SEG' int2str(i) '_shift_resampled=notTemporalResampleAlignmentwithBivEpi(SEG' int2str(i) '_shift_clean,RVyes);']);
end

%% Run pairwiseAlignment.m to resample all to a common space

% NOTE: TODO: Scar positions should be aligned as well. 

% Assume subject 1 is the reference and iterate over all others
for i = Subjects(2:end)   
    eval(['SEG' int2str(i) '=pairwiseAlignmentwithBivEpi(SEG1_shift_resampled,SEG' int2str(i) '_shift_resampled,IsFullTemporal);']);
end

% Finally, change resolution for Subject1 for good
SEG1 = ChangeReswithBivEpi(SEG1_shift_resampled);

%% Create physical points for fixed reference
%Adjust for the resolution
% for i = 2:noSubjects
%     eval(['SEG' int2str(i) '=ChangeReswithBivEpi(SEG' int2str(i) '_shift_resampled);']);
% end



% %% Account for voxel size for SEG1
% % Account for voxel size
% SEG1_shift_resampled = SEG1_shift_clean;
% SEG1_shift_resampled.EndoXold   = SEG1_shift_resampled.EndoXnew;
% SEG1_shift_resampled.EndoYold   = SEG1_shift_resampled.EndoYnew;
% SEG1_shift_resampled.EpiXold    = SEG1_shift_resampled.EpiXnew;
% SEG1_shift_resampled.EpiYold    = SEG1_shift_resampled.EpiYnew;
% SEG1_shift_resampled.RVEndoXold = SEG1_shift_resampled.RVEndoXnew;
% SEG1_shift_resampled.RVEndoYold = SEG1_shift_resampled.RVEndoYnew;
% SEG1_shift_resampled.RVEpiXold = SEG1_shift_resampled.RVEpiXnew;
% SEG1_shift_resampled.RVEpiYold = SEG1_shift_resampled.RVEpiYnew;
% 
% % SEG1_shift_clean.EndoXnew   = SEG1_shift_clean.EndoXnew*SEG1_shift_clean.ResolutionX;
% % SEG1_shift_clean.EndoYnew   = SEG1_shift_clean.EndoYnew*SEG1_shift_clean.ResolutionY;
% % SEG1_shift_clean.EpiXnew    = SEG1_shift_clean.EpiXnew*SEG1_shift_clean.ResolutionX;
% % SEG1_shift_clean.EpiYnew    = SEG1_shift_clean.EpiYnew*SEG1_shift_clean.ResolutionY;
% % SEG1_shift_clean.RVEndoXnew = SEG1_shift_clean.RVEndoXnew*SEG1_shift_clean.ResolutionX;
% % SEG1_shift_clean.RVEndoYnew = SEG1_shift_clean.RVEndoYnew*SEG1_shift_clean.ResolutionY;
% 
% sizenEndo=size(SEG1_shift_resampled.EndoXnew);
% KEndo = sizenEndo(1, 1); %No. of points (default 80)
% NEndo = sizenEndo(1, 2); %No. of time frames
% SEndo = sizenEndo(1, 3); %No. of slices
% EndoZ = repmat((1-(1:SEG1_shift_resampled.ZSize))*(SEG1_shift_resampled.SliceThickness+SEG1_shift_resampled.SliceGap),...
%       [KEndo 1]);
%   
% % Create physical points for the fixed reference
% for n = 1
%     for s = 1:SEndo
%         for k = 1:KEndo
%             i = (s-1)*KEndo+k;
%             eval(['SEG1_shift_resampled.EndoPoints.Frame' int2str(n) '(i,1) = SEG1_shift_resampled.ResolutionX*SEG1_shift_resampled.EndoXnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.EndoPoints.Frame' int2str(n) '(i,2) = SEG1_shift_resampled.ResolutionY*SEG1_shift_resampled.EndoYnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.EndoPoints.Frame' int2str(n) '(i,3) = EndoZ(k,s);']); 
%         end
%     end
% end
% % for n = 1:NEndo
% %     for s = 1:SEndo
% %         for k = 1:KEndo
% %             i = (s-1)*KEndo+k;
% %             eval(['SEG1_shift_clean.EndoPoints.Frame' int2str(n) '(i,1) = SEG1_shift_clean.EndoXnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.EndoPoints.Frame' int2str(n) '(i,2) = SEG1_shift_clean.EndoYnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.EndoPoints.Frame' int2str(n) '(i,3) = SEG1_shift_clean.ResolutionX*EndoZ(k,s);']); 
% %         end
% %     end
% % end
% 
% sizenEpi=size(SEG1_shift_resampled.EpiXnew);
% KEpi = sizenEpi(1, 1); %No. of points (default 80)
% NEpi = sizenEpi(1, 2); %No. of time frames
% SEpi = sizenEpi(1, 3); %No. of slices
% EpiZ = repmat((1-(1:SEG1_shift_resampled.ZSize))*(SEG1_shift_resampled.SliceThickness+SEG1_shift_resampled.SliceGap),...
%       [KEpi 1]);
%   
% % Same for Epi
% for n = 1
%     for s = 1:SEpi
%         for k = 1:KEpi
%             i = (s-1)*KEpi+k;
%             eval(['SEG1_shift_resampled.EpiPoints.Frame' int2str(n) '(i,1) = SEG1_shift_resampled.ResolutionX*SEG1_shift_resampled.EpiXnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.EpiPoints.Frame' int2str(n) '(i,2) = SEG1_shift_resampled.ResolutionY*SEG1_shift_resampled.EpiYnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ(k,s);']); 
%         end
%     end
% end
% 
% % for n = 1:NEpi
% %     for s = 1:SEpi
% %         for k = 1:KEpi
% %             i = (s-1)*KEpi+k;
% %             eval(['SEG1_shift_clean.EpiPoints.Frame' int2str(n) '(i,1) = SEG1_shift_clean.EpiXnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.EpiPoints.Frame' int2str(n) '(i,2) = SEG1_shift_clean.EpiYnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ(k,s);']); 
% %         end
% %     end
% % end
% 
 sizenRV=size(SEG1_shift_resampled.RVEndoXnew);
 KRV = sizenRV(1, 1); %No. of points (default 80)
% NRV = sizenRV(1, 2); %No. of time frames
SRV = sizenRV(1, 3); %No. of slices
% RVEndoZ = repmat((1-(1:SEG1_shift_resampled.ZSize))*(SEG1_shift_resampled.SliceThickness+SEG1_shift_resampled.SliceGap),...
%       [KRV 1]);
% 
% for n = 1
%     for s = 1:SRV
%         for k = 1:KRV
%             i = (s-1)*KRV+k;
%             eval(['SEG1_shift_resampled.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG1_shift_resampled.ResolutionX*SEG1_shift_resampled.RVEndoXnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG1_shift_resampled.ResolutionY*SEG1_shift_resampled.RVEndoYnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ(k,s);']); 
%         end
%     end
% end
% 
% sizenRVEpi=size(SEG1_shift_resampled.RVEpiXnew);
% KRVEpi = sizenRVEpi(1, 1); %No. of points (default 80)
% NRVEpi = sizenRVEpi(1, 2); %No. of time frames
% SRVEpi = sizenRVEpi(1, 3); %No. of slices
% RVEpiZ = repmat((1-(1:SEG1_shift_resampled.ZSize))*(SEG1_shift_resampled.SliceThickness+SEG1_shift_resampled.SliceGap),...
%       [KRVEpi 1]);
% 
% for n = 1
%     for s = 1:SRVEpi
%         for k = 1:KRVEpi
%             i = (s-1)*KRVEpi+k;
%             eval(['SEG1_shift_resampled.RVEpiPoints.Frame' int2str(n) '(i,1) = SEG1_shift_resampled.ResolutionX*SEG1_shift_resampled.RVEpiXnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.RVEpiPoints.Frame' int2str(n) '(i,2) = SEG1_shift_resampled.ResolutionY*SEG1_shift_resampled.RVEpiYnew(k,n,s);']); 
%             eval(['SEG1_shift_resampled.RVEpiPoints.Frame' int2str(n) '(i,3) = RVEpiZ(k,s);']); 
%         end
%     end
% end
% 
% % for n = 1:NRV
% %     for s = 1:SRV
% %         for k = 1:KRV
% %             i = (s-1)*KRV+k;
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG1_shift_clean.RVEndoXnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG1_shift_clean.RVEndoYnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ(k,s);']); 
% %         end
% %     end
% % end
% 
% % Move RV after voxel-size adjustment (so that LV and RV don't overlap)
% baryCentreLVold(1,1) = mean(mean(SEG1_shift_resampled.EndoXold(:,1,:)));
% baryCentreLVold(1,2) = mean(mean(SEG1_shift_resampled.EndoYold(:,1,:)));
% %baryCentreLVold(1,3) = mean(mean(SEG_shift_resampled.ResolutionX*EndoZ));
% 
% baryCentreRVold(1,1) = mean(mean(SEG1_shift_resampled.RVEndoXold(:,1,:)));
% baryCentreRVold(1,2) = mean(mean(SEG1_shift_resampled.RVEndoYold(:,1,:)));
% %baryCentreRVold(1,3) = mean(mean(SEG_shift_resampled.ResolutionX*RVEndoZ));
% 
% directionBefore = baryCentreLVold - baryCentreRVold;
% lengthDirectionBefore = sqrt(directionBefore(1,1)^2 + directionBefore(1,2)^2);
% moveInDirection = SEG1_shift_resampled.ResolutionX * lengthDirectionBefore - lengthDirectionBefore;
% % for n = 1:NRV
% %     for s = 1:SRV
% %         for k = 1:KRV
% %             i = (s-1)*KRV+k;
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = moveInDirection+SEG1_shift_clean.RVEndoXnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = moveInDirection+SEG1_shift_clean.RVEndoYnew(k,n,s);']); 
% %             eval(['SEG1_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = SEG1_shift_clean.ResolutionX*RVEndoZ(k,s);']); 
% %         end
% %     end
% % end
% 
% SEG1 = SEG1_shift_resampled;

%% Add scar to the model
% Coordinates of scar points are kept in SEG(i).Scar.Manual
% for i = 1:noSubjects
%     eval(['Zlayers = unique(SEG' int2str(i) '.EpiPoints.Frame1(:,3), ''stable'');']);
%     Coordinates = [];
%     for s=1:length(Zlayers)
%         eval(['[X_scar, Y_scar] = find(SEG' int2str(i) '.Scar.Result(:, :, s));']);
%         if sum(size(X_scar)) > 2
%             Z_scar = ones(size(X_scar))*Zlayers(s);
%             Coordinates = [Coordinates; [X_scar Y_scar Z_scar]];
%         end
%     end
%     eval(['SEG' int2str(i) '.ScarNew = Coordinates;']);
% end
% 
% ScarZ = repmat((1-(1:SEG1_shift_resampled.ZSize))*(SEG1_shift_resampled.SliceThickness+SEG1_shift_resampled.SliceGap),...
%       [KRV 1]);
%   
% for n = 1
%     for s = 1:SRV
%         for k = 1:KRV
%             i = (s-1)*KRV+k;
%             SEG1.ScarNew(i,1) = SEG1_shift_resampled.ResolutionX*SEG1.ScarNew(k,1); 
%             SEG1.ScarNew(i,2) = SEG1_shift_resampled.ResolutionY*SEG1.ScarNew(k,2); 
%             SEG1.ScarNew(i,3) = ScarZ(k,s); 
%         end
%     end
% end
%%%%%%%%%%%%
%% Get scar for mhd

% NOTE: To be included in first steps, probably SliceAlignment
Scarsmhd = cell(noSubjects);

for i = Subjects
    Scarmhd = [];
    %initZshift = eval(['SEG' int2str(i) '.EndoPoints.Frame1(1,3);']);
    for s = eval(['1:size(SEG' int2str(i) '.EndoXnew, 3);']);
        eval(['[X_scar, Y_scar] = find(SEG' int2str(i) '.Scar.Result(:, :, s));']);
        %eval(['X_scar = SEG' int2str(i) '_shift_resampled.ResolutionX*X_scar;']);
        %eval(['Y_scar = SEG' int2str(i) '_shift_resampled.ResolutionY*Y_scar;']);
        eval(['sizenEndo=size(SEG' int2str(i) '.EndoXnew);']);
        KEndo = sizenEndo(1, 1); 
        eval(['EndoZ = repmat((1-(1:SEG' int2str(i) '.ZSize))*'...
            '(SEG' int2str(i) '.SliceThickness+SEG' int2str(i)...
            '.SliceGap), [KEndo 1]);']);
        Z_scar = repmat(EndoZ(1,s),size(X_scar),1);
        %Z_scar = Z_scar + initZshift;
        if sum(size(X_scar)) > 1
            Scartmp = [X_scar, Y_scar, Z_scar];
            Scarmhd = cat(1,Scarmhd,Scartmp);
        end
    end
    Scarsmhd{i} = Scarmhd;
    eval(['SEG' int2str(i) '.ScarMhd = Scarmhd;']);
end
displayWithScar(SEG3, 3, 1);
displaySEGandSCAR(SEG3);
%Saving .mhd files
for i = Subjects
    eval(['SaveMhd(SEG' int2str(i) ',' int2str(i) ');']);
end


% % displaySEGandSCAR(SEG1);
% displayWithScar(SEG2, 2, 1);

% displayWithScar(SEG3, 3, 1);
% displayWithScar(SEG4, 4, 1);
% displayWithScar(SEG5, 5, 1);

temp=round(Scarsmhd{1});
temp(:)=temp(:);
z=max(temp(:,3));
pix=zeros(SEG1.XSize,SEG1.YSize,SEG1.ZSize);
for i=1:SEG1.ZSize
    temp1=find(temp(:,3)==z);
    [c,d]=size(temp1);
    for j=1:c
        x=temp(temp1(j),1);
        y=temp(temp1(j),2);
        
          pix(x,y,i)=255;
        
    end
    z = z-SEG1.SliceThickness;
    
end
pixImage = uint8(pix);

rot = [1 0 0; 0 1 0; 0 0 -1];
shift = -(SEG1.ZSize-2)*SEG1.SliceThickness;
orig = [0 0 0]';
sp = [SEG1.ResolutionX SEG1.ResolutionY SEG1.SliceGap+SEG1.SliceThickness]';
orient = eye(3);

image = ImageType(size(squeeze(pixImage))', orig, sp, orient);
image.data = squeeze(pixImage);
%figure,
%image.show();
fprintf('saving...\n');
write_mhd('ScarImage1.mhd',image, 'elementtype', 'uint8');

%% Save all to new files

% Aligned models
for i = Subjects
    eval(['[pathstr,name,ext] = fileparts(filename{' num2str(i) '});']);
    suffix = '_aligned';
    outname = fullfile(['Data/Aligned/' name suffix ext]);
    eval(['save(outname,''SEG' int2str(i) ''');']);
end

% Scar images 
for i = Subjects
    prefix = 'Scar';
    eval(['S = SEG' num2str(i) '.ZSize;']);
    for j = 1:S
        if j>9
        eval(['imwrite(SEG' num2str(i) '.Scar.Result(:,:,j), [''Data/'...
            'ScarImages/ScarP_' num2str(i) '/ScarIm' int2str(j) '.jpg'']);']);
        else
            eval(['imwrite(SEG' num2str(i) '.Scar.Result(:,:,j), [''Data/'...
            'ScarImages/ScarP_' num2str(i) '/ScarIm0' int2str(j) '.jpg'']);']);
        end
    end
end
%% Write out to text files to be called in make_surface.py

% Scar texts not included, since we have .mhd
ext1 = '.txt';
for i = Subjects
    eval(['[pathstr,name,ext] = fileparts(filename{' num2str(i) '});']);
    for frame = 1
        eval(['suffix1 = ''-LVEndo-Frame_' int2str(frame) ''';']);
        eval(['suffix2 = ''-LVEpi-Frame_' int2str(frame) ''';']);
        eval(['suffix3 = ''-RVEndo-Frame_' int2str(frame) ''';']);
        eval(['suffix4 = ''-RVEpi-Frame_' int2str(frame) ''';']);
       % eval(['suffix5 = ''-Scar-' int2str(frame) ''';']);
       % eval(['suffix6 = ''-Scar-bin' int2str(frame) ''';']);
        outname1 = fullfile(['Data/Texts/' name suffix1 ext1]);
        outname2 = fullfile(['Data/Texts/' name suffix2 ext1]);
        outname3 = fullfile(['Data/Texts/' name suffix3 ext1]);
        outname4 = fullfile(['Data/Texts/' name suffix4 ext1]);
       % outname5 = fullfile(['Data/Texts/' name suffix5 ext1]);
       % outname6 = fullfile(['Data/Texts/' name suffix6 ext1]);
        eval(['dlmwrite(outname1, SEG' int2str(i) '.EndoPoints.Frame' int2str(frame) ','' '');']);
        eval(['dlmwrite(outname2, SEG' int2str(i) '.EpiPoints.Frame' int2str(frame) ','' '');']);
        eval(['dlmwrite(outname3, SEG' int2str(i) '.RVEndoPoints.Frame' int2str(frame) ','' '');']);
        eval(['dlmwrite(outname4, SEG' int2str(i) '.RVEpiPoints.Frame' int2str(frame) ','' '');']);
      % eval(['dlmwrite(outname5, SEG' int2str(i) '.ScarNew,'' '');']);
      % eval(['dlmwrite(outname6, SEG' int2str(i) '.Scar.Result,'' '');']);
    end
end


%% Clear unwanted variables
% for i = 1:noSubjects
%     eval(['clear filename' int2str(i) ';']);
%     eval(['clear SEG' int2str(i) '_shift;']);
%     eval(['clear SEG' int2str(i) '_shift_clean;']);
%     eval(['clear SEG' int2str(i) '_shift_resample;']);
% end
% clear i outname1 outname2 pathstr name ext suffix1 suffix2 frame Nnew noSubjects ext1 
%     
