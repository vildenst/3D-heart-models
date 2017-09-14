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
% July 2016
% This function aligns automatically segmentation contours. Takes a SEG
% structure as argument and returns a SEG structure with aligned slices.
% Alignement is performed using a linear least square estimation of the 
% center of all slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SEG_shift = sliceAlignmentwithBivEpi(SEG,RVyes,IsFullTemporal)

sizen=size(SEG.EndoX);
K = sizen(1, 1);
N = sizen(1, 2);
S = sizen(1, 3);
zEndo = (1:S)*SEG.SliceThickness;

sizenEpi=size(SEG.EpiX);
KEpi = sizenEpi(1, 1);
NEpi = sizenEpi(1, 2);
SEpi = sizenEpi(1, 3);
zEpi = (1:SEpi)*SEG.SliceThickness;

if RVyes==1
    sizenRV=size(SEG.RVEndoX);
    KRV = sizenRV(1, 1);
    NRV = sizenRV(1, 2);
    SRV = sizenRV(1, 3);
    zRV = (1:SRV)*SEG.SliceThickness;

    sizenRVEpi=size(SEG.RVEpiX);
    KRVEpi = sizenRVEpi(1, 1);
    NRVEpi = sizenRVEpi(1, 2);
    SRVEpi = sizenRVEpi(1, 3);
    zRVEpi = (1:SRVEpi)*SEG.SliceThickness;    
    
    XRV_avgs = mean(SEG.RVEndoX);
    YRV_avgs = mean(SEG.RVEndoY);
end


% X_avgs : array cointaining the barycenters of each slice and frame
% X_avgs(1, frame, slice)
% contour barycenters are computed as the mean of all LV contour points
% in a slice

for s = 1:S
    if ~isnan(SEG.EndoX(1,1,s)) 
        X_avgs = 0.5*mean(SEG.EpiX + SEG.EndoX);
        Y_avgs = 0.5*mean(SEG.EpiY + SEG.EndoY);
    else
        X_avgs = mean(SEG.EpiX);
        Y_avgs = mean(SEG.EpiY);
    end
end

SEG_shift = SEG;
SEG_shift.isFullTemporal = 1;

for n=1:N

    x = X_avgs(1, n, :);
    y = Y_avgs(1, n, :);
    
    % Computing least squares linear regression of barycenters for both 
    % coordinates X and Y.
    
    lmX = LinearModel.fit(zEndo, x(:));
    lmY = LinearModel.fit(zEndo, y(:));

    % estX linear least squares estimation of barycenter X coordinate
    
    estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEndo;
    estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEndo;
    
    % Shifting each segment contour so that all barycenters are located
    % on the regression lines for both X and Y coordinates.
    
    for s=1:S
        
        shiftX = x(:) - estX(s);
        shiftY = y(:) - estY(s);
        SEG_shift.EndoX(:, n, s) = SEG.EndoX(:, n, s) - shiftX(s);
        SEG_shift.EndoY(:, n, s) = SEG.EndoY(:, n, s) - shiftY(s);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Finding X and Y coordinates of pixels with scars
        [X_scar, Y_scar] = find(SEG.Scar.Result(:, :, s));
        % Scar pixels, if present in the slice, shall be shifted
        if sum(size(X_scar)) > 1
            % Calculating new scar pixels' positions
            X_scar = abs(round(X_scar - shiftX(s)));
            Y_scar = abs(round(Y_scar - shiftY(s)));
            dims = size(SEG_shift.Scar.Result(:,:, s));
            % Providing linear indices
            ind = sub2ind(dims, X_scar, Y_scar);
            U = zeros(dims);
            % Creating new pixel matrix
            U(ind) = 1;
            SEG_shift.Scar.Result(:,:, s) = U;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

for n = 1:N
    
    %x = X_avgs(1, n, :);
    %y = Y_avgs(1, n, :);
    
    % Computing least squares linear regression of barycenters for both 
    % coordinates X and Y.
    
    lmX = LinearModel.fit(zEpi, x(:));
    lmY = LinearModel.fit(zEpi, y(:));
    
    % estX linear least squares estimation of barycenter X coordinate
    
    estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zEpi;
    estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zEpi;
    
    % Shifting each segment contour so that all barycenters are located
    % on the regression lines for both X and Y coordinates.
    
    for s=1:SEpi
        
        shiftX = x(:) - estX(s);
        shiftY = y(:) - estY(s);
        
        SEG_shift.EpiX(:, n, s) = SEG.EpiX(:, n, s) - shiftX(s);
        SEG_shift.EpiY(:, n, s) = SEG.EpiY(:, n, s) - shiftY(s);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RV calignment (if included)
