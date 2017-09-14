%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%                 Change Resolution
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SEG_NewRes = ChangeReswithBivEpi(SEG)

%% Account for voxel size for SEG1
% Account for voxel size
SEG.EndoXold   = SEG.EndoXnew;
SEG.EndoYold   = SEG.EndoYnew;
SEG.EpiXold    = SEG.EpiXnew;
SEG.EpiYold    = SEG.EpiYnew;
SEG.RVEndoXold = SEG.RVEndoXnew;
SEG.RVEndoYold = SEG.RVEndoYnew;
SEG.RVEpiXold = SEG.RVEpiXnew;
SEG.RVEpiYold = SEG.RVEpiYnew;

%% Move EndoLV points
% 
sizenEndo=size(SEG.EndoXnew);
KEndo = sizenEndo(1, 1); %No. of points (default 80)
NEndo = sizenEndo(1, 2); %No. of time frames
SEndo = sizenEndo(1, 3); %No. of slices
EndoZ = repmat((1-(1:SEG.ZSize))*(SEG.SliceThickness+SEG.SliceGap),...
    [KEndo 1]);
  
% Create physical points for the fixed reference
for n = 1:NEndo
    for s = 1:SEndo
        for k = 1:KEndo
            i = (s-1)*KEndo+k;
            SEG.EndoPoints.Frame{n}(i,1) = SEG.ResolutionX *...
                SEG.EndoXnew(k,n,s);
            SEG.EndoPoints.Frame{n}(i,2) = SEG.ResolutionY *...
                SEG.EndoYnew(k,n,s); 
            SEG.EndoPoints.Frame{n}(i,3) = EndoZ(k,s);
        end
    end
end

sizenEpi=size(SEG.EpiXnew);
KEpi = sizenEpi(1, 1); %No. of points (default 80)
NEpi = sizenEpi(1, 2); %No. of time frames
SEpi = sizenEpi(1, 3); %No. of slices
EpiZ = repmat((1-(1:SEG.ZSize))*(SEG.SliceThickness+SEG.SliceGap),...
      [KEpi 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Move EpiLV points
for n = 1:NEpi
    for s = 1:SEpi
        for k = 1:KEpi
            i = (s-1)*KEpi+k;
            SEG.EpiPoints.Frame{n}(i,1) = SEG.ResolutionX *...
            SEG.EpiXnew(k,n,s);
            SEG.EpiPoints.Frame{n}(i,2) = SEG.ResolutionY *...
                SEG.EpiYnew(k,n,s);
            SEG.EpiPoints.Frame{n}(i,3) = EpiZ(k,s);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Move EndoRV points
sizenRV=size(SEG.RVEndoXnew);
KRV = sizenRV(1, 1); %No. of points (default 80)
NRV = sizenRV(1, 2); %No. of time frames
SRV = sizenRV(1, 3); %No. of slices
RVEndoZ = repmat((1-(1:SEG.ZSize))*(SEG.SliceThickness+SEG.SliceGap),...
      [KRV 1]);

for n = 1:NRV
    for s = 1:SRV
        for k = 1:KRV
            i = (s-1)*KRV+k;
            SEG.RVEndoPoints.Frame{n}(i,1) = SEG.ResolutionX *...
                SEG.RVEndoXnew(k,n,s);
            SEG.RVEndoPoints.Frame{n}(i,2) = SEG.ResolutionY *...
                SEG.RVEndoYnew(k,n,s); 
            SEG.RVEndoPoints.Frame{n}(i,3) = RVEndoZ(k,s); 
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Move EpiRV points
sizenRVEpi=size(SEG.RVEpiXnew);
KRVEpi = sizenRVEpi(1, 1); %No. of points (default 80)
NRVEpi = sizenRVEpi(1, 2); %No. of time frames
SRVEpi = sizenRVEpi(1, 3); %No. of slices
RVEpiZ = repmat((1-(1:SEG.ZSize))*(SEG.SliceThickness+SEG.SliceGap),...
      [KRVEpi 1]);

for n = 1:NRVEpi
    for s = 1:SRVEpi
        for k = 1:KRVEpi
            i = (s-1)*KRVEpi+k;
            SEG.RVEpiPoints.Frame{n}(i,1) = SEG.ResolutionX *...
                SEG.RVEpiXnew(k,n,s); 
            SEG.RVEpiPoints.Frame{n}(i,2) = SEG.ResolutionY *...
                SEG.RVEpiYnew(k,n,s);
            SEG.RVEpiPoints.Frame{n}(i,3) = RVEpiZ(k,s);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Change Res for scar
Scarmhd = [];
    initZshift = SEG.EndoPoints.Frame{1}(1,3);
    for s = 1:SEndo
        [X_scar, Y_scar] = find(SEG.Scar.Result(:, :, s));
        
        X_scar = SEG.ResolutionX * X_scar;
        Y_scar = SEG.ResolutionY * Y_scar;
        Z_scar = repmat(EndoZ(1,s),[size(X_scar),1]);
        
        Z_scar = Z_scar + initZshift;
        
        if sum(size(X_scar)) > 1
            Scartmp = [X_scar, Y_scar, Z_scar];
            Scarmhd = cat(1,Scarmhd,Scartmp);
        end
        
        SEG.ScarMhd = Scarmhd;
    end
    
SEG_NewRes = SEG;