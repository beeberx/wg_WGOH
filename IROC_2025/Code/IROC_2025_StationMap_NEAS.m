% Map of Stations - NEAS
clear all;close all;clc;
edge_W = -85;
edge_E =  -40;
edge_S =   30;
edge_N =   65;
regTLA = 'NEAS';
regTIT = 'Northeast American Shelf';
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
rdata = IROC_newregions.region2;

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

colormap([cmap_ocean]);

coldef_land = [0 0.3059 0.1059];
m_gshhs_i('patch',coldef_land)

if polflag == 1
    IROC_2025_mplot_countries(edge_W,edge_E,edge_S,edge_N,...
        'I:\Data_External\NaturalEarth_GIS\cultural_10m\ne_10m_admin_0_countries');
end

brighten(.3);

[LONT,LATT] = IROC_2025_mplot_wkt(POI_wkt);

%%
for ii=1:17
    if ismember(IROC_metaData.Index_{ii},{'NEAS_016','NEAS_015','NEAS_013','NEAS_011',...
            'NEAS_004','NEAS_010'})
        posT = [LONT(ii)+1,LATT(ii)-0.75];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_002','NEAS_017'})
        posT = [LONT(ii)-1,LATT(ii)+0.5];
        tVal = 'bottom';
        tHal = 'right';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_001'})
        posT = [LONT(ii),LATT(ii)];
        tVal = 'middle';
        tHal = 'center';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_005'})
        posT = [LONT(ii),LATT(ii)-0.5];
        tHal = 'center';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_003'})
        posT = [LONT(ii)+2.5,LATT(ii)];
        tVal = 'middle';
        tHal = 'left';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_006'})
        posT = [LONT(ii)-1,LATT(ii)-0.5];
        tVal = 'bottom';
        tHal = 'right';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_007'})
        posT = [LONT(ii)+1,LATT(ii)-0.5];
        tVal = 'top';
        tHal = 'left';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_008'})
        posT = [LONT(ii)-1,LATT(ii)+1];
        tVal = 'bottom';
        tHal = 'right';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_009'})
        posT = [LONT(ii)-3.5,LATT(ii)+2];
        tVal = 'bottom';
        tHal = 'right';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_013'})
        posT = [LONT(ii)+1,LATT(ii)];
        tVal = 'middle';
        tHal = 'left';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_012'})
        posT = [LONT(ii)+1.5,LATT(ii)];
        tVal = 'middle';
        tHal = 'left';
    elseif ismember(IROC_metaData.Index_{ii},{'NEAS_014'})
        posT = [LONT(ii)+1,LATT(ii)-1.5];
        tVal = 'top';
        tHal = 'left';
    end
    m_plot([LONT(ii) posT(1)],[LATT(ii) posT(2)],'k-')
    m_text(posT(1),posT(2),IROC_metaData.Index_{ii},...
        'interpreter','none','color','r','backgroundcolor','w',...
        'edgecolor','k','verticalalignment',tVal','horizontalalignment',tHal)
    clear posT tVal tHal
end

m_plot(-71.338,46.852,'ow','markerfacecolor','w')
m_text(-71.75,46.9,'Québec City','color','w','horizontalalignment','right','fontsize',14,'fontweight','bold')
m_plot(-74.047,40.702,'ow','markerfacecolor','w')
m_text(-74.5,41,'New York','color','w','horizontalalignment','right','fontsize',14,'fontweight','bold')
m_plot(-51.733,64.174,'ow','markerfacecolor','w')
m_text(-51.3,64.2,'Nuuk','color','w','horizontalalignment','left','fontsize',14,'fontweight','bold')
m_text(-70,57,{'Québec-';'Labrador';'Peninsula'},'color','w','fontsize',14,'fontweight','bold','horizontalalignment','center')
m_text(-56.382,48.532,{'New-','found-','land'},'color','w','fontsize',10,'fontweight','bold','horizontalalignment','center')

m_text(-73,50,'Canada','color',[.8 .8 .8],'fontsize',22,'fontweight','bold','horizontalalignment','center')
m_text(-81,36,'U.S.A.','color',[.8 .8 .8],'fontsize',22,'fontweight','bold','horizontalalignment','center')

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
