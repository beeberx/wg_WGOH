function [MHW_cat,MHW_time,MHW_lon,MHW_lat] = IROC_2025_fun_get_NOAA_MHW_spatial(varargin)
% function IROC_2025_fun_get_NOAA_MHW_spatial
%
% Extract spatial field of Marine Heatwave Category.  
% Data from NOAA Daily Marine Heatwave Watch product
% (https://coralreefwatch.noaa.gov/product/marine_heatwave/). 
% Requires FTP download to be up to date in data_dir (optional). If
% data_dir not specified, then a GUI will ask for selecting data directory
%
% USE:
%       [MHW_cat,MHW_time,MHW_lon,MHW_lat] = IROC_2025_fun_get_NOAA_MHW_spatial('time_extent',[739618 739982],...
%                                               'lon_extent', [-80 30], 'lat_extent', [20 85],... 
%                                               'data_dir',MY_DATA_LOCATION);
%
% INPUT:
%   All input arguments are optional. For extents, all begin and end are inclusive. 
%       time_extent   = time extent for field (matlab datenum format) [floor(now)-27 floor(now)]
%       lon_extent    = western & eastern extent of longitude for field [-180 180]
%       lat_extent    = southern & northern extent of longitude for field [-90 90]
%       data_dir      = path to data directory
%
%
% OUTPUT:
%       MHW_cat       = spatial of heatwave category from NOAA Marine Heatwave Watch product
%       MHW_time      = time stamp from datafile for field
%       MHW_lon       = longitude of grid extracted
%       MHW_lat       = latitude of grid extracted
%
% WRITTEN BY:
%       Bee Berx, June-2023
%
% MODIFIED FOR ICES WGOH BY:
%       Bee Berx, June-2026

% prepare the input parser and set default parameters
p = inputParser;
t1 = floor(now)-27;t2 = floor(now);
addOptional(p,'time_extent',[t1;t2]);
addOptional(p,'lon_extent',[-180 180]);
addOptional(p,'lat_extent',[-90 90]);
addOptional(p,'data_dir','');
parse(p,varargin{:});

% put the parsed input into the time, lat and lon extent variables. 
lon_extent = p.Results.lon_extent;
lat_extent = p.Results.lat_extent;
time_extent = p.Results.time_extent;

% if no data_dir is specified, then one MUST be selected.  This prompt
% generates a navigation box to set the source directory for the data.
if isempty(p.Results.data_dir)
    NOAA_HeatWaveDir = uigetdir(pwd,'Select source directory for NOAA MHW data:');
else
    NOAA_HeatWaveDir = p.Results.data_dir;
end
% check that valid data directory has been selected. 
if NOAA_HeatWaveDir==0
    error('IROC_2025_fun_get_NOAA_MHW_spatial: No valid source directory set for NOAA MHW data.')
elseif ~isfolder(NOAA_HeatWaveDir)
    error('IROC_2025_fun_get_NOAA_MHW_spatial: No valid source directory set for NOAA MHW data.')
end

% check that data directory ends in correct path separator
if NOAA_HeatWaveDir(end)~=filesep
    NOAA_HeatWaveDir = [NOAA_HeatWaveDir,filesep];
end

% warn user if all defaults are being used on time, latitude and longitude
if time_extent(1)==t1 && time_extent(2)==t2 && lon_extent(1)==-180 ...
        && lon_extent(2)==180 && lat_extent(1)==-90 && lat_extent(2)==90
    warndlg({'IROC_2025_fun_get_NOAA_MHW_spatial:';'Warning Default Time, Latitude and Longitude Used'})
end

% take the first file to check that can reach it 
fname = [NOAA_HeatWaveDir datestr(time_extent(1),'yyyy') ...
    '\noaa-crw_mhw_v1.0.1_category_' datestr(time_extent(1),'yyyymmdd') '.nc'];
if ~isfile(fname)
    error(['IROC_2025_fun_get_NOAA_MHW_spatial: Can''t read first time field file',...
        'noaa-crw_mhw_v1.0.1_category_' datestr(time_extent(1),'yyyymmdd') '.nc'])
end

% then use first file to read and set boundaries
MHW_lat = ncread(fname,'lat');
MHW_lon = ncread(fname,'lon');
idxlon = intersect(find(MHW_lon>=lon_extent(1)),find(MHW_lon<=lon_extent(2)));
idxlat = intersect(find(MHW_lat>=lat_extent(1)),find(MHW_lat<=lat_extent(2)));
clear MHW_lon MHW_lat
MHW_lon  = ncread(fname,'lon',[min(idxlon)],[max(idxlon)-min(idxlon)+1]);
MHW_lat  = ncread(fname,'lat',[min(idxlat)],[max(idxlat)-min(idxlat)+1]);
clear fname

% set a vector with input times
input_mhw_time = time_extent(1):time_extent(2);

% initiate first field
MHW_time = NaN.*input_mhw_time(1);
MHW_cat = NaN.*zeros(length(MHW_lon),length(MHW_lat),1);
% step through the individual time fields and go get the extent of lat/lon grid
for ff=1:length(input_mhw_time)
    fname = [NOAA_HeatWaveDir datestr(input_mhw_time(ff),'yyyy') ...
        '\noaa-crw_mhw_v1.0.1_category_' datestr(input_mhw_time(ff),'yyyymmdd') '.nc'];
    if ~exist(fname,'file')
        disp(['MHW Category File does not exist:',...
            'noaa-crw_mhw_v1.0.1_category_' datestr(time_extent(1),'yyyymmdd') '.nc'])
        continue
    end
    heatwave_tim = (double(ncread(fname,'time'))/(24*3600))+datenum(1981,1,1,0,0,0);
    heatwave_cat = ncread(fname,'heatwave_category',[min(idxlon),min(idxlat),1],[max(idxlon)-min(idxlon)+1,max(idxlat)-min(idxlat)+1,1]);
    mask = ncread(fname,'mask',[min(idxlon),min(idxlat),1],[max(idxlon)-min(idxlon)+1,max(idxlat)-min(idxlat)+1,1]);
    heatwave_cat(mask~=0)=NaN;
    if ff==1
        MHW_cat(:,:,1)=heatwave_cat;
        MHW_time(1)=heatwave_tim;
    else
        MHW_cat=cat(3,MHW_cat,heatwave_cat);
        MHW_time=cat(1,MHW_time,heatwave_tim);
    end
    clear heatwave_cat mask fname heatwave_tim
end; clear ff