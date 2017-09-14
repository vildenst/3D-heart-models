%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                              ALIGN SLICES                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the center point of the point cloud representing the left or right
% ventricle
% Author - Eric Davenne and Kristin McLeod
% SIMULA Research Laboratory
% Contact - kristin@simula.no
% October 2014
% This function aligns automatically segmentation contours. Takes a SEG
% structure as argument and returns a SEG structure with aligned slices.
% Alignement is performed using a linear least square estimation of the 
% center of all slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SEG_shift = sliceAlignment(SEG,RVyes,IsFullTemporal)
% DO NOTHING, SLICES ARE ALREADY ALIGNED FOR THIS DATASET


sizen=size(SEG.EndoX);
K = sizen(1, 1);
N = sizen(1, 2);
S = sizen(1, 3);
sizenEpi=size(SEG.EpiX);
KEpi = sizenEpi(1, 1);
NEpi = sizenEpi(1, 2);
SEpi = sizenEpi(1, 3);

if RVyes==1
    sizenRV=size(SEG.RVEndoX);
    KRV = sizenRV(1, 1);
    NRV = sizenRV(1, 2);
    SRV = sizenRV(1, 3);
    zRV = (1:SRV)*SEG.SliceThickness;
    
    %XRV_avgs = mean(SEG.RVEndoX);
    %YRV_avgs = mean(SEG.RVEndoY);
end
% 
i = 1;
for s = 1:S
    if s > 1
        if ~isnan(endo(k,1))
            i = i+1;
        end
    end
    for k = 1:K
        EndoX(:,:)=SEG.EndoX(:,1,s);
        EndoY(:,:)=SEG.EndoY(:,1,s); 
        endo = sum(EndoX,2);
        % Remove NaN values in the array
        if ~isnan(endo(k,1)) 
            tmp1(k,1) = EndoX(k,1);
            tmp2(k,1) = EndoY(k,1);
            EndoXnew(k,1,i) = tmp1(k,1);
            EndoYnew(k,1,i) = tmp2(k,1);
        end
    end
end
i = 1;
for s = 1:SEpi
    if s > 1
        if ~isnan(epi(k,1))
            i = i+1;
        end
    end
    for k = 1:KEpi
        EpiX(:,:)=SEG.EpiX(:,1,s);
        EpiY(:,:)=SEG.EpiY(:,1,s); 
        epi = sum(EpiX,2);
        % Remove NaN values in the array
        if ~isnan(epi(k,1)) 
            tmp1(k,1) = EpiX(k,1);
            tmp2(k,1) = EpiY(k,1);
            EpiXnew(k,1,i) = tmp1(k,1);
            EpiYnew(k,1,i) = tmp2(k,1);
        end
    end  
end
i = 1;
for s = 1:SRV
    if s > 1
        if ~isnan(rv(k,1))
            i = i+1;
        end
    end
    for k = 1:KRV
        RVX(:,:)=SEG.RVEndoX(:,1,s);
        RVY(:,:)=SEG.RVEndoY(:,1,s); 
        rv = sum(RVX,2);
        % Remove NaN values in the array
        if ~isnan(rv(k,1)) 
            tmp1(k,1) = RVX(k,1);
            tmp2(k,1) = RVY(k,1);
            RVEndoXnew(k,1,i) = tmp1(k,1);
            RVEndoYnew(k,1,i) = tmp2(k,1);
        end
    end
end
SEG_shift = SEG;
%clear SEG_shift.EndoX SEG_shift.EndoY SEG_shift.EpiX SEG_shift.EpiY SEG_shift.RVEndoX SEG_shift.RVEndoY
SEG_shift.EndoXnew = EndoXnew;
SEG_shift.EndoYnew = EndoYnew;
SEG_shift.EpiXnew = EpiXnew;
SEG_shift.EpiYnew = EpiYnew;
SEG_shift.RVEndoXnew = RVEndoXnew;
SEG_shift.RVEndoYnew = RVEndoYnew;


 SEG_shift.isFullTemporal = IsFullTemporal;
% 
% % X_avgs : array cointaining the barycenters of each slice and frame
% % X_avgs(1, frame, slice)
% % contour barycenters are computed as the mean of all LV contour points
% % in a slice
% 
% for s = 1:S
%     if ~isnan(SEG.EndoX(1,1,s)) 
%         X_avgs = 0.5*mean(SEG.EpiX + SEG.EndoX);
%         Y_avgs = 0.5*mean(SEG.EpiY + SEG.EndoY);
%     else
%         X_avgs = mean(SEG.EpiX);
%         Y_avgs = mean(SEG.EpiY);
%     end
% end
%     
% 
% 
 zEndo = (1:S)*SEG.SliceThickness;
 zEpi = (1:SEpi)*SEG.SliceThickness;
