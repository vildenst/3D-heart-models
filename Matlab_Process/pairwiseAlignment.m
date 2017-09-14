%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  TRANSFORM MOVING SUBJECT TO REFERENCE                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the center point of the point cloud representing the left or right
% ventricle
% Author - Kristin Mcleod
% SIMULA Research Laboratory
% Contact - kristin@simula.no
% May 2016
% Takes as input the filenames of the reference subject and target subject
% which should be pre-aligned and temporally resampled first using
% autoAlign.m and temporalResample.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SEG2new = pairwiseAlignment1(SEG_fixed,SEG_moving,IsFullTemporal)
%% Read data
% Read first filename to assign SEG1
SEG1      = SEG_fixed;
sizen1    = size(SEG1.EndoXnew);
sizen1epi = size(SEG1.EpiXnew);
sizenRV1  = size(SEG1.RVEndoXnew);
K1        = sizen1(1,1);
N1        = sizen1(1,2);
S1        = sizen1(1,3);
K1epi     = sizen1epi(1,1);
N1epi     = sizen1epi(1,2);
S1epi     = sizen1epi(1,3);
KRV1      = sizenRV1(1,1);
NRV1      = sizenRV1(1,2);
SRV1      = sizenRV1(1,3);
EndoZ1 = repmat((1-(1:SEG1.ZSize))*(SEG1.SliceThickness+SEG1.SliceGap),...
      [K1 1]);
EpiZ1 = repmat((1-(1:SEG1.ZSize))*(SEG1.SliceThickness+SEG1.SliceGap),...
      [K1epi 1]);
RVEndoZ1 = repmat((1-(1:SEG1.ZSize))*(SEG1.SliceThickness+SEG1.SliceGap),...
      [KRV1 1]);

% Read second filename to assign SEG2
SEG2      = SEG_moving; 
sizen2    = size(SEG2.EndoXnew);
sizen2epi = size(SEG2.EpiXnew);
sizenRV2  = size(SEG2.RVEndoXnew);
K2        = sizen2(1,1);
N2        = sizen2(1,2);
S2        = sizen2(1,3);
K2epi     = sizen2epi(1,1);
N2epi     = sizen2epi(1,2);
S2epi     = sizen2epi(1,3);
KRV2      = sizenRV2(1,1);
NRV2      = sizenRV2(1,2);
SRV2      = sizenRV2(1,3);
EndoZ2 = repmat((1-(1:SEG2.ZSize))*(SEG2.SliceThickness+SEG2.SliceGap),...
      [K2 1]);
EpiZ2 = repmat((1-(1:SEG2.ZSize))*(SEG2.SliceThickness+SEG2.SliceGap),...
      [K2epi 1]);
RVEndoZ2 = repmat((1-(1:SEG2.ZSize))*(SEG2.SliceThickness+SEG2.SliceGap),...
      [KRV2 1]);

%% Create physical points from EndoX and EndoY for fixed patient
% Move RV after voxel-size adjustment (so that LV and RV don't overlap)
baryCentreLVold1(1,1) = mean(mean(SEG1.EndoXnew(:,1,:)));
baryCentreLVold1(1,2) = mean(mean(SEG1.EndoYnew(:,1,:)));

baryCentreRVold1(1,1) = mean(mean(SEG1.RVEndoXnew(:,1,:)));

directionBefore1 = baryCentreLVold1 - baryCentreRVold1;
lengthDirectionBefore1 = sqrt(directionBefore1(1,1)^2 + directionBefore1(1,2)^2);
moveInDirection1 = SEG1.ResolutionX * lengthDirectionBefore1 - lengthDirectionBefore1;

if IsFullTemporal == 1
    for n = 1:N1
        for s = 1:S1
            for k = 1:K1
                i = (s-1)*K1+k;
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.EndoXnew(k,n,s);']); 
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.EndoYnew(k,n,s);']); 
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,3) = EndoZ1(k,s);']); 
            end
        end
    end

    % Same for Epi
    for n = 1:N1epi
        for s = 1:S1epi
            for k = 1:K1epi
                i = (s-1)*K1epi+k;
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.EpiXnew(k,n,s);']); 
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.EpiYnew(k,n,s);']); 
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ1(k,s);']); 
            end
        end
    end

    %Same for RV endo
    for n = 1:NRV1
        for s = 1:SRV1
            for k = 1:KRV1
                i = (s-1)*KRV1+k;
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.RVEndoXnew(k,n,s);']); 
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.RVEndoYnew(k,n,s);']); 
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ1(k,s);']); 
            end
        end 
    end

    %% Create physical points from EndoX and EndoY for moving patient
    % Move RV after voxel-size adjustment (so that LV and RV don't overlap)
    baryCentreLVold2(1,1) = mean(mean(SEG2.EndoXnew(:,1,:)));
    baryCentreLVold2(1,2) = mean(mean(SEG2.EndoYnew(:,1,:)));
    %baryCentreLVold(1,3) = mean(mean(SEG_shift_resampled.ResolutionX*EndoZ));

    baryCentreRVold2(1,1) = mean(mean(SEG2.RVEndoXnew(:,1,:)));
    baryCentreRVold2(1,2) = mean(mean(SEG2.RVEndoYnew(:,1,:)));
    %baryCentreRVold(1,3) = mean(mean(SEG_shift_resampled.ResolutionX*RVEndoZ));

    directionBefore2 = baryCentreLVold2 - baryCentreRVold2;
    lengthDirectionBefore2 = sqrt(directionBefore2(1,1)^2 + directionBefore2(1,2)^2);
    moveInDirection2 = SEG2.ResolutionX * lengthDirectionBefore2 - lengthDirectionBefore2;
    for n = 1:N2
        for s = 1:S2
            for k = 1:K2
                i = (s-1)*K2+k;
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.EndoXnew(k,n,s);']); 
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.EndoYnew(k,n,s);']); 
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,3) = EndoZ2(k,s);']); 
            end
        end
    end

    % Same for Epi
    for n = 1:N2epi
        for s = 1:S2epi
            for k = 1:K2epi
                i = (s-1)*K2epi+k;
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.EpiXnew(k,n,s);']); 
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.EpiYnew(k,n,s);']); 
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ2(k,s);']); 
            end
        end
    end

    % Same for RV Endo
    for n = 1:NRV2
        for s = 1:SRV2
            for k = 1:KRV2
                i = (s-1)*KRV2+k;
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.RVEndoXnew(k,n,s);']); 
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.RVEndoYnew(k,n,s);']); 
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ2(k,s);']); 
            end
        end 
    end

    %% Compute transformation components (scaling, translation, rotation)
    % Compute barycentres (choose the 1st frame as the reference)
    baryCentreLV1(1,1) = mean(SEG1.EndoPoints.Frame1(:,1));
    baryCentreLV1(1,2) = mean(SEG1.EndoPoints.Frame1(:,2));
    baryCentreLV1(1,3) = mean(SEG1.EndoPoints.Frame1(:,3));

    baryCentreRV1(1,1) = mean(SEG1.RVEndoPoints.Frame1(:,1));
    baryCentreRV1(1,2) = mean(SEG1.RVEndoPoints.Frame1(:,2));
    baryCentreRV1(1,3) = mean(SEG1.RVEndoPoints.Frame1(:,3));

    baryCentreLV2(1,1) = mean(SEG2.EndoPoints.Frame1(:,1));
    baryCentreLV2(1,2) = mean(SEG2.EndoPoints.Frame1(:,2));
    baryCentreLV2(1,3) = mean(SEG2.EndoPoints.Frame1(:,3));

    baryCentreRV2(1,1) = mean(SEG2.RVEndoPoints.Frame1(:,1));
    baryCentreRV2(1,2) = mean(SEG2.RVEndoPoints.Frame1(:,2));
    baryCentreRV2(1,3) = mean(SEG2.RVEndoPoints.Frame1(:,3));

    % Get length of line segments joining LV centre and RV centre  
    length1 = sqrt((abs(baryCentreLV1(1,1)-baryCentreRV1(1,1))^2 + ...
        abs(baryCentreLV1(1,2) - baryCentreRV1(1,2))^2 + ...
        abs(baryCentreLV1(1,3) - baryCentreRV1(1,3))^2));

    length2 = sqrt((abs(baryCentreLV2(1,1)-baryCentreRV2(1,1))^2 + ...
        abs(baryCentreLV2(1,2) - baryCentreRV2(1,2))^2 + ...
        abs(baryCentreLV2(1,3) - baryCentreRV2(1,3))^2));

    % Compute scaling factor between line segments
    scale = length1 / length2;

    % Compute translation (translate to match x-points)
    translation = baryCentreLV2-baryCentreLV1;

    %Copy to new struct
    SEG2new = SEG2;
    SEG1new = SEG1;

    %% Translate main axis of moving patient back to the origin
    for n = 1:N2
        eval(['l = length(SEG2.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2.EndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Same for Epi
    for n = 1:N2epi
        eval(['l = length(SEG2.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2.EpiPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Same for RV Endo
    for n = 1:NRV2
        eval(['l = length(SEG2.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2.RVEndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Do for fixed subject as well
    for n = 1:N1
        eval(['l = length(SEG1.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.EndoPoints.Frame' int2str(n) '(i,:) = SEG1.EndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end

    % Same for Epi
    for n = 1:N1epi
        eval(['l = length(SEG1.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.EpiPoints.Frame' int2str(n) '(i,:) = SEG1.EpiPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end

    % Same for RV Endo
    for n = 1:NRV1
        eval(['l = length(SEG1.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG1.RVEndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end
    %% Rotate 
    baryCentreLV1new(1,1) = mean(SEG1new.EndoPoints.Frame1(1:80,1));
    baryCentreLV1new(1,2) = mean(SEG1new.EndoPoints.Frame1(1:80,2));
    baryCentreLV1new(1,3) = mean(SEG1new.EndoPoints.Frame1(1:80,3));

    baryCentreRV1new(1,1) = mean(SEG1new.RVEndoPoints.Frame1(1:80,1));
    baryCentreRV1new(1,2) = mean(SEG1new.RVEndoPoints.Frame1(1:80,2));
    baryCentreRV1new(1,3) = mean(SEG1new.RVEndoPoints.Frame1(1:80,3));

    baryCentreLV2new(1,1) = mean(SEG2new.EndoPoints.Frame1(1:80,1));
    baryCentreLV2new(1,2) = mean(SEG2new.EndoPoints.Frame1(1:80,2));
    baryCentreLV2new(1,3) = mean(SEG2new.EndoPoints.Frame1(1:80,3));

    baryCentreRV2new(1,1) = mean(SEG2new.RVEndoPoints.Frame1(1:80,1));
    baryCentreRV2new(1,2) = mean(SEG2new.RVEndoPoints.Frame1(1:80,2));
    baryCentreRV2new(1,3) = mean(SEG2new.RVEndoPoints.Frame1(1:80,3));

    baryCentreLV1normed = ((baryCentreRV1new-(baryCentreLV1new)));
    baryCentreLV2normed = ((baryCentreRV2new-(baryCentreLV2new)));
    % Compute angle of rotation between the line segments
    rotationAngle = acos((baryCentreLV1normed(1,1) * baryCentreLV2normed(1,1) + ...
        baryCentreLV1normed(1,2) * baryCentreLV2normed(1,2))/(...
        sqrt(baryCentreLV1normed(1,1)^2 + baryCentreLV1normed(1,2)^2) * ... 
        sqrt(baryCentreLV2normed(1,1)^2 + baryCentreLV2normed(1,2)^2)));

    %rotationAngle = rotationAngle*180/pi;
    rotationMatrix = [cos(rotationAngle) sin(rotationAngle) 0; ...
                      -sin(rotationAngle) cos(rotationAngle) 0; ...
                      0 0 1];

    for n = 1:N2
        eval(['l = length(SEG2new.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2new.EndoPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end

    % Same for Epi
    for n = 1:N2epi
        eval(['l = length(SEG2new.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2new.EpiPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end

    % Same for RV Endo
    for n = 1:NRV2
        eval(['l = length(SEG2new.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end
    
    %% Translate to fit main axis of fixed patient  
    for n = 1:N2
        eval(['l = length(SEG2new.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2new.EndoPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end

    % Same for Epi
    for n = 1:N2epi
        eval(['l = length(SEG2new.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2new.EpiPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end

    % Same for RV Endo
    for n = 1:NRV2
        eval(['l = length(SEG2new.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end

else
    for n = 1
        for s = 1:S1
            for k = 1:K1
                i = (s-1)*K1+k;
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.EndoXnew(k,n,s);']); 
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.EndoYnew(k,n,s);']); 
                eval(['SEG1.EndoPoints.Frame' int2str(n) '(i,3) = EndoZ1(k,s);']); 
            end
        end
    end

    % Same for Epi
    for n = 1
        for s = 1:S1epi
            for k = 1:K1epi
                i = (s-1)*K1epi+k;
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.EpiXnew(k,n,s);']); 
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.EpiYnew(k,n,s);']); 
                eval(['SEG1.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ1(k,s);']); 
            end
        end
    end

    %Same for RV endo
    for n = 1
        for s = 1:SRV1
            for k = 1:KRV1
                i = (s-1)*KRV1+k;
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG1.ResolutionX*SEG1.RVEndoXnew(k,n,s);']); 
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG1.ResolutionY*SEG1.RVEndoYnew(k,n,s);']); 
                eval(['SEG1.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ1(k,s);']); 
            end
        end 
    end

    %% Create physical points from EndoX and EndoY for moving patient
    % Move RV after voxel-size adjustment (so that LV and RV don't overlap)
    baryCentreLVold2(1,1) = mean(mean(SEG2.EndoXnew(:,1,:)));
    baryCentreLVold2(1,2) = mean(mean(SEG2.EndoYnew(:,1,:)));

    baryCentreRVold2(1,1) = mean(mean(SEG2.RVEndoXnew(:,1,:)));
    baryCentreRVold2(1,2) = mean(mean(SEG2.RVEndoYnew(:,1,:)));

    directionBefore2 = baryCentreLVold2 - baryCentreRVold2;
    lengthDirectionBefore2 = sqrt(directionBefore2(1,1)^2 + directionBefore2(1,2)^2);
    moveInDirection2 = SEG2.ResolutionX * lengthDirectionBefore2 - lengthDirectionBefore2;
    for n = 1
        for s = 1:S2
            for k = 1:K2
                i = (s-1)*K2+k;
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.EndoXnew(k,n,s);']); 
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.EndoYnew(k,n,s);']); 
                eval(['SEG2.EndoPoints.Frame' int2str(n) '(i,3) = EndoZ2(k,s);']); 
            end
        end
    end

    % Same for Epi
    for n = 1
        for s = 1:S2epi
            for k = 1:K2epi
                i = (s-1)*K2epi+k;
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.EpiXnew(k,n,s);']); 
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.EpiYnew(k,n,s);']); 
                eval(['SEG2.EpiPoints.Frame' int2str(n) '(i,3) = EpiZ2(k,s);']); 
            end
        end
    end

    % Same for RV Endo
    for n = 1
        for s = 1:SRV2
            for k = 1:KRV2
                i = (s-1)*KRV2+k;
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG2.ResolutionX*SEG2.RVEndoXnew(k,n,s);']); 
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG2.ResolutionY*SEG2.RVEndoYnew(k,n,s);']); 
                eval(['SEG2.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ2(k,s);']); 
            end
        end 
    end

    %% Compute transformation components (scaling, translation, rotation)
    % Compute barycentres (choose the 1st frame as the reference)
    baryCentreLV1(1,1) = mean(SEG1.EndoPoints.Frame1(:,1));
    baryCentreLV1(1,2) = mean(SEG1.EndoPoints.Frame1(:,2));
    baryCentreLV1(1,3) = mean(SEG1.EndoPoints.Frame1(:,3));

    baryCentreRV1(1,1) = mean(SEG1.RVEndoPoints.Frame1(:,1));
    baryCentreRV1(1,2) = mean(SEG1.RVEndoPoints.Frame1(:,2));
    baryCentreRV1(1,3) = mean(SEG1.RVEndoPoints.Frame1(:,3));

    baryCentreLV2(1,1) = mean(SEG2.EndoPoints.Frame1(:,1));
    baryCentreLV2(1,2) = mean(SEG2.EndoPoints.Frame1(:,2));
    baryCentreLV2(1,3) = mean(SEG2.EndoPoints.Frame1(:,3));

    baryCentreRV2(1,1) = mean(SEG2.RVEndoPoints.Frame1(:,1));
    baryCentreRV2(1,2) = mean(SEG2.RVEndoPoints.Frame1(:,2));
    baryCentreRV2(1,3) = mean(SEG2.RVEndoPoints.Frame1(:,3));

    % Get length of line segments joining LV centre and RV centre  
    length1 = sqrt((abs(baryCentreLV1(1,1)-baryCentreRV1(1,1))^2 + ...
        abs(baryCentreLV1(1,2) - baryCentreRV1(1,2))^2 + ...
        abs(baryCentreLV1(1,3) - baryCentreRV1(1,3))^2));

    length2 = sqrt((abs(baryCentreLV2(1,1)-baryCentreRV2(1,1))^2 + ...
        abs(baryCentreLV2(1,2) - baryCentreRV2(1,2))^2 + ...
        abs(baryCentreLV2(1,3) - baryCentreRV2(1,3))^2));

    % Compute scaling factor between line segments
    scale = length1 / length2;

    % Compute translation (translate to match x-points)
    translation = baryCentreLV2-baryCentreLV1;

    %Copy to new struct
    SEG2new = SEG2;
    SEG1new = SEG1;

    %% Translate main axis of moving patient back to the origin
    for n = 1
        eval(['l = length(SEG2.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2.EndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Same for Epi
    for n = 1
        eval(['l = length(SEG2.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2.EpiPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Same for RV Endo
    for n = 1
        eval(['l = length(SEG2.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2.RVEndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV2;']); 
        end
    end

    % Do for fixed subject as well
    for n = 1
        eval(['l = length(SEG1.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.EndoPoints.Frame' int2str(n) '(i,:) = SEG1.EndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end

    % Same for Epi
    for n = 1
        eval(['l = length(SEG1.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.EpiPoints.Frame' int2str(n) '(i,:) = SEG1.EpiPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end

    % Same for RV Endo
    for n = 1
        eval(['l = length(SEG1.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG1new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG1.RVEndoPoints.Frame' int2str(n) '(i,:) - baryCentreLV1;']); 
        end
    end

    %% Rotate 
    baryCentreLV1new(1,1) = mean(SEG1new.EndoPoints.Frame1(1:80,1));
    baryCentreLV1new(1,2) = mean(SEG1new.EndoPoints.Frame1(1:80,2));
    baryCentreLV1new(1,3) = mean(SEG1new.EndoPoints.Frame1(1:80,3));

    baryCentreRV1new(1,1) = mean(SEG1new.RVEndoPoints.Frame1(1:80,1));
    baryCentreRV1new(1,2) = mean(SEG1new.RVEndoPoints.Frame1(1:80,2));
    baryCentreRV1new(1,3) = mean(SEG1new.RVEndoPoints.Frame1(1:80,3));

    baryCentreLV2new(1,1) = mean(SEG2new.EndoPoints.Frame1(1:80,1));
    baryCentreLV2new(1,2) = mean(SEG2new.EndoPoints.Frame1(1:80,2));
    baryCentreLV2new(1,3) = mean(SEG2new.EndoPoints.Frame1(1:80,3));

    baryCentreRV2new(1,1) = mean(SEG2new.RVEndoPoints.Frame1(1:80,1));
    baryCentreRV2new(1,2) = mean(SEG2new.RVEndoPoints.Frame1(1:80,2));
    baryCentreRV2new(1,3) = mean(SEG2new.RVEndoPoints.Frame1(1:80,3));

    baryCentreLV1normed = ((baryCentreRV1new-(baryCentreLV1new)));
    baryCentreLV2normed = ((baryCentreRV2new-(baryCentreLV2new)));
    % Compute angle of rotation between the line segments
    rotationAngle = acos((baryCentreLV1normed(1,1) * baryCentreLV2normed(1,1) + ...
        baryCentreLV1normed(1,2) * baryCentreLV2normed(1,2))/(...
        sqrt(baryCentreLV1normed(1,1)^2 + baryCentreLV1normed(1,2)^2) * ... 
        sqrt(baryCentreLV2normed(1,1)^2 + baryCentreLV2normed(1,2)^2)));

    %rotationAngle = rotationAngle*180/pi;
    rotationMatrix = [cos(rotationAngle) sin(rotationAngle) 0; ...
                      -sin(rotationAngle) cos(rotationAngle) 0; ...
                      0 0 1];


    for n = 1
        eval(['l = length(SEG2new.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2new.EndoPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end

    % Same for Epi
    for n = 1
        eval(['l = length(SEG2new.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2new.EpiPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end

    % Same for RV Endo
    for n = 1
        eval(['l = length(SEG2new.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) * rotationMatrix;']); 
        end
    end

    %% Translate to fit main axis of fixed patient  
    for n = 1
        eval(['l = length(SEG2new.EndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EndoPoints.Frame' int2str(n) '(i,:) = SEG2new.EndoPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end

    % Same for Epi
    for n = 1
        eval(['l = length(SEG2new.EpiPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.EpiPoints.Frame' int2str(n) '(i,:) = SEG2new.EpiPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end

    % Same for RV Endo
    for n = 1
        eval(['l = length(SEG2new.RVEndoPoints.Frame' int2str(n) ');']);
        for i = 1:l
            eval(['SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) = SEG2new.RVEndoPoints.Frame' int2str(n) '(i,:) + baryCentreLV1;']); 
        end
    end
end

end
