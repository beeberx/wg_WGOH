% script to look up which time series are in which regions both IROC
% regions and ICES EcoRegions
clear all;close all;clc;

IROC_metaData = readtable('IROC_2025_AllMetaData_2026-03-23.xlsx');

load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')
IROC_RegionNames = cellstr(cat(1,IROC_newregions.regionshort1,IROC_newregions.regionshort2,IROC_newregions.regionshort3,IROC_newregions.regionshort4,...
    IROC_newregions.regionshort5,IROC_newregions.regionshort6,IROC_newregions.regionshort7));


M = m_shaperead('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\ICES_ecoregions\ICES_ecoregions_20171207_erase_ESRI');
no_regions = size(M.dbfdata,1);
RegionNames = M.dbfdata(:,2);
RegionNumbers = M.dbfdata{:,1};

Output = cat(2,IROC_metaData.Index,IROC_metaData.RegionCode,IROC_metaData.RegionCode,IROC_metaData.RegionCode,IROC_metaData.Index,IROC_metaData.Index);

for ii = 1:size(IROC_metaData,1)
    in_IROC = zeros(size(IROC_RegionNames,1),1);
    in_ECO =  zeros(size(RegionNames,1),1);
    tmp = IROC_metaData.Latitude{ii};
    if ~isempty(regexpi(tmp,'N'))
        C = textscan(tmp(1:regexp(tmp,'N')-1),'%f');
        lat_check = C{1};
    elseif ~isempty(regexpi(tmp,'S'))
        C = textscan(tmp(1:regexp(tmp,'S')-1),'%f');
        lat_check = -1.*C{1};
    end
    tmp = IROC_metaData.Longitude{ii};
    if ~isempty(regexpi(tmp,'E'))
        C = textscan(tmp(1:regexp(tmp,'E')-1),'%f');
        lon_check = C{1};
    elseif ~isempty(regexpi(tmp,'W'))
        C = textscan(tmp(1:regexp(tmp,'W')-1),'%f');
        lon_check = -1.*C{1};
    end

    for ireg = no_regions:-1:1
        rdata = M.ncst{ireg};
        IN = inpolygon(lon_check,lat_check,rdata(:,1),rdata(:,2));
        if IN==1
            in_ECO(ireg)=1;
        end
        clear IN
    end
    
    for rr=1:7
        eval(['rdata = IROC_newregions.region', num2str(rr) ';']);
            IN = inpolygon(lon_check,lat_check,rdata(:,1),rdata(:,2));
        if IN==1
            in_IROC(rr)=1;
        end
        clear IN
    end
    
    if sum(in_ECO)==0
        Output(ii,3) = {'None'};
    else
        Output(ii,3) = RegionNames(find(in_ECO==1));
    end

    if sum(in_IROC)==0
        Output(ii,4) = {'None'};
    else
        Output(ii,4) = IROC_RegionNames(find(in_IROC==1));
    end
    
    Output{ii,5} = lon_check;
    Output{ii,6} = lat_check;
end