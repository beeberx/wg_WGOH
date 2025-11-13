% Map of Stations - BICC
clear all;close all;clc;
edge_W =  -35;
edge_E =    5;
edge_S =   15;
edge_N =   50;
regTLA = 'BICC';
regTIT = 'Bay of Biscay, western Iberia and Canary Basin';
polflag=1;

fname = [getenv('Bathy') '\GEBCO_2024\GEBCO_2024_sub_ice_topo.nc'];

lon = ncread(fname,'lon');
lat = ncread(fname,'lat');

idxlon = intersect(find(lon>=edge_W-5),find(lon<=edge_E+5));
idxlat = intersect(find(lat>=edge_S-5),find(lat<=edge_N+5));

istride = 20;
eta = ncread(fname,'elevation',[idxlon(1) idxlat(1)],[Inf Inf],[istride istride]);
lon = ncread(fname,'lon',[idxlon(1)],[Inf],[istride]);
lat = ncread(fname,'lat',[idxlat(1)],[Inf],[istride]);

clear idxlon idxlat
%%
load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')
rdata = IROC_newregions.region4;

%%
IROC_metaData = readtable('..\Data\IROC_Header_Summary_updated_2025-08-22.xlsx');
idx = find(cellfun(@isempty,regexpi(IROC_metaData.Index_,regTLA))==0);
IROC_metaData=IROC_metaData(idx,:);clear idx
[u,iU]=unique(IROC_metaData.Index_);
IROC_metaData = IROC_metaData(iU,:);clear u iU

%%
POI_lab = cat(1,IROC_metaData.Index_);
POI_wkt = cat(1,IROC_metaData.Area_);

%%
close all
clf
m_proj('mercator','lon',[edge_W,edge_E],'lat',[edge_S,edge_N]);

cmap_ocean = flipud(cbrewer('seq','Blues',101));
cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;

[CS,CH]=m_contourf(lon,lat,double(eta)',[-10000:1000:1000 1000:100:0],'edgecolor','none');
hold on
caxis([-10000 0])
m_grid('linestyle','none','tickdir','out','linewidth',3);

m_plot(rdata(:,1),rdata(:,2),'-','LineWidth',1,'color','b')%[.6 .6 .6]

coldef_land = [0 0.3059 0.1059];
m_gshhs_i('patch',coldef_land,'edgecolor','k')

if polflag == 1
    IROC_2025_mplot_countries(edge_W,edge_E,edge_S,edge_N,...
        'I:\Data_External\NaturalEarth_GIS\cultural_10m\ne_10m_admin_0_countries');
end

brighten(.3);

colormap([cmap_ocean]);

[LONT,LATT] = IROC_2025_mplot_wkt(POI_wkt);

%%
for ii=1:size(IROC_metaData,1)
    if isnan(LONT(ii));continue;end
    if ismember(IROC_metaData.Index_{ii},{'BICC_005';...
            'BICC_007';'BICC_008';'BICC_010';'BICC_011';...
            'BICC_013';'BICC_014';'BICC_015';'BICC_017';'BICC_018'})
        continue
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_004'})
        txtT = {'BICC_004';'BICC_005'};
        posT = [LONT(ii)+1,LATT(ii)-3];
        tHal = 'center';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_006'})
        txtT = {'BICC_006';'BICC_007';'BICC_008' };
        posT = [LONT(ii)+1,LATT(ii)-2];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_009'})
        txtT = {'BICC_009';'BICC_010';'BICC_011' };
        posT = [LONT(ii)+2,LATT(ii)-1.5];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_012'})
        txtT = {'BICC_012';'BICC_013';'BICC_014';'BICC_015' };
        posT = [LONT(ii)-4,LATT(ii)-1.5];
        tHal = 'right';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_016'})
        txtT = {'BICC_016';'BICC_017';'BICC_018' };
        posT = [LONT(ii)-2,LATT(ii)+1];
        tHal = 'right';
        tVal = 'bottom';
    elseif ismember(IROC_metaData.Index_{ii},{'BICC_003'})
        txtT = IROC_metaData.Index_{ii};
        posT = [LONT(ii),LATT(ii)-1];
        tHal = 'right';
        tVal = 'top';
    else
        txtT = IROC_metaData.Index_{ii};
        posT = [LONT(ii),LATT(ii)-1];
        tHal = 'left';
        tVal = 'top';
    end
    m_plot([LONT(ii) posT(1)],[LATT(ii) posT(2)],'k-')
    m_text(posT(1),posT(2),txtT,...
        'interpreter','none','color','r','backgroundcolor','w',...
        'edgecolor','k','verticalalignment',tVal','horizontalalignment',tHal)
    clear posT tVal tHal
end

ax=m_contfbar(1,[.5 .8],CS,CH);
title(ax,{'Depth (m)','',''}); % Move up by inserting a blank line

set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,[ 'IROC_2025_StationMap_',regTLA,'.png'])
% set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
%     'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7],'InvertHardcopy','off')
% % set(gcf,'paperorientation','portrait','papertype','a4','paperpositionmode','auto',...
% %     'paperunits','centimeters','paperposition',[0.6 0.6 19.7 28.4],'InvertHardcopy','off')
% print(gcf, '-dpng', '-r300',[ 'IROC_2025_StationMap_',regTLA,'.png'])