if RVyes == 1
    for n = 1:N
        
        %??
        %x = XRV_avgs(1, n, :);
        %y = YRV_avgs(1, n, :);
        
       % x = X_avgs(1, n, :);
       % y = Y_avgs(1, n, :);

        % Computing least squares linear regression of barycenters for both 
        % coordinates X and Y.

        lmX = LinearModel.fit(zRV, x(:));
        lmY = LinearModel.fit(zRV, y(:));

        % estX linear least squares estimation of barycenter X coordinate

        estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zRV;
        estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zRV;

        % Shifting each segment contour so that all barycenters are located
        % on the regression lines for both X and Y coordinates.

        for s=1:SRV

            shiftX = x(:) - estX(s);
            shiftY = y(:) - estY(s);

            if SEG_shift.isFullTemporal == 1
                if n == SEG.EDT || n == SEG.EST
                    SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s) - shiftX(s);
                    SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s) - shiftY(s);
                end
            else
                SEG_shift.RVEndoX(:, n, s) = SEG.RVEndoX(:, n, s) - shiftX(s);
                SEG_shift.RVEndoY(:, n, s) = SEG.RVEndoY(:, n, s) - shiftY(s);
            end
        end
    end
    for n = 1:N
        %x = XRV_avgs(1, n, :);
        %y = YRV_avgs(1, n, :);
       % x = X_avgs(1, n, :);
       % y = Y_avgs(1, n, :);

        % Computing least squares linear regression of barycenters for both 
        % coordinates X and Y.

        lmX = LinearModel.fit(zRVEpi, x(:));
        lmY = LinearModel.fit(zRVEpi, y(:));

        % estX linear least squares estimation of barycenter X coordinate

        estX = lmX.Coefficients.Estimate(1) + lmX.Coefficients.Estimate(2)*zRVEpi;
        estY = lmY.Coefficients.Estimate(1) + lmY.Coefficients.Estimate(2)*zRVEpi;

        % Shifting each segment contour so that all barycenters are located
        % on the regression lines for both X and Y coordinates.
        for s=1:SRVEpi

            shiftX = x(:) - estX(s);
            shiftY = y(:) - estY(s);

            if SEG_shift.isFullTemporal == 1
                if n == SEG.EDT || n == SEG.EST
                    SEG_shift.RVEpiX(:, n, s) = SEG.RVEpiX(:, n, s) - shiftX(s);
                    SEG_shift.RVEpiY(:, n, s) = SEG.RVEpiY(:, n, s) - shiftY(s);
                end
            else
                SEG_shift.RVEpiX(:, n, s) = SEG.RVEpiX(:, n, s) - shiftX(s);
                SEG_shift.RVEpiY(:, n, s) = SEG.RVEpiY(:, n, s) - shiftY(s);
            end
        end
    end    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleaning the data

i = 1;
for s = 1:S
    if s > 1
        if ~isnan(endo(k,1))
            i = i+1;
        end
    end

    for k = 1:K
        EndoX(:,:)=SEG_shift.EndoX(:,:,s);
        EndoY(:,:)=SEG_shift.EndoY(:,:,s); 
        endo = sum(EndoX,2);
        % Remove NaN values in the array
        if ~isnan(endo(k,1)) 
            tmp1(k,:) = EndoX(k,:);
            tmp2(k,:) = EndoY(k,:);
            for n = 1:N
                EndoXnew(k,n,i) = tmp1(k,n);
                EndoYnew(k,n,i) = tmp2(k,n);
            end
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
        EpiX(:,:)=SEG_shift.EpiX(:,:,s);
        EpiY(:,:)=SEG_shift.EpiY(:,:,s); 
        epi = sum(EpiX,2);
        % Remove NaN values in the array
        if ~isnan(epi(k,1)) 
            tmp1(k,:) = EpiX(k,:);
            tmp2(k,:) = EpiY(k,:);
            for n = 1:NEpi
                EpiXnew(k,n,i) = tmp1(k,n);
                EpiYnew(k,n,i) = tmp2(k,n);
            end
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
        RVX(:,:)=SEG_shift.RVEndoX(:,1,s);
        RVY(:,:)=SEG_shift.RVEndoY(:,1,s); 
        rv = sum(RVX,2);
        % Remove NaN values in the array
        if ~isnan(rv(k,1)) 
            tmp1(k,:) = RVX(k,:);
            tmp2(k,:) = RVY(k,:);
            for n = 1:NRV
                RVEndoXnew(k,n,i) = tmp1(k,n);
                RVEndoYnew(k,n,i) = tmp2(k,n);
            end
        end
    end
end

i = 1;
for s = 1:SRVEpi
    if s > 1
        if ~isnan(rv(k,1))
            i = i+1;
        end
    end
    for k = 1:KRVEpi
        RVX(:,:)=SEG_shift.RVEpiX(:,1,s);
        RVY(:,:)=SEG_shift.RVEpiY(:,1,s); 
        rv = sum(RVX,2);
        % Remove NaN values in the array
        if ~isnan(rv(k,1)) 
            tmp1(k,:) = RVX(k,:);
            tmp2(k,:) = RVY(k,:);
            for n = 1:NRV
                RVEpiXnew(k,n,i) = tmp1(k,n);
                RVEpiYnew(k,n,i) = tmp2(k,n);
            end
        end
    end
end

SEG_shift.EndoXnew = EndoXnew;
SEG_shift.EndoYnew = EndoYnew;
SEG_shift.EpiXnew = EpiXnew;
SEG_shift.EpiYnew = EpiYnew;
SEG_shift.RVEndoXnew = RVEndoXnew;
SEG_shift.RVEndoYnew = RVEndoYnew;
SEG_shift.RVEpiXnew = RVEpiXnew;
SEG_shift.RVEpiYnew = RVEpiYnew;

end
