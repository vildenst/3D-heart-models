%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PRE-PROCESS AND ALIGN ALL TO REFERENCE                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULA Research Laboratory
% For GOSH TOF patients at ED only (bi-ventricle)
% Contact - kristin@simula.no, maciej.mar92@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
home=getenv('HOME');
toolbox_path='/Programs/Medical_Image_Processing_Toolbox/code/MedicalImageProcessingToolbox';
path(path, [home,'',toolbox_path,'','/class_image']);
path(path, [home,'',toolbox_path,'','/processing/IO']);
N = length(dir(['../seg/*.mat']));
noSubjects = N;  % Total number of subjects 
RVyes = 1;
IsFullTemporal = 0;
filename = cell(noSubjects,1);
SEGold = cell(noSubjects,1);
SEG_shift = cell(noSubjects,1);
SEG_shift_clean = cell(noSubjects,1);SEG_shift_resampled = cell(noSubjects,1);

global SEG;
SEG = cell(noSubjects,1);

% Prefix for current cohort

%database='segment_';
database='Patient_';

% File naming convention:
% If database == CPH_, files should be named CPH_1, CPH_2 ... CPH_82
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First give filenames for all subjects and load them
% Find existing files
Subjects = [];
for i = 1:noSubjects
    if exist(['Data/Seg/' database num2str(i) '.mat'], 'file')
    filename{i} = ['Data/Seg/' database num2str(i) '.mat'];
    Subjects = [Subjects i];
    end
end

% Load files
disp('Loading files...');
for i = Subjects
    tmp = load(filename{i},'-mat','setstruct');
    SEGold{i} = tmp.setstruct; 
end
clear tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run sliceAlignment.m to remove slice mis-alignments
disp('Slice alignment...');
for i = Subjects
    SEG_shift{i} = sliceAlignmentwithBivEpi(SEGold{i},RVyes,...
        IsFullTemporal);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Run cleanPointIndices.m to fix the point indexing
disp('Cleaning indices...');
for i = Subjects
    SEG_shift_clean{i} = cleanPointIndiceswithBivEpi(SEG_shift{i},RVyes,...
        IsFullTemporal);
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run temporalResampling.m to resample all to have the same no. of frames

for i = Subjects
   % eval(['SEG' int2str(i) '_shift_resampled=temporalResample...
    %(SEG' int2str(i) '_shift,Nnew);']); % Without temporal alignment
    SEG_shift_resampled{i} = notTemporalResampleAlignmentwithBivEpi...
        (SEG_shift_clean{i},RVyes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run pairwiseAlignment.m to resample all to a common space
% Assume subject 1 is the reference and iterate over all other
disp('Pairwise alignment...');
for i = Subjects(2:end)
    SEG{i} = pairwiseAlignmentwithBivEpi(SEG_shift_resampled{1},...
        SEG_shift_resampled{i},IsFullTemporal);
end

% Finally, change resolution for Subject1 for good
SEG{1} = ChangeReswithBivEpi(SEG_shift_resampled{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save all to new files

% Aligned models

disp('Saving files...');
% Scar images
 for i = Subjects
     SaveMhd(i, filename{i});
 end

 % Scar percentage
 SV = [];
 for i = Subjects
     SV(i) = SEG{i, 1}.Scar.Percentage;
 end
 ScarVolumeFile = fullfile(['Data/ScarVolume.txt']);
 dlmwrite(ScarVolumeFile, SV, 'delimiter', ' ');
 
% Text files to be called in make_surface.py
ext1 = '.txt';
for i = Subjects
    [pathstr,name,ext] = fileparts(filename{i});
    if i<10
        name = [name(1:end-1) int2str(i)];
    end
    
    for frame = 1
        suffix = '_aligned';
        suffix1 = ['-LVEndo-Frame_' int2str(frame)];
        suffix2 = ['-LVEpi-Frame_' int2str(frame)];
        suffix3 = ['-RVEndo-Frame_' int2str(frame)];
        suffix4 = ['-RVEpi-Frame_' int2str(frame)];
        %eval(['suffix5 = ''-Scar-' int2str(frame) ''';']);
        %eval(['suffix6 = ''-Scar-bin' int2str(frame) ''';']);
        outname = ['Data/Aligned/' name suffix ext];
        outname1 = fullfile(['Data/Texts/' name suffix1 ext1]);
        outname2 = fullfile(['Data/Texts/' name suffix2 ext1]);
        outname3 = fullfile(['Data/Texts/' name suffix3 ext1]);
        outname4 = fullfile(['Data/Texts/' name suffix4 ext1]);
        %outname5 = fullfile(['Data/Texts/' name suffix5 ext1]);
        %outname6 = fullfile(['Data/Texts/' name suffix6 ext1]);
        SEGsave = SEG{i};
        save(outname, 'SEGsave');
        dlmwrite(outname1, SEG{i}.EndoPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname2, SEG{i}.EpiPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname3, SEG{i}.RVEndoPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname4, SEG{i}.RVEpiPoints.Frame{frame}, 'delimiter',' ');
       %eval(['dlmwrite(outname5, SEG' int2str(i) '.ScarNew,'' '');']);
       %eval(['dlmwrite(outname6, SEG' int2str(i) '.Scar.Result,'' '');']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualisation
 %displayWithScar(3, 1);
 %displaySEGandSCAR(SEG{1});
