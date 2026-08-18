%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [OIClimMean,OIClimSdev,OIClimNval] = NWES_IROC_fun_get_OISST_climatology(OISST_tvec,OISST,clim_ref_period)
% sst climatology - mean and st dev in ref period

OIClimMean = NaN.*zeros(size(OISST,1),size(OISST,2),12);
OIClimSdev = NaN.*zeros(size(OISST,1),size(OISST,2),12);
OIClimNval = NaN.*zeros(size(OISST,1),size(OISST,2),12);
for mm=1:12
    ClimIdx  = intersect(intersect(find(OISST_tvec(:,1)>=clim_ref_period(1)),...
        find(OISST_tvec(:,1)<=clim_ref_period(2))),...
        find(OISST_tvec(:,2)==mm));
    mask = abs(sum(~isnan(OISST(:,:,ClimIdx)),3)>=0.6.*length(ClimIdx));
    mask(mask==0)=NaN;
    OIClimMean(:,:,mm) = mask.* mean(OISST(:,:,ClimIdx),3,'omitnan');
    OIClimSdev(:,:,mm) = mask.*std(OISST(:,:,ClimIdx),[],3,'omitnan');
    OIClimNval(:,:,mm) = sum(~isnan(OISST(:,:,ClimIdx)),3);
    
    clear ClimIdx
end
end



