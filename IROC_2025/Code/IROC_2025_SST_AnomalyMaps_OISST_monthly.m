%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Script to load NOAA OISST Hi Res Sea Surface Temperature Data,       %
%    calculate anomalies (obs - mean in reference period) and normalised  %
%    anomalies (obs - mean, scaled by standard deviation in reference     %
%    period), and create plots of these within large IROC region of       %
%    and plotting seasonal maps. Figures is large panel of annual mean    %
%    with 2 by 2 underneath of four seasonal means/                       %
%                                                                         %
%  Author - Bee Berx                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc

%% set lon and lat extents for area, time_extent for data and data directory
lon_extent = [-80 30];
lat_extent = [ 20 85];
sst_dir = ['I:\Data_External\NOAA_oisst.v2.highres\'];
clim_ref_period = [1991 2020];
year_of_interest = 2025;

%% set whether or not to save figures
save_fig_flag = 1;

%% get the OISST data
[SST,SST_anom,SST_norm_anom,time,lon,lat] = ...
    IROC_2025_fun_get_NOAA_OISST_spatial('time_extent',[datenum(year_of_interest,1,1),datenum(year_of_interest,12,31)],...
    'lon_extent', lon_extent, 'lat_extent', lat_extent,...
    'clim_period',[1991 2020], 'data_dir',sst_dir);

%% if year is incomplete, fill with NaN to correct size
if size(SST,3)<12
    SST = cat(3,SST,NaN.*zeros(size(SST,1),size(SST,2),12-size(SST,3)));
    SST_anom = cat(3,SST_anom,NaN.*zeros(size(SST,1),size(SST,2),12-size(SST,3)));
    SST_norm_anom = cat(3,SST_norm_anom,NaN.*zeros(size(SST,1),size(SST,2),12-size(SST,3)));
end

%%
% create plots - to use pcolor, need to shift lon and lat by half a grid
% spacing and need to pad the category with NaNs
pos12 = [0.02 0.68 0.225 0.3;0.255 0.68 0.225 0.3;0.49 0.68 0.225 0.3;0.725 0.68 0.225 0.3;...
    0.02 0.36 0.225 0.3;0.255 0.36 0.225 0.3;0.49 0.36 0.225 0.3;0.725 0.36 0.225 0.3;...
    0.02 0.04 0.225 0.3;0.255 0.04 0.225 0.3;0.49 0.04 0.225 0.3;0.725 0.04 0.225 0.3];

%% set colormaps
cmap = IROC_2025_fun_anom_colormap;

amap = IROC_2025_fun_normanom_colormap;


%% ANOM SST OI SST relative OISST
lon2plot = [min(lon(:))-0.025;lon+0.025];
lat2plot = [min(lat(:))-0.025;lat+0.025];
dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

%% ANOM SST OI SST relative OISST
% plot of anomalies each month
figure
for mm=1:12
    heat2plot = SST_anom(:,:,mm);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
    
    ax=subplot(3,4,mm);
    pcolor(lon2plot,lat2plot,heat2plot');shading flat;
    caxis([-2.5 2.5])
    colormap(cmap(:,:))
    IROC_2025_fun_coastGLOB
    set(ax,'position',pos12(mm,:));

        if ismember(mm,12)
        [hc]=colorbar(ax,'eastoutside');
        set(hc,'ytick',[-2.5:0.5:2.5],'yticklabel',sprintf('% -3.1f\n',[-2.5:0.5:2.5]'))
        title(hc,'^o C','fontsize',10,'fontname','arial')
        set(hc,'position',[0.96 0.04 0.015 0.89])
    end
    if ~ismember(mm,[9,10,11,12])
        set(ax,'xticklabel',[])
    end
    if ~ismember(mm,[1,5,9])
        set(ax,'yticklabel',[])
    end
    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{datestr(time(mm,:),'mmm-yy')},'VerticalAlignment','bottom','HorizontalAlignment','center')
end
if save_fig_flag
    figout_name = ['IROC_2025_OISST_anom_monthly_',sprintf('%4d',year_of_interest),'_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end

%%
% plot of standardised anomalies each month
figure
for mm=1:12
    heat2plot = SST_norm_anom(:,:,mm);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);

    s1=subplot(3,4,mm);
    pcolor(lon2plot,lat2plot,heat2plot')
    ax = gca;
    shading flat
    caxis([-3.5 3.5])
    colormap(amap(:,:))

    IROC_2025_fun_coastGLOB
    set(gca,'XLim',lon_extent,'YLim',lat_extent)
    set(ax,'position',pos12(mm,:));
    if ismember(mm,12)
        [hc]=colorbar(ax,'eastoutside');
        set(hc,'ytick',[-3.5:0.5:3.5],'yticklabel',sprintf('% -3.1f\n',[-3.5:0.5:3.5]'))
        title(hc,{'   St. ';'  Dev. ';'  Units'},'fontsize',10,'fontname','arial')
        set(hc,'position',[0.96 0.04 0.015 0.89])
    end
    if ~ismember(mm,[9,10,11,12])
        set(ax,'xticklabel',[])
    end
    if ~ismember(mm,[1,5,9])
        set(ax,'yticklabel',[])
    end
    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{datestr(time(mm,:),'mmm-yy')},'VerticalAlignment','bottom','HorizontalAlignment','center')
end
if save_fig_flag
    figout_name = ['IROC_2025_OISST_norm_anom_monthly_',sprintf('%4d',year_of_interest),'_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end
