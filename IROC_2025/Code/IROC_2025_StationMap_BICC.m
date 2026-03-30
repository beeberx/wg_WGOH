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
% IROC_metaData = readtable('..\Data\IROC_Header_Summary_updated_2025-08-22.xlsx');
IROC_metaData = readtable('IROC_2025_AllMetaData_2026-03-23.xlsx');
idx = find(cellfun(@isempty,regexpi(IROC_metaData.Index,regTLA))==0);
IROC_metaData=IROC_metaData(idx,:);clear idx
[u,iU]=unique(IROC_metaData.Index);
IROC_metaData = IROC_metaData(iU,:);clear u iU

%%
POI_lab = cat(1,IROC_metaData.Index);
POI_wkt = cat(1,IROC_metaData.DetailedLocation_WKT_);

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
    if ismember(IROC_metaData.Index{ii},{'BICC_110','BICC_111','BICC_121','BICC_131',...
            'BICC_141','BICC_151','BICC_161','BICC_349'})
        txtT = IROC_metaData.Index{ii};
        if ismember(IROC_metaData.Index{ii},{'BICC_121','BICC_141'})
            posT = [LONT(ii),LATT(ii)+0.7];
            if ismember(IROC_metaData.Index{ii},{'BICC_121'})
                tHal = 'center';
            else
                tHal = 'right';
            end
        tVal = 'bottom';
        elseif ismember(IROC_metaData.Index{ii},{'BICC_110','BICC_131'})
            posT = [LONT(ii),LATT(ii)+1.7];
        tHal = 'center';
        tVal = 'bottom';
        elseif ismember(IROC_metaData.Index{ii},{'BICC_161','BICC_349','BICC_111'})
            posT = [LONT(ii)+1,LATT(ii)];
        tHal = 'left';
        tVal = 'middle';
        elseif ismember(IROC_metaData.Index{ii},{'BICC_151'})
            posT = [LONT(ii)-1,LATT(ii)+0.5];
        tHal = 'right';
        tVal = 'bottom';
        else
            posT = [LONT(ii),LATT(ii)-0.1];
        tHal = 'center';
        tVal = 'bottom';
        end
    elseif ismember(IROC_metaData.Index{ii},{'BICC_001'})
        txtT = {'BICC_001';'BICC_002';'BICC_003';'BICC_004'};
        posT = [LONT(ii)-2,LATT(ii)+1.5];
        tHal = 'right';
        tVal = 'bottom';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_122'})
        txtT = {'BICC_122';'BICC_123'};
        posT = [LONT(ii)+1,LATT(ii)-1];
        tHal = 'center';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_131','BICC_131'})
        txtT = {'BICC_132'};
        posT = [LONT(ii)+1,LATT(ii)-3];
        tHal = 'center';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_172'})
        txtT = {'BICC_172';'BICC_173';'BICC_174';'BICC_175' };
        posT = [LONT(ii)-3.5,LATT(ii)];
        tHal = 'right';
        tVal = 'middle';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_211'})
        txtT = {'BICC_211';'BICC_212';'BICC_213';'BICC_214' };
        posT = [LONT(ii)+1,LATT(ii)-0.5];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_221'})
        txtT = {'BICC_221';'BICC_222';'BICC_223';'BICC_224' };
        posT = [LONT(ii)+1,LATT(ii)-0.5];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_231'})
        txtT = {'BICC_231';'BICC_232';'BICC_233';'BICC_234' };
        posT = [LONT(ii)-2,LATT(ii)-1];
        tHal = 'right';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_312'})
        txtT = {'BICC_312';'BICC_313'};
        posT = [LONT(ii)-1,LATT(ii)-1];
        tHal = 'right';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_321'})
        txtT = {'BICC_321';'BICC_328';'BICC_329'};
        posT = [LONT(ii)+0.4,LATT(ii)+0.5];
        tHal = 'left';
        tVal = 'bottom';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_331'})
        txtT = {'BICC_331';'BICC_332';'BICC_333'};
        posT = [LONT(ii)+1,LATT(ii)-2];
        tHal = 'left';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_412'})
        txtT = {'BICC_412';'BICC_413';'BICC_414'};
        posT = [LONT(ii)-1,LATT(ii)-2];
        tHal = 'center';
        tVal = 'top';
    elseif ismember(IROC_metaData.Index{ii},{'BICC_421'})
        txtT = {'BICC_421';'BICC_422';'BICC_423'};
        posT = [LONT(ii)+2,LATT(ii)-1];
        tHal = 'left';
        tVal = 'top';
    else
        continue
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
