return
%% make nice map of NWES region

clear all;close all;clc
fname = [getenv('Bathy') '\GEBCO_2024\GEBCO_2024_sub_ice_topo.nc'];
ncdisp(fname)

lon = ncread(fname,'lon');
lat = ncread(fname,'lat');

idxlon = intersect(find(lon>=-110),find(lon<=80));
idxlat = intersect(find(lat>=0),find(lat<=90));

istride = 20;
eta = ncread(fname,'elevation',[idxlon(1) idxlat(1)],[Inf Inf],[istride istride]);
lon = ncread(fname,'lon',[idxlon(1)],[Inf],[istride]);
lat = ncread(fname,'lat',[idxlat(1)],[Inf],[istride]);

clear idxlon idxlat

%%
XLimVal = [    -20 15]; 
YLimVal = [    45 65] ;
rr=1;

cmap_ocean = flipud(cbrewer('seq','Blues',61));
cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;
cmap_land = cbrewer('seq','Greens',61);
cmap_land(cmap_land<0)=0;cmap_land(cmap_land>1)=1;

%% NWES base only
close all
%m_proj('lambert','lon',XLimVal(rr,:),'lat',YLimVal(rr,:)); 
m_proj('mercator','lon',XLimVal(rr,:),'lat',YLimVal(rr,:)); 

[CS,CH]=m_contourf(lon,lat,double(eta)',[-10000, -3000:50:0, 250:250:3000],'edgecolor','none');
hold on
[CS2,CH2]=m_contour(lon,lat,double(eta)',[-500:100:-100,-75:25:0],'edgecolor',[.8 .8 .8]);
caxis([-1000 1000])
colormap([cmap_ocean;cmap_land]);
colorbar
m_grid('linestyle','none','tickdir','out','linewidth',3);
 


coldef_land = cmap_land(end-1,:);
m_gshhs_i('color',coldef_land)

print(gcf, '-dpng', '-r300', ['IROC_2025_emptyBasemap_NWES.png'])  
