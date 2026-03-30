% Map of Stations - NSBS
clear all;close all;clc;
edge_W =  -40;
edge_E =   70;
edge_S =   55;
edge_N =   85;
regTLA = 'NSBS';
regTIT = 'Nordic & Barents Seas';
polflag = 1;

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
rdata = IROC_newregions.region5;

%%
IROC_metaData = readtable('..\Data\IROC_Header_Summary_updated_2025-09-17.xlsx');
idx = find(cellfun(@isempty,regexpi(IROC_metaData.Index_,regTLA))==0);
IROC_metaData=IROC_metaData(idx,:);clear idx
[u,iU]=unique(IROC_metaData.Index_);
IROC_metaData = IROC_metaData(iU,:);clear u iU

idx = find(ismember(IROC_metaData.Index_,{'NSBS_001';'NSBS_003';'NSBS_006';'NSBS_009';'NSBS_012';...
    'NSBS_013';'NSBS_014';'NSBS_015';'NSBS_018';'NSBS_019';'NSBS_021';'NSBS_024';'NSBS_025';...
    'NSBS_026';'NSBS_027';'NSBS_029';'NSBS_030';'NSBS_031'}))
IROC_metaData = IROC_metaData(idx,:);clear idx

%%
POI_lab = cat(1,IROC_metaData.Index_);
POI_wkt = cat(1,IROC_metaData.Area_);

%%
close all
clf
m_proj('lambert','lon',[edge_W,edge_E],'lat',[edge_S,edge_N]);

cmap_ocean = flipud(cbrewer('seq','Blues',101));
cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;

[CS,CH]=m_contourf(lon,lat,double(eta)',[-10000:1000:1000 1000:100:0],'edgecolor','none');
hold on
caxis([-10000 0])
m_grid('linestyle','none','tickdir','out','linewidth',3,'fontsize',14);

m_plot(rdata(:,1),rdata(:,2),'-','LineWidth',1,'color','b')%[.6 .6 .6]

coldef_land = [0 0.3059 0.1059];
m_gshhs_i('patch',coldef_land,'edgecolor','k')

if polflag == 1
    IROC_2025_mplot_countries_noLabels(edge_W,edge_E,edge_S,edge_N,...
        'I:\Data_External\NaturalEarth_GIS\cultural_10m\ne_10m_admin_0_countries');
end

brighten(.3);

colormap([cmap_ocean]);

[LONT,LATT] = IROC_2025_mplot_wkt(POI_wkt);

%%
for ii=1:size(IROC_metaData,1)
    if ismember(IROC_metaData.Index_{ii},{'NSBS_001'})
        txtT = {'NSBS_001';'BSO'};
        posT = [LONT(ii)+3,LATT(ii)-1];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_003' })
        txtT = {'NSBS_003';'V-N'};
        posT = [LONT(ii)+3,LATT(ii)+1.5];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_009'})
        txtT = {'NSBS_009';'NSBS_029';'FSC'};
        posT = [LONT(ii)+3,LATT(ii)-1];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_006'})
        txtT = {'NSBS_006';'NSBS_026';'NSBS_027';'FC-N'};
        posT = [LONT(ii)-12,LATT(ii)-2];
        tHal = 'right';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_012'})
        txtT = {'NSBS_012';'FS-N'};
        posT = [LONT(ii),LATT(ii)+2];
        tHal = 'center';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_019'})
        txtT = {'NSBS_019';'FS-S'};
        posT = [LONT(ii)+4,LATT(ii)];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_013'})
        txtT = {'NSBS_013';'Gim'};
        posT = [LONT(ii)+4,LATT(ii)];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_014'})
        txtT = {'NSBS_014'};
        posT = [LONT(ii)+4,LATT(ii)-1];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_015'})
        txtT = {'NSBS_015';'M'};
        posT = [LONT(ii)-1,LATT(ii)-1.5];
        tHal = 'center';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_018'})
        txtT = {'NSBS_018';'Svi'};
        posT = [LONT(ii)+4,LATT(ii)];
        tHal = 'left';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_021'})
        txtT = {'NSBS_021';'NSBS_030';'LNa'};
        posT = [LONT(ii)-4,LATT(ii)+1.5];
        tHal = 'right';
        tVal = 'bottom';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_024'})
        txtT = {'NSBS_024';'Si'};
        posT = [LONT(ii)-1,LATT(ii)-0.5];
        tHal = 'right';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_025'})
        txtT = {'NSBS_025';'Fx'};
        posT = [LONT(ii)-2,LATT(ii)+1];
        tHal = 'right';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index_{ii},{'NSBS_031'})
        txtT = {'NSBS_031'};
        posT = [LONT(ii)-5,LATT(ii)-1];
        tHal = 'right';
        tVal = 'top';
    else 
        continue
    end
    m_plot([LONT(ii) posT(1)],[LATT(ii) posT(2)],'k-')
    m_text(posT(1),posT(2),txtT,...
        'interpreter','none','color','r','backgroundcolor','w',...
        'edgecolor','k','verticalalignment',tVal','horizontalalignment',tHal,...
        'fontsize',14)
    clear posT tVal tHal
end

%ax=m_contfbar(1,[.5 .8],CS,CH);
ax=m_contfbar([.7 .9],.9,CS,CH);
title(ax,{'Depth (m)','',''}); % Move up by inserting a blank line

set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,[ 'IROC_2025_StationMap_',regTLA,'.png'])
% set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
%     'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7],'InvertHardcopy','off')
% % set(gcf,'paperorientation','portrait','papertype','a4','paperpositionmode','auto',...
% %     'paperunits','centimeters','paperposition',[0.6 0.6 19.7 28.4],'InvertHardcopy','off')
% print(gcf, '-dpng', '-r300',[ 'IROC_2025_StationMap_',regTLA,'.png'])




% Time series in Fig 6.2:
% Faroe-Shetland Channel (NSBS_009)
% Faroe Current – N (NSBS_006)
% Svinøy (NSBS_018)
% Faxafloi (NSBS_025)
% Siglunes (NSBS_024)
% Gimsøy (NSBS_013)
% Barents Sea Opening (NSBS_001)
% Vardø-N (NSBS_003)
% Fram Strait S (NSBS_019)
% Fram Strait N (NSBS_012)
% 
% Time series in Fig 6.3:
% Norwegian Sea Heat and Freshwater Content anomaly (NSBS_014)
% 
% Time series in Fig. 6.4:
% Greenland Sea ML D/T/S (polygon, no ID)
% 
% Time series in Fig. 6.5:
% Barents Sea Ice area (external source, no ID) + Fugløya-Bear Island section (NSBS_001, as in Fig. 6.2)
% 
% Time series in Fig. 6.6:
% Sea surface temperature anomalies (MHW, external source, no ID)
% 
% Time series in Fig. 6.7:
% Langanes section, stations 2-6, EIC (NSBS_030)
% 
% Time series in Fig. 6.8:
% Norwegian Sea Arctic Water (no ID but location is the Svinøy section (NSBS_018))
% 
% Time series in Fig. 6.9:
% Intermediate water in the Faroe North section at 800-1000 m (NSBS_027) and the Faroe-Shetland Channel at 1100 m (NSBS_029)
% 
% Time series in Fig. 6.10:
% Deep water in the Iceland Sea at 1500-1800 m (NSBS_021), Faroe-N  at 1800-2000 m (NSBS_026) and OWS “M” at 2000 m (NSBS_015)
