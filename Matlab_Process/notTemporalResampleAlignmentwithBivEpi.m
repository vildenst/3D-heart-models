%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% TEMPORAL RESAMPLING OF POINT CLOUD WITH TEMPORAL ALIGNMENT TO ES PHASE  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample point cloud to have 30 frames using interpolation between points
% Author - Kristin Mcleod
% SIMULA Research Laboratory
% Contact - kristin@simula.no, maciej.mar92@gmail.com
% July 2016
% Takes as input SEG_shift from sliceAlignment.m, and the number of desired 
% time points N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SEG_shift_resampled = notTemporalResampleAlignment(SEG_shift_clean,RVyes)

SEG_shift_resampled = SEG_shift_clean; % Pre-assign output
SEG_shift = SEG_shift_clean;

SEG_shift_resampled.EndoXnew = []; 
SEG_shift_resampled.EndoYnew = [];
SEG_shift_resampled.EpiXnew = []; 
SEG_shift_resampled.EpiYnew = [];

sizen=size(SEG_shift.EndoXnew);
K = sizen(1, 1); %No. of points (default 80)
S = sizen(1, 3); %No. of slices

sizenEpi=size(SEG_shift.EpiXnew);
KEpi = sizenEpi(1, 1); %No. of points (default 80)
SEpi = sizenEpi(1, 3); %No. of slices

if RVyes == 1
    SEG_shift_resampled.RVEndoXnew = []; 
    SEG_shift_resampled.RVEndoYnew = [];
    SEG_shift_resampled.RVEpiXnew = []; 
    SEG_shift_resampled.RVEpiYnew = [];
    
    sizenRV=size(SEG_shift.RVEndoXnew);
    KRV = sizenRV(1, 1); %No. of points (default 80)
    SRV = sizenRV(1, 3); %No. of slices
    
    sizenRVEpi=size(SEG_shift.RVEpiXnew);
    KRVEpi = sizenRVEpi(1, 1); %No. of points (default 80)
    SRVEpi = sizenRVEpi(1, 3); %No. of slices
end

for s = 1:S
    for k = 1:K
        EndoX(:,:)=SEG_shift.EndoXnew(:,:,s);
        EndoY(:,:)=SEG_shift.EndoYnew(:,:,s);  
        endo = sum(EndoX,2);
        % Remove NaN values in the array
        if ~isnan(endo(k,1)) 
          tmp1(k,:) = EndoX(k,:);
          tmp2(k,:) = EndoY(k,:);      
            for n = 1
                SEG_shift_resampled.EndoXnew(k,n,s) = tmp1(k,n);
                SEG_shift_resampled.EndoYnew(k,n,s) = tmp2(k,n);
            end
        end
    end
end

for s = 1:SEpi
    for k = 1:KEpi
        EpiX(:,:)=SEG_shift.EpiXnew(:,:,s);
        EpiY(:,:)=SEG_shift.EpiYnew(:,:,s); 
        epi = sum(EpiX,2);
        % Remove NaN values in the array
        if ~isnan(epi(k,1)) 
          tmp1(k,:) = EpiX(k,:);
          tmp2(k,:) = EpiY(k,:);
            for n = 1
                SEG_shift_resampled.EpiXnew(k,n,s) = tmp1(k,n);
                SEG_shift_resampled.EpiYnew(k,n,s) = tmp2(k,n);
            end
        end
    end
end
if RVyes == 1
    for s = 1:SRV
        for k = 1:KRV
            RVEndoX(:,:)=SEG_shift.RVEndoXnew(:,:,s);
            RVEndoY(:,:)=SEG_shift.RVEndoYnew(:,:,s);    
            rv = sum(RVEndoX,2);
            % Remove NaN values in the array
            if ~isnan(rv(k,1)) 
              tmp1(k,:) = RVEndoX(k,:);
              tmp2(k,:) = RVEndoY(k,:);
                for n = 1
                    SEG_shift_resampled.RVEndoXnew(k,n,s) = tmp1(k,n);
                    SEG_shift_resampled.RVEndoYnew(k,n,s) = tmp2(k,n);
                end
            end
        end
    end
    for s = 1:SRVEpi
        for k = 1:KRVEpi
            RVEpiX(:,:)=SEG_shift.RVEpiXnew(:,:,s);
            RVEpiY(:,:)=SEG_shift.RVEpiYnew(:,:,s);    
            rv = sum(RVEpiX,2);
            % Remove NaN values in the array
            if ~isnan(rv(k,1)) 
              tmp1(k,:) = RVEpiX(k,:);
              tmp2(k,:) = RVEpiY(k,:);
                for n = 1
                    SEG_shift_resampled.RVEpiXnew(k,n,s) = tmp1(k,n);
                    SEG_shift_resampled.RVEpiYnew(k,n,s) = tmp2(k,n);
                end
            end
        end
    end
end
clear EndoX EndoY EpiX EpiY RVEndoX RVEndoY RVEpiX RVEpiY tmp1 tmp2

end


