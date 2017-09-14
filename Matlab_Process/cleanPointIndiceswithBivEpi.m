%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                         CLEAN POINT INDEXING                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean point indexing to make nicer meshes
% Author - Kristin Mcleod (following from Eric Davennes work)
% SIMULA Research Laboratory
% Contact - kristin@simula.no, maciej.mar92@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  SEG_shift_clean = cleanPointIndiceswithBivEpi(SEG_shift,RVyes,IsFullTemporal)
%% Get size info
SEG_shift_clean = SEG_shift;

sizen = size(SEG_shift.EndoXnew);
K = sizen(1,1); %number of points in a segment contour
N = sizen(1,2); %number of frames
S = sizen(1,3); %number of slices

sizenEpi = size(SEG_shift.EpiXnew);
KEpi = sizenEpi(1,1); %number of points in a segment contour
NEpi = sizenEpi(1,2); %number of frames
SEpi = sizenEpi(1,3); %number of slices

LVdist21Endo = zeros(1,K);
LVdist21Epi = zeros(1,KEpi);

if RVyes == 1
    sizenRV = size(SEG_shift.RVEndoXnew);
    KRV = sizenRV(1,1); %number of points in a segment contour
    NRV = sizenRV(1,2);
    SRV = sizenRV(1,3); %number of slices
   
    sizenRVEpi = size(SEG_shift.RVEpiXnew);
    KRVEpi = sizenRVEpi(1,1); %number of points in a segment contour
    NRVEpi = sizenRVEpi(1,2);
    SRVEpi = sizenRVEpi(1,3); %number of slices 
      
    RVdist21Endo = zeros(1,KRV);
    RVdist21Epi = zeros(1,KRVEpi);
    
%      RVEndoZ = repmat((1-(1:SRV))*(SEG_shift.SliceThickness+SEG_shift.SliceGap),...
%           [KRV 1]);
%       RVEpiZ = repmat((1-(1:SRVEpi))*(SEG_shift.SliceThickness+SEG_shift.SliceGap),...
%           [KRVEpi 1]);
end

% SEG_shift_clean.EndoXnew = SEG_shift.EndoXnew;
% SEG_shift_clean.EndoYnew = SEG_shift.EndoYnew;
% SEG_shift_clean.EpiXnew = SEG_shift.EpiX;
% SEG_shift_clean.EpiYnew = SEG_shift.EpiY;

