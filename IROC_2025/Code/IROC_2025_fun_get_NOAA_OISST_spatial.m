function [SST,SST_anom,SST_norm_anom,time,lon,lat] = IROC_2025_fun_get_NOAA_OISST_spatial(varargin)
% function IROC_2025_fun_get_NOAA_OISST_spatial
%
% Extract spatial field of NOAA OISST Hi Res Sea Surface Temperature
% Dataset 
% Data from NOAA Daily Marine Heatwave Watch product
% (https://coralreefwatch.noaa.gov/product/marine_heatwave/). 
% Requires FTP download to be up to date in data_dir (optional). If
% data_dir not specified, then a GUI will ask for selecting data directory
%
% USE:
%       [SST,SST_anom,SST_norm_anom,time,lon,lat] = ...
%                   IROC_2025_fun_get_NOAA_OISST_spatial('time_extent',[739618 739982],... 
%                                     'lon_extent', [-80 30], 'lat_extent', [20 85],... 
%                                     'clim_period',[1991 2020], 'data_dir',MY_DATA_LOCATION);
%
% INPUT:
%   All input arguments are optional. For extents, all begin and end are inclusive. 
%       time_extent   = time extent for field (matlab datenum format) [floor(now)-27 floor(now)]
%       lon_extent    = western & eastern extent of longitude for field [-180 180]
%       lat_extent    = southern & northern extent of longitude for field [-90 90]
%       clim_period   = climatological period to calculate reference [1991 2020]
%       data_dir      = path to data directory
%
%
% OUTPUT:
%       SST           = spatial of SST from OISST
%       SST_anom      = spatial of SST anomaly from OISST
%       SST_norm_anom = spatial of SST anomaly from OISST
%       time          = time stamp from datafile for field
%       lon           = longitude of grid extracted
%       lat           = latitude of grid extracted
%
% WRITTEN FOR ICES WGOH BY:
%       Bee Berx, June-2026

% prepare the input parser and set default parameters
p = inputParser;
t1 = floor(now)-27;t2 = floor(now);
addOptional(p,'time_extent',[t1;t2]);
addOptional(p,'clim_period',[1991 2020]);
addOptional(p,'lon_extent',[-180 180]);
addOptional(p,'lat_extent',[-90 90]);
addOptional(p,'data_dir','');
parse(p,varargin{:});

% put the parsed input into the time, lat and lon extent variables. 
lon_extent = p.Results.lon_extent;
lat_extent = p.Results.lat_extent;
time_extent = p.Results.time_extent;
clim_period = p.Results.clim_period;

% if no data_dir is specified, then one MUST be selected.  This prompt
% generates a navigation box to set the source directory for the data.
if isempty(p.Results.data_dir)
    NOAA_SSTDir = uigetdir(pwd,'Select source directory for NOAA MHW data:');
else
    NOAA_SSTDir = p.Results.data_dir;
end
% check that valid data directory has been selected. 
if NOAA_SSTDir==0
    error('IROC_2025_fun_get_NOAA_OISST_spatial: No valid source directory set for NOAA MHW data.')
elseif ~isfolder(NOAA_SSTDir)
    error('IROC_2025_fun_get_NOAA_OISST_spatial: No valid source directory set for NOAA MHW data.')
end

% check that data directory ends in correct path separator
if NOAA_SSTDir(end)~=filesep
    NOAA_SSTDir = [NOAA_SSTDir,filesep];
end

% warn user if all defaults are being used on time, latitude and longitude
if time_extent(1)==t1 && time_extent(2)==t2 && lon_extent(1)==-180 ...
        && lon_extent(2)==180 && lat_extent(1)==-90 && lat_extent(2)==90
    warndlg({'IROC_2025_fun_get_NOAA_OISST_spatial:';'Warning Default Time, Latitude and Longitude Used'})
end

% set file names for sst and ice monthly mean files
fname = {[NOAA_SSTDir 'sst.mon.mean.nc']};
iname = {[NOAA_SSTDir 'icec.mon.mean.nc']};

% take the first file to check that can reach it 
if ~isfile(fname)
    error(['IROC_2025_fun_get_NOAA_OISST_spatial: Can''t read data file',...
        'sst.mon.mean.nc'])
end

% read in lat and lon
lat = ncread(fname{1},'lat');
lon = ncread(fname{1},'lon');
lon(lon>180)=lon(lon>180)-360;

% find index for latitude and read latitude selection
ilat1 = intersect(find(lat>=lat_extent(1)),find(lat<=lat_extent(2)));
lat  = double(ncread(fname{1},'lat',[ilat1(1)],[length(ilat1)]));

% find whether longitude straddles zero
if sign(lon_extent(1))==sign(lon_extent(2))
    lon_switch = 0;
else
    lon_switch = 1;
end
% depending on whether straddles zero, find longitude indices and read
% longitude selection 
if lon_switch
    ilon1 = intersect(find(lon>=lon_extent(1)),find(lon<=0));
    ilon2 = intersect(find(lon>=0),find(lon<=lon_extent(2)));
    sellon1  = double(ncread(fname{1},'lon',[ilon1(1)],[length(ilon1)]));
    sellon2  = double(ncread(fname{1},'lon',[ilon2(1)],[length(ilon2)]));
    sellon = cat(1,sellon1,sellon2);
else
    ilon1 = intersect(find(lon>=lon_extent(1)),find(lon<=lon_extent(2)));
    sellon  = double(ncread(fname{1},'lon',[ilon1(1)],[length(ilon1)]));
end
sellon(sellon>180)=sellon(sellon>180)-360;
lon=sellon;clear sellon

% read land mask
if lon_switch
lsmask = cat(1,ncread([NOAA_SSTDir,'lsmask.oisst.nc'],'lsmask',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),1]),...
    ncread([NOAA_SSTDir,'lsmask.oisst.nc'],'lsmask',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),1]));
