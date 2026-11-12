% Map of Selected Stations - Summary Figure
clear all;close all;clc;
edge_W =  -180;
edge_E =   180;
edge_S =    10;
edge_N =    85;

%fname = [getenv('Bathy') '\GEBCO_2024\GEBCO_2024_sub_ice_topo.nc'];
%lon = ncread(fname,'lon');
%lat = ncread(fname,'lat');
%idxlon = intersect(find(lon>=edge_W-5),find(lon<=edge_E+5));
%idxlat = intersect(find(lat>=edge_S-5),find(lat<=edge_N+5));
%istride = 20;
%eta = ncread(fname,'elevation',[idxlon(1) idxlat(1)],[Inf Inf],[istride istride]);
%lon = ncread(fname,'lon',[idxlon(1)],[Inf],[istride]);
%lat = ncread(fname,'lat',[idxlat(1)],[Inf],[istride]);
%clear idxlon idxlat

%%
%load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')

%%
coldef_land = [239, 245, 247]./255;
coldef_ocean = [203, 225, 233]./255;

%%
close all
clf
m_proj('lambert','lon',[-105 70],'lat',[10 85]);

%bathymetry map
%cmap_ocean = flipud(cbrewer('seq','Blues',101));
%cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;
%[CS,CH]=m_contourf(lon,lat,double(eta)',[-10000:1000:1000 1000:100:0],'edgecolor','none');
%colormap([cmap_ocean]);
%hold on
%caxis([-10000 10])

% coldef_land = [0 0.3059 0.1059];
% m_gshhs_i('patch',coldef_land,'edgecolor','none')
m_coast('patch',coldef_land,'edgecolor',coldef_land);
m_nolakes(coldef_land,coldef_land)

% m_grid('linestyle','none','tickdir','out','linewidth',3);
m_grid('xtick',[60:-60:-120],'ytick',[30:15:85],'XaxisLocation','bottom','YaxisLocation','left','color',coldef_ocean);%,'box','fancy'

exportgraphics(gcf,'Basemap.svg','ContentType','vector')


function m_nolakes(lakeColor,lakeEdge)
% delete the water bodies patches in figures created by m_map
%        default lakeColor is white ([1 1 1]), default lakeEdge is white ([1 1 1])
% usage:
%        m_nolakes(lakeColor,lakeEdge)
%        http://scriptdemo.blogspot.com
%  xianmin@ualberta.ca
%
%  $Log$
%  Matlab 8.3, R2014a@pequod, dkieke, added edgecolor option
%  05.06.2020, dkieke,  Matlab 8.3, R2014a@pequod: needed to optimize line 24 to work properly in m_map1.4k and higher

if nargin==0
    lakeColor = [1 1 1];
    lakeEdge  = [1 1 1];
elseif nargin ~= 1 & nargin ~= 2
    help m_nolakes
    return
end

gshhstypes={'c','l','i','h','f'};

for nt = 1:numel(gshhstypes)
    eval(['hw=findobj(gcf,''type'',''patch'',''tag'',''m_gshhs_',gshhstypes{nt},'_lake'');'])%,''facecolor'',lakeColor,''edgecolor'',lakeEdge);']);

    if ~isempty(hw)
        delete(hw);
    end

end

hw=findobj(gcf,'type','patch','tag','m_coast_lake');
if ~isempty(hw)
    delete(hw);
end


hw = findobj(gcf,'type','patch','tag','m_coast','facecolor',lakeColor,'edgecolor',lakeEdge);

if ~isempty(hw)
    delete(hw);
end
end