%% Compute squared distances and rearrange points
%if IsFullTemporal == 1

    % EndoLV
    refEndo = 1;
    
    for n=1:N
    %     if n>1
    %         for j = 1:K
    %             TestIndPrevFrameEndo(j) = (SEG_shift.EndoX(j, n, s) - SEG_shift.EndoX(refEndo, n-1, s))^2 + (SEG_shift.EndoY(j, n, s) - SEG_shift.EndoY(refEndo, n-1, s))^2;
    %         end
    %         [YTestEndo , indTestEndo] = min(TestIndPrevFrameEndo);
    %         refEndo = indTestEndo;
    %     end
        for s=S:-1:2
            
            for k=1:K
                LVdist21Endo(k) = (SEG_shift.EndoXnew(refEndo, n, s) - ...
                    SEG_shift.EndoXnew(k, n, s - 1))^2 + ...
                    (SEG_shift.EndoYnew(refEndo, n, s) - ...
                    SEG_shift.EndoYnew(k, n, s - 1))^2;
            end
            
            [~, indEndo] = min(LVdist21Endo);
            indexEndo = indEndo;
            refEndo = indEndo;
            
            for l=1:K
                indexEndo = mod(indexEndo, K) + 1;
                SEG_shift_clean.EndoXnew(l, n, s-1) = ...
                    SEG_shift.EndoXnew(indexEndo, n, s-1);
                SEG_shift_clean.EndoYnew(l, n, s-1) = ...
                    SEG_shift.EndoYnew(indexEndo, n, s-1);
            end    
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % EpiLV
    refEpi = 1;
    for n=1:NEpi
    %     if n>1
    %         for j = 1:K
    %             TestIndPrevFrameEpi(j) = (SEG_shift.EpiX(j, n, s) - SEG_shift.EpiX(refEpi, n-1, s))^2 + (SEG_shift.EpiY(j, n, s) - SEG_shift.EpiY(refEpi, n-1, s))^2;
    %         end
    %         [YTestEpi , indTestEpi] = min(TestIndPrevFrameEpi);
    %         refEpi = indTestEpi;
    %     end
        for s=SEpi:-1:2
            
            for k=1:KEpi
                LVdist21Epi(k) = (SEG_shift.EpiXnew(refEpi, n, s) -...
                    SEG_shift.EpiXnew(k, n, s - 1))^2 + ...
                    (SEG_shift.EpiYnew(refEpi, n, s) - ...
                    SEG_shift.EpiYnew(k, n, s - 1))^2;
            end
            
            [~, indEpi] = min(LVdist21Epi);
            indexEpi = indEpi;
            refEpi = indEpi;
            
            for l=1:KEpi
                indexEpi = mod(indexEpi, K) + 1;
                SEG_shift_clean.EpiXnew(l, n, s-1) = ...
                    SEG_shift.EpiXnew(indexEpi, n, s-1);
                SEG_shift_clean.EpiYnew(l, n, s-1) = ...
                    SEG_shift.EpiYnew(indexEpi, n, s-1);
            end    
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % To account for the irregular shape of the RV, start the cleaning from the
    % % centre and adjust indexing above then below
    % halfSliceRVED = round(SRV/2);
    % %RV ED
    % refRVED = 1;
    % for s=halfSliceRVED:-1:2
    %     for k=1:KRV
    %         RVdist21EndoED(k) = (SEG_shift_resampled.RVEndoXED(refRVED, s) - SEG_shift_resampled.RVEndoXED(k, s-1))^2 + (SEG_shift_resampled.RVEndoYED(refRVED, s) - SEG_shift_resampled.RVEndoYED(k, s-1))^2;
    %     end
    %     [YRVED , indRVED] = min(RVdist21EndoED);
    %     indexRVED = indRVED;
    %     refRVED = indRVED; 
    %     for l=1:KRV
    %         SEG_shift_clean.RVEndoXED(l, s-1) = SEG_shift_resampled.RVEndoXED(indexRVED, s-1);
    %         SEG_shift_clean.RVEndoYED(l, s-1) = SEG_shift_resampled.RVEndoYED(indexRVED, s-1);
    %         indexRVED = mod(indexRVED,KRV) + 1;
    %     end
    % end
    % refRVED = 1;
    % for s=halfSliceRVED:SRV-1
    %     for k=1:KRV
    %         RVdist21EndoED(k) = (SEG_shift_resampled.RVEndoXED(refRVED, s) - SEG_shift_resampled.RVEndoXED(k, s+1))^2 + (SEG_shift_resampled.RVEndoYED(refRVED, s) - SEG_shift_resampled.RVEndoYED(k, s+1))^2;
    %     end
    %     [YRVED , indRVED] = min(RVdist21EndoED);
    %     indexRVED = indRVED;
    %     refRVED = indRVED; 
    %     for l=1:KRV
    %         SEG_shift_clean.RVEndoXED(l, s+1) = SEG_shift_resampled.RVEndoXED(indexRVED, s+1);
    %         SEG_shift_clean.RVEndoYED(l, s+1) = SEG_shift_resampled.RVEndoYED(indexRVED, s+1);
    %         indexRVED = mod(indexRVED,KRV) + 1;
    %     end
    % end

    
    % EndoRV 
    if RVyes ==1
        refRV = 1;
        for n = 1:NRV
        %     if n>1
        %         for j = 1:K
        %             TestIndPrevFrameRV(j) = (SEG_shift.RVEndoX(j, n, s) - SEG_shift.RVEndoX(refRV, n-1, s))^2 + (SEG_shift.RVEndoY(j, n, s) - SEG_shift.RVEndoY(refRV, n-1, s))^2;
        %         end
        %         [YTestRV , indTestRV] = min(TestIndPrevFrameRV);
        %         refRV = indTestRV;
        %     end
            for s=SRV:-1:2
                
                for k=1:KRV
                    RVdist21Endo(k) = (SEG_shift.RVEndoXnew(refRV, n, s) - ...
                        SEG_shift.RVEndoXnew(k, n, s-1))^2 + ...
                        (SEG_shift.RVEndoYnew(refRV, n, s) - ...
                        SEG_shift.RVEndoYnew(k, n, s-1))^2;
                end
                
                [~, indRV] = min(RVdist21Endo);
                indexRV = indRV;
                refRV = indRV;
                
                for l=1:KRV
                    SEG_shift_clean.RVEndoXnew(l, n, s-1) = ...
                        SEG_shift.RVEndoXnew(indexRV, n, s-1);
                    SEG_shift_clean.RVEndoYnew(l, n, s-1) = ...
                        SEG_shift.RVEndoYnew(indexRV, n, s-1);
                    indexRV = mod(indexRV,KRV) + 1;
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % EpiRV
        
        refRVEpi = 1;
        for n = 1:NRVEpi
        %     if n>1
        %         for j = 1:K
        %             TestIndPrevFrameRV(j) = (SEG_shift.RVEndoX(j, n, s) - SEG_shift.RVEndoX(refRV, n-1, s))^2 + (SEG_shift.RVEndoY(j, n, s) - SEG_shift.RVEndoY(refRV, n-1, s))^2;
        %         end
        %         [YTestRV , indTestRV] = min(TestIndPrevFrameRV);
        %         refRV = indTestRV;
        %     end
            for s=SRVEpi:-1:2
                
                for k=1:KRVEpi
                    RVdist21Epi(k) = (SEG_shift.RVEpiXnew(refRVEpi, n, s) - ...
                        SEG_shift.RVEpiXnew(k, n, s-1))^2 + ...
                        (SEG_shift.RVEpiYnew(refRVEpi, n, s) - ...
                        SEG_shift.RVEpiYnew(k, n, s-1))^2;
                end
                
                [~, indRVEpi] = min(RVdist21Epi);
                indexRVEpi = indRVEpi;
                refRVEpi = indRVEpi;
                
                for l=1:KRVEpi
                    SEG_shift_clean.RVEpiXnew(l, n, s-1) = ...
                        SEG_shift.RVEpiXnew(indexRVEpi, n, s-1);
                    SEG_shift_clean.RVEpiYnew(l, n, s-1) = ...
                        SEG_shift.RVEpiYnew(indexRVEpi, n, s-1);
                    indexRVEpi = mod(indexRVEpi,KRVEpi) + 1;
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    % %RV ES
    % refRVES = 1;
    % for s=SRVES:-1:2
    %     for k=1:KRVES
    %         RVdist21EndoES(k) = (SEG_shift_resampled.RVEndoXES(refRVES, s) - SEG_shift_resampled.RVEndoXES(k, s-1))^2 + (SEG_shift_resampled.RVEndoYES(refRVES, s) - SEG_shift_resampled.RVEndoYES(k, s-1))^2;
    %     end
    %     [YRVES , indRVES] = min(RVdist21EndoES);
    %     indexRVES = indRVES;
    %     refRVES = indRVES; 
    %     for l=1:KRVES
    %         SEG_shift_clean.RVEndoXES(l, s-1) = SEG_shift_resampled.RVEndoXES(indexRVES, s-1);
    %         SEG_shift_clean.RVEndoYES(l, s-1) = SEG_shift_resampled.RVEndoYES(indexRVES, s-1);
    %         indexRVES = mod(indexRVES,KRVES) + 1;
    %     end
    % end

    % n = SEG_shift_clean.EDT;
    % for s = 1:SRV
    %     for k = 1:KRV
    %         i = (s-1)*KRV+k;
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG_shift_clean.RVEndoXED(k,s);']);
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG_shift_clean.RVEndoYED(k,s);']);
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ(k,s);']);
    %     end
    % end
    % n = SEG_shift_clean.EST;
    % for s = 1:SRV
    %     for k = 1:KRV
    %         i = (s-1)*KRV+k;
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG_shift_clean.RVEndoXES(k,s);']);
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG_shift_clean.RVEndoYES(k,s);']);
    %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZES(k,s);']);
    %     end
    % end
