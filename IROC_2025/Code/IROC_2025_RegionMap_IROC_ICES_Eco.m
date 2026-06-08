% Map of IROC regions and ICES Ecosystem Regions
clear all;close all;clc;
edge_W =  -180;
edge_E =   180;
edge_S =    10;
edge_N =    85;

bathy_flag= 0;

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
%load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')


%%
load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')

M = m_shaperead('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\ICES_ecoregions\ICES_ecoregions_20171207_erase_ESRI');

ECO_cols = load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\ICES_ecoregions\ICES_ecoregions_colours.txt')./255;

%%
close all
clf
%m_proj('mercator','lon',[edge_W,edge_E],'lat',[edge_S,edge_N]);
%m_proj('Stereographic','longitudes',[-37],'latitudes',[60],'radius',[45],'rect','on');
m_proj('lambert','lon',[-105 70],'lat',[10 85]);
hold on

%bathymetry map
if bathy_flag==1
    cmap_ocean = flipud(cbrewer('seq','Blues',101));
    cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;
    [CS,CH]=m_contourf(lon,lat,double(eta)',[-10000:1000:1000 1000:100:0],'edgecolor','none');
    colormap([cmap_ocean]);
    caxis([-10000 10])
end

%% ICES Eco_Regions
no_regions = size(M.dbfdata,1);
RegionNames = M.dbfdata(:,2);
RegionNumbers = M.dbfdata{:,1};

for ireg = no_regions:-1:1
    tmp = M.ncst{ireg};
    m_patch(tmp(:,1),tmp(:,2),'r','linestyle','-','LineWidth',1,'edgecolor',ECO_cols(ireg,:),'facecolor',ECO_cols(ireg,:))%[.6 .6 .6]);,'facealpha',0.5
end

for rr=1:7
    eval(['rdata = IROC_newregions.region', num2str(rr) ';']);
    m_patch(rdata(:,1),rdata(:,2),'b','linestyle','-','LineWidth',1,'edgecolor','b','facecolor','none')%[.6 .6 .6]
end


% coldef_land = [0 0.3059 0.1059];
% m_gshhs_i('patch',coldef_land,'edgecolor','none')
%m_coast('patch',[0.75 0.75 0.75],'edgecolor','k');
%m_nolakes([0.75 0.75 0.75],[0.75 0.75 0.75])
m_coast('patch',[255 255 190]/255,'edgecolor',[.6 .6 .6]);
m_nolakes([255 255 190]/255,[255 255 190]/255)
% m_grid('linestyle','none','tickdir','out','linewidth',3);
m_grid('xtick',[60:-60:-120],'ytick',[30:15:85],'XaxisLocation','bottom','YaxisLocation','left');%,'box','fancy'

set(gcf,'position',IROC_2025_fun_framesize(),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,'IROC_2025_Map_IROCRegions_ICESEcoRegions.png','png')