else
lsmask = ncread([NOAA_SSTDir,'lsmask.oisst.nc'],'lsmask',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),1]);
end
lsmask(lsmask==0) = NaN;lsmask = double(lsmask);

% read time from sst file 
time_orig = datevec(datenum(1800,1,1)+ncread(fname{1},'time'));

% read sst from sst file and ice from ice file
if lon_switch 
    sst_in = cat(1,ncread(fname{1},'sst',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
        ncread(fname{1},'sst',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
else
    sst_in = ncread(fname{1},'sst',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]);
end
sst_in = double(sst_in);
sst_in(sst_in==-9.969209968386869e+36)=NaN;

if lon_switch
ice_in = cat(1,ncread(iname{1},'icec',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
    ncread(iname{1},'icec',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
else
ice_in = ncread(iname{1},'icec',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]);
end
ice_in = double(ice_in);
ice_in(ice_in==-9.969209968386869e+36)=NaN;

% set the ice mask
icemask = abs(isnan(ice_in));
icemask(icemask==0)=NaN;

clear ice_in;

% mask everywhere that is land or ice
sst_in_masked = sst_in.* icemask .*repmat(lsmask,1,1,size(sst_in,3));

% calculate climatology mean and standard deviation
% declare variables
ClimMean = NaN.*zeros(size(sst_in_masked,1),size(sst_in_masked,2),12);
ClimSdev = NaN.*zeros(size(sst_in_masked,1),size(sst_in_masked,2),12);
for mm=1:12
    ClimIdx  = intersect(intersect(find(time_orig(:,1)>=clim_period(1)),...
        find(time_orig(:,1)<=clim_period(2))),...
        find(time_orig(:,2)==mm));
    mask = sum(~isnan(sst_in_masked(:,:,ClimIdx)),3);
    mask(mask<25)=NaN;mask(~isnan(mask))=1;%masks out where there are less than 25 of 30 years
    ClimMean(:,:,mm) = mean(sst_in_masked(:,:,ClimIdx),3,'omitnan').*mask;
    ClimSdev(:,:,mm) = std(sst_in_masked(:,:,ClimIdx),[],3,'omitnan').*mask;
    clear ClimIdx mask
end

% calculate anomalies and standardised anomalies from climatology
Anom = NaN.*zeros(size(sst_in_masked,1),size(sst_in_masked,2),size(sst_in_masked,3));
NormAnom = NaN.*zeros(size(sst_in_masked,1),size(sst_in_masked,2),size(sst_in_masked,3));
for mm=1:12
    idxOI =  find(time_orig(:,2)==mm);
    Anom(:,:,idxOI) = sst_in_masked(:,:,idxOI) - repmat(ClimMean(:,:,mm),1,1,length(idxOI));
    NormAnom(:,:,idxOI) = (sst_in_masked(:,:,idxOI) - repmat(ClimMean(:,:,mm),1,1,length(idxOI)))./ ...
        repmat(ClimSdev(:,:,mm),1,1,length(idxOI));
end

idxValid = intersect(find(datenum(time_orig)>=time_extent(1)),find(datenum(time_orig)<=time_extent(2)));

time = datenum(time_orig(idxValid,:));
SST = sst_in_masked(:,:,idxValid);
SST_anom = Anom(:,:,idxValid);
SST_norm_anom = NormAnom(:,:,idxValid);

end