% else
%     refEndo = 1;
%     % LV Endo
%     for n=1
%     %     if n>1
%     %         for j = 1:K
%     %             TestIndPrevFrameEndo(j) = (SEG_shift.EndoX(j, n, s) - SEG_shift.EndoX(refEndo, n-1, s))^2 + (SEG_shift.EndoY(j, n, s) - SEG_shift.EndoY(refEndo, n-1, s))^2;
%     %         end
%     %         [YTestEndo , indTestEndo] = min(TestIndPrevFrameEndo);
%     %         refEndo = indTestEndo;
%     %     end
%         for s=S:-1:2
%             for k=1:K
%                 LVdist21Endo(k) = (SEG_shift.EndoX(refEndo, n, s) - SEG_shift.EndoX(k, n, s - 1))^2 + (SEG_shift.EndoY(refEndo, n, s) - SEG_shift.EndoY(k, n, s - 1))^2;
%             end
%             [YEndo , indEndo] = min(LVdist21Endo);
%             indexEndo = indEndo;
%             refEndo = indEndo;
%             for l=1:K
%                 indexEndo = mod(indexEndo, K) + 1;
%                 SEG_shift_clean.EndoXnew(l, n, s-1) = SEG_shift.EndoX(indexEndo, n, s-1);
%                 SEG_shift_clean.EndoYnew(l, n, s-1) = SEG_shift.EndoY(indexEndo, n, s-1);
%             end    
%         end
%     end
% 
%     % LV Epi
%     refEpi = 1;
%     for n=1
%     %     if n>1
%     %         for j = 1:K
%     %             TestIndPrevFrameEpi(j) = (SEG_shift.EpiX(j, n, s) - SEG_shift.EpiX(refEpi, n-1, s))^2 + (SEG_shift.EpiY(j, n, s) - SEG_shift.EpiY(refEpi, n-1, s))^2;
%     %         end
%     %         [YTestEpi , indTestEpi] = min(TestIndPrevFrameEpi);
%     %         refEpi = indTestEpi;
%     %     end
%         for s=SEpi:-1:2
%             for k=1:KEpi
%                 LVdist21Epi(k) = (SEG_shift.EpiX(refEpi, n, s) - SEG_shift.EpiX(k, n, s - 1))^2 + (SEG_shift.EpiY(refEpi, n, s) - SEG_shift.EpiY(k, n, s - 1))^2;
%             end
%             [YEpi , indEpi] = min(LVdist21Epi);
%             indexEpi = indEpi;
%             refEpi = indEpi;
%             for l=1:KEpi
%                 indexEpi = mod(indexEpi, K) + 1;
%                 SEG_shift_clean.EpiXnew(l, n, s-1) = SEG_shift.EpiX(indexEpi, n, s-1);
%                 SEG_shift_clean.EpiYnew(l, n, s-1) = SEG_shift.EpiY(indexEpi, n, s-1);
%             end    
%         end
%     end
% 
%     % % To account for the irregular shape of the RV, start the cleaning from the
%     % % centre and adjust indexing above then below
%     % halfSliceRVED = round(SRV/2);
%     % %RV ED
%     % refRVED = 1;
%     % for s=halfSliceRVED:-1:2
%     %     for k=1:KRV
%     %         RVdist21EndoED(k) = (SEG_shift_resampled.RVEndoXED(refRVED, s) - SEG_shift_resampled.RVEndoXED(k, s-1))^2 + (SEG_shift_resampled.RVEndoYED(refRVED, s) - SEG_shift_resampled.RVEndoYED(k, s-1))^2;
%     %     end
%     %     [YRVED , indRVED] = min(RVdist21EndoED);
%     %     indexRVED = indRVED;
%     %     refRVED = indRVED; 
%     %     for l=1:KRV
%     %         SEG_shift_clean.RVEndoXED(l, s-1) = SEG_shift_resampled.RVEndoXED(indexRVED, s-1);
%     %         SEG_shift_clean.RVEndoYED(l, s-1) = SEG_shift_resampled.RVEndoYED(indexRVED, s-1);
%     %         indexRVED = mod(indexRVED,KRV) + 1;
%     %     end
%     % end
%     % refRVED = 1;
%     % for s=halfSliceRVED:SRV-1
%     %     for k=1:KRV
%     %         RVdist21EndoED(k) = (SEG_shift_resampled.RVEndoXED(refRVED, s) - SEG_shift_resampled.RVEndoXED(k, s+1))^2 + (SEG_shift_resampled.RVEndoYED(refRVED, s) - SEG_shift_resampled.RVEndoYED(k, s+1))^2;
%     %     end
%     %     [YRVED , indRVED] = min(RVdist21EndoED);
%     %     indexRVED = indRVED;
%     %     refRVED = indRVED; 
%     %     for l=1:KRV
%     %         SEG_shift_clean.RVEndoXED(l, s+1) = SEG_shift_resampled.RVEndoXED(indexRVED, s+1);
%     %         SEG_shift_clean.RVEndoYED(l, s+1) = SEG_shift_resampled.RVEndoYED(indexRVED, s+1);
%     %         indexRVED = mod(indexRVED,KRV) + 1;
%     %     end
%     % end
% 
%     %RV 
%     if RVyes ==1
%         refRV = 1;
%         for n = 1
%         %     if n>1
%         %         for j = 1:K
%         %             TestIndPrevFrameRV(j) = (SEG_shift.RVEndoX(j, n, s) - SEG_shift.RVEndoX(refRV, n-1, s))^2 + (SEG_shift.RVEndoY(j, n, s) - SEG_shift.RVEndoY(refRV, n-1, s))^2;
%         %         end
%         %         [YTestRV , indTestRV] = min(TestIndPrevFrameRV);
%         %         refRV = indTestRV;
%         %     end
%             for s=SRV:-1:2
%                 for k=1:KRV
%                     RVdist21Endo(k) = (SEG_shift.RVEndoX(refRV, n, s) - SEG_shift.RVEndoX(k, n, s-1))^2 + (SEG_shift.RVEndoY(refRV, n, s) - SEG_shift.RVEndoY(k, n, s-1))^2;
%                 end
%                 [YRV , indRV] = min(RVdist21Endo);
%                 indexRV = indRV;
%                 refRV = indRV;
%                 for l=1:KRV
%                     SEG_shift_clean.RVEndoXnew(l, n, s-1) = SEG_shift.RVEndoX(indexRV, n, s-1);
%                     SEG_shift_clean.RVEndoYnew(l, n, s-1) = SEG_shift.RVEndoY(indexRV, n, s-1);
%                     indexRV = mod(indexRV,KRV) + 1;
%                 end
%             end
%         end
%     end
%     % %RV ES
%     % refRVES = 1;
%     % for s=SRVES:-1:2
%     %     for k=1:KRVES
%     %         RVdist21EndoES(k) = (SEG_shift_resampled.RVEndoXES(refRVES, s) - SEG_shift_resampled.RVEndoXES(k, s-1))^2 + (SEG_shift_resampled.RVEndoYES(refRVES, s) - SEG_shift_resampled.RVEndoYES(k, s-1))^2;
%     %     end
%     %     [YRVES , indRVES] = min(RVdist21EndoES);
%     %     indexRVES = indRVES;
%     %     refRVES = indRVES; 
%     %     for l=1:KRVES
%     %         SEG_shift_clean.RVEndoXES(l, s-1) = SEG_shift_resampled.RVEndoXES(indexRVES, s-1);
%     %         SEG_shift_clean.RVEndoYES(l, s-1) = SEG_shift_resampled.RVEndoYES(indexRVES, s-1);
%     %         indexRVES = mod(indexRVES,KRVES) + 1;
%     %     end
%     % end
% 
%     % n = SEG_shift_clean.EDT;
%     % for s = 1:SRV
%     %     for k = 1:KRV
%     %         i = (s-1)*KRV+k;
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG_shift_clean.RVEndoXED(k,s);']);
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG_shift_clean.RVEndoYED(k,s);']);
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZ(k,s);']);
%     %     end
%     % end
%     % n = SEG_shift_clean.EST;
%     % for s = 1:SRV
%     %     for k = 1:KRV
%     %         i = (s-1)*KRV+k;
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,1) = SEG_shift_clean.RVEndoXES(k,s);']);
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,2) = SEG_shift_clean.RVEndoYES(k,s);']);
%     %         eval(['SEG_shift_clean.RVEndoPoints.Frame' int2str(n) '(i,3) = RVEndoZES(k,s);']);
%     %     end
%     % end
%end

clear n s k j  i N S K NEpi SEpi KEpi SRV KRV SRVES KRVES YRV YEpi YEndo...
    YTestEpi YTestEndo YTestRV
end
