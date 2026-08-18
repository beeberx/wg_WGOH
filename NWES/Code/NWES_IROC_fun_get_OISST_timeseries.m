function [SST,SST_time,sellon,sellat] = NWES_IROC_fun_get_OISST_timeseries(data_folder,time_choice,lon_choice,lat_choice)
% function fun_get_OISST_timeseries
%
% Extract time series of OI SST data from NOAA OI SST Hi Res product.
% Requires most up to date netcdf files to be saved in data_folder
% 
%
%
% USE:
%       [SST,time,lon,lat] = fun_get_OISST_timeseries(data_folder,time_choice,lon_choice,lat_choice)
%
% INPUT:
%       time_choice   = start and end time for field (matlab datenum format)
%       lon_choice    = western & eastern extent of longitude for field [-180 180]
%       lat_choice    = southern & northern extent of longitude for field [-90 90]
%
%
% OUTPUT:
%       SST (time x 1)        = monthly mean SST (deg C) from OISST
%       time                  = time stamp from datafile
%       lon                   = longitude of grid extracted (nearest long)
%       lat                   = latitude of grid extracted (nearest lat)
%
% DEPENDENCIES:
%   The function needs access to the following
%       DATA: data in NOAA format in data_folder
%
%
% EXAMPLE:
%       [SST,time,lon,lat] = fun_get_OISST_timeseries(data_folder, ...
%               [datenum(2022,1,1),floor(now)],[-25 15],[45 65]);
%

NOAA_OISSTDir = data_folder;

tim_chck = datevec(floor(now));
Years=1981:tim_chck(1);clear tim_chck
nyrs=length(Years);

%SST_time = [datenum(1981,1,1):1:datenum(2024,12,31)]';
SST_time = [sort(repmat(Years',12,1)),repmat([1:12]',nyrs,1),repmat(15,nyrs*12,1)];

idxValid = intersect(find(datenum(SST_time)>=time_choice(1)),find(datenum(SST_time)<=time_choice(2)));

SST_time = SST_time(idxValid,:);

% Loop through data year by year
for iyear=1:nyrs
    if ~ismember(Years(iyear),SST_time(:,1));continue;end
    fname = {[NOAA_OISSTDir 'sst.day.mean.' num2str(Years(iyear)) '.nc']};
    iname = {[NOAA_OISSTDir 'icec.day.mean.' num2str(Years(iyear)) '.nc']};
    if iyear==1
        lat = ncread(fname{1},'lat');
        lon = ncread(fname{1},'lon');
        lon(lon>180)=lon(lon>180)-360;
        ilat1 = intersect(find(lat>=lat_choice(1)),find(lat<=lat_choice(2)));
        ilon2 = intersect(find(lon>=0),find(lon<=lon_choice(2)));
        ilon1 = intersect(find(lon>=lon_choice(1)),find(lon<=0));

        sellon1  = double(ncread(fname{1},'lon',[ilon1(1)],[length(ilon1)]));
        sellon2  = double(ncread(fname{1},'lon',[ilon2(1)],[length(ilon2)]));
        sellon = cat(1,sellon1,sellon2);
        sellon(sellon>180)=sellon(sellon>180)-360;

        sellat  = double(ncread(fname{1},'lat',[ilat1(1)],[length(ilat1)]));
        lsmask = cat(1,ncread([NOAA_OISSTDir,'lsmask.oisst.nc'],'lsmask',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),1]),...
            ncread([NOAA_OISSTDir,'lsmask.oisst.nc'],'lsmask',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),1]));
        lsmask(lsmask==0) = NaN;lsmask = double(lsmask);

        SST = NaN.*zeros(size(lsmask,1),size(lsmask,2),size(SST_time,1));

    end
    time_orig = datevec(datenum(1800,1,1)+ncread(fname{1},'time'));

    sst_in = cat(1,ncread(fname{1},'sst',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
        ncread(fname{1},'sst',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
    sst_in = double(sst_in);
    sst_in(sst_in==-9.969209968386869e+36)=NaN;

    ice_in = cat(1,ncread(iname{1},'icec',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
        ncread(iname{1},'icec',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
    ice_in = double(ice_in);
    ice_in(ice_in==-9.969209968386869e+36)=NaN;

    icemask = abs(isnan(ice_in));
    icemask(icemask==0)=NaN;

    clear ice_in;

    if ~isempty(find(squeeze(sum(sum(isnan(sst_in),1),2)) >sum(sum(isnan(lsmask),1),2)))
        keyboard
    end

    sst_in_masked = sst_in.* icemask .*repmat(lsmask,1,1,size(sst_in,3));

    time_mon = unique(time_orig(:,[1:2]),"rows");

    for nn=1:size(time_mon,1)
        idx = intersect(find(time_orig(:,1)==time_mon(nn,1)),...
            find(time_orig(:,2)==time_mon(nn,2)));
        if length(idx)~=eomday(time_mon(nn,1),time_mon(nn,2));continue;end
        [~,~,idx2] = intersect(time_mon(nn,1:2),SST_time(:,1:2),'rows');
        mask = abs(sum(~isnan(sst_in_masked(:,:,idx)),3)>=0.66.*length(idx));
        mask(mask==0)=NaN;
        SST(:,:,idx2) = mask.*mean(sst_in_masked(:,:,idx),3,'omitnan');
        clear mask idx2 idx
    end

    clear ice_in icemask time_mon sst_in sst_in_masked
end

SST_time=datenum(SST_time);
end

