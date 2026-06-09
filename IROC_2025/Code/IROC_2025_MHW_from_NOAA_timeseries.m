clear all;close all;clc

%% set lon and lat extents for area, time_extent for data and data directory
lon_extent = [-80 30];
lat_extent = [ 20 85];
time_extent = [datenum(2025,1,1),datenum(2025,12,31)];
data_dir = [getenv('isilon'),'\Data_External\NOAA_MarineHeatwaveWatch\v1.0.1\category\nc\'];

%% set whether or not to save figures
save_fig_flag = 1;

%%
% go get MHW data using extents defined above
[MHW_cat,MHW_time,MHW_lon,MHW_lat] = IROC_2025_fun_get_NOAA_MHW_spatial('time_extent',time_extent,...
                                           'lon_extent', lon_extent, 'lat_extent', lat_extent,... 
                                           'data_dir',data_dir);
% make time as a [yyyy mm dd HH MM SS] matrix
MHW_timevec = datevec(MHW_time);

%% set colour maps
MHW_cmap = IROC_2025_fun_MHW_colormap;

%%
% create plots - to use pcolor, need to shift lon and lat by half a grid
% spacing and need to pad the category with NaNs


%% plot of max MHW cat over entire time
lon2plot = [min(MHW_lon(:))-0.025;MHW_lon+0.025];
lat2plot = [min(MHW_lat(:))-0.025;MHW_lat+0.025];
heat2plot = max(MHW_cat,[],3);
heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);
figure
m_proj('Mercator','longitudes',lon_extent,'latitudes',lat_extent);
m_pcolor(lon2plot,lat2plot,heat2plot');
caxis([-0.5 5.5])
colormap(MHW_cmap)
IROC_2025_fun_coastGLOB
m_gshhs_i('patch', [240,237,233]/255,'edgecolor',[0 0 0]/255);
m_grid('xtick',min(lon2plot):dlon:max(lon2plot),'ytick',min(lat2plot):dlat:max(lat2plot),...
    'box', 'on','gridcolor',[.8 .8 .8],'linestyle','-','fontsize',12,'fontname','Arial')
colorbar('southoutside')
title({'Maximum Heatwave Category';...
    [datestr(MHW_time(1),'dd-mmm-yy') ' to ' datestr(MHW_time(end),'dd-mmm-yy') ];...
    'Source: NOAA Marine Heatwave Product'})
if save_fig_flag
    figout_name = ['IROC_2025_MHW_max_all_dates_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end

%% plot of mean MHW cat over entire time
lon2plot = [min(MHW_lon(:))-0.025;MHW_lon+0.025];
lat2plot = [min(MHW_lat(:))-0.025;MHW_lat+0.025];
heat2plot = mean(MHW_cat,3);
heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);
figure
m_proj('Mercator','longitudes',lon_extent,'latitudes',lat_extent);
m_pcolor(lon2plot,lat2plot,heat2plot');
caxis([-0.5 5.5])
colormap(MHW_cmap)
IROC_2025_fun_coastGLOB
m_gshhs_i('patch', [240,237,233]/255,'edgecolor',[0 0 0]/255);
m_grid('xtick',min(lon2plot):dlon:max(lon2plot),'ytick',min(lat2plot):dlat:max(lat2plot),...
    'box', 'on','gridcolor',[.8 .8 .8],'linestyle','-','fontsize',12,'fontname','Arial')
colorbar('southoutside')
title({'Mean Heatwave Category';...
    [datestr(MHW_time(1),'dd-mmm-yy') ' to ' datestr(MHW_time(end),'dd-mmm-yy') ];...
    'Source: NOAA Marine Heatwave Product'})
if save_fig_flag
    figout_name = ['IROC_2025_MHW_mean_all_dates_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end