% 
% if IsFullTemporal == 1
%     for n=1:N
% 
%         x = X_avgs(1, n, :);
%         y = Y_avgs(1, n, :);
% 
%         % Computing least squares linear regression of barycenters for both 
%         % coordinates X and Y.
% 
%         lmX = LinearModel.fit(zEndo, x(:));
%         lmY = LinearModel.fit(zEndo, y(:));
% 
%         % estX linear least squares estimation of barycenter X coordinate
% 
%         estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEndo;
%         estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEndo;
% 
%         % Shifting each segment contour so that all barycenters are located
%         % on the regression lines for both X and Y coordinates.
% 
%         for s=1:S
% 
%             shiftX = x(:) - estX(s);
%             shiftY = y(:) - estY(s);
% 
%             SEG_shift.EndoX(:, n, s) = SEG.EndoX(:, n, s) - shiftX(s);
%             SEG_shift.EndoY(:, n, s) = SEG.EndoY(:, n, s) - shiftY(s);
%         end
%     end
%     for n = 1:N
%         x = X_avgs(1, n, :);
%         y = Y_avgs(1, n, :);
% 
%         % Computing least squares linear regression of barycenters for both 
%         % coordinates X and Y.
% 
%         lmX = LinearModel.fit(zEpi, x(:));
%         lmY = LinearModel.fit(zEpi, y(:));
% 
%         % estX linear least squares estimation of barycenter X coordinate
% 
%         estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEpi;
%         estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEpi;
% 
%         % Shifting each segment contour so that all barycenters are located
%         % on the regression lines for both X and Y coordinates.
%         for s=1:SEpi
% 
%             shiftX = x(:) - estX(s);
%             shiftY = y(:) - estY(s);
% 
%             SEG_shift.EpiX(:, n, s) = SEG.EpiX(:, n, s) - shiftX(s);
%             SEG_shift.EpiY(:, n, s) = SEG.EpiY(:, n, s) - shiftY(s);
%         end
%     end
%     if RVyes == 1
%         for n = 1:N
%             %x = XRV_avgs(1, n, :);
%             %y = YRV_avgs(1, n, :);
%             x = X_avgs(1, n, :);
%             y = Y_avgs(1, n, :);
% 
%             % Computing least squares linear regression of barycenters for both 
%             % coordinates X and Y.
% 
%             lmX = LinearModel.fit(zRV, x(:));
%             lmY = LinearModel.fit(zRV, y(:));
% 
%             % estX linear least squares estimation of barycenter X coordinate
% 
%             estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zRV;
%             estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zRV;
% 
%             % Shifting each segment contour so that all barycenters are located
%             % on the regression lines for both X and Y coordinates.
%             for s=1:SRV
% 
%                 shiftX = x(:) - estX(s);
%                 shiftY = y(:) - estY(s);
% 
%                 if SEG_shift.isFullTemporal == 1
%                     if n == SEG.EDT || n == SEG.EST
%                         SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s) - shiftX(s);
%                         SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s) - shiftY(s);
%                     end
%                 else
%                     SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s) - shiftX(s);
%                     SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s) - shiftY(s);
%                 end
%             end
%         end
%     end
% else 
    for n=1

        %x = X_avgs(1, n, :);
        %y = Y_avgs(1, n, :);

        % Computing least squares linear regression of barycenters for both 
        % coordinates X and Y.

        %lmX = LinearModel.fit(zEndo, x(:));
        %lmY = LinearModel.fit(zEndo, y(:));

        % estX linear least squares estimation of barycenter X coordinate

        %estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEndo;
        %estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEndo;

        % Shifting each segment contour so that all barycenters are located
        % on the regression lines for both X and Y coordinates.

        for s=1:S

            %shiftX = x(:) - estX(s);
            %shiftY = y(:) - estY(s);

            SEG_shift.EndoX(:, n, s) = SEG.EndoX(:, n, s); %- shiftX(s);
            SEG_shift.EndoY(:, n, s) = SEG.EndoY(:, n, s); %- shiftY(s);
        end
    end
    for n = 1
        %x = X_avgs(1, n, :);
        %y = Y_avgs(1, n, :);

        % Computing least squares linear regression of barycenters for both 
        % coordinates X and Y.

        %lmX = LinearModel.fit(zEpi, x(:));
        %lmY = LinearModel.fit(zEpi, y(:));

        % estX linear least squares estimation of barycenter X coordinate

        %estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEpi;
        %estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEpi;

        % Shifting each segment contour so that all barycenters are located
        % on the regression lines for both X and Y coordinates.
        for s=1:SEpi

            %shiftX = x(:) - estX(s);
            %shiftY = y(:) - estY(s);

            SEG_shift.EpiX(:, n, s) = SEG.EpiX(:, n, s); % - shiftX(s);
            SEG_shift.EpiY(:, n, s) = SEG.EpiY(:, n, s); % - shiftY(s);
        end
    end
    if RVyes == 1
        for n = 1
            %x = XRV_avgs(1, n, :);
            %y = YRV_avgs(1, n, :);
            %x = X_avgs(1, n, :);
            %y = Y_avgs(1, n, :);

            % Computing least squares linear regression of barycenters for both 
            % coordinates X and Y.

            %lmX = LinearModel.fit(zRV, x(:));
            %lmY = LinearModel.fit(zRV, y(:));

            % estX linear least squares estimation of barycenter X coordinate

            %estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zRV;
            %estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zRV;

            % Shifting each segment contour so that all barycenters are located
            % on the regression lines for both X and Y coordinates.
            for s=1:SRV

                %shiftX = x(:) - estX(s);
                %shiftY = y(:) - estY(s);

                if SEG_shift.isFullTemporal == 1
                    if n == SEG.EDT || n == SEG.EST
                        SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s); % - shiftX(s);
                        SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s); % - shiftY(s);
                    end
                else
                    SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s); % - shiftX(s);
                    SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s); % - shiftY(s);
                end
            end
        end
%     end
end
