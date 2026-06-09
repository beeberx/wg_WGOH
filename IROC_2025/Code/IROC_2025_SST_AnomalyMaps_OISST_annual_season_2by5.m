%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Script to load NOAA OISST Hi Res Sea Surface Temperature Data,       %
%    calculate anomalies (obs - mean in reference period) and normalised  %
%    anomalies (obs - mean, scaled by standard deviation in reference     %
%    period), and create plots of these within large IROC region of       %
%    and plotting seasonal maps. The plot is a strip of 2 rows, 5 columns %
%    with annual mean and four seasonal means, one row anomalies, one row %
%    normalised anomalies.                                                %
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

%% set colour maps
MHW_cmap = IROC_2025_fun_MHW_colormap;

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

%% create annual mean anomaly and normalised anomaly
ann_Anom_select = mean(SST_anom,3);
ann_NormAnom_select = mean(SST_norm_anom,3);

%% calculate seasonal mean anomaly and normalised anomaly
sea_Anom_select = NaN.*zeros(size(SST,1),size(SST,2),4);
sea_NormAnom_select = NaN.*zeros(size(SST,1),size(SST,2),4);
sea_idx = [1,2,3;4,5,6;7,8,9;10,11,12];
for ss=1:4
    sea_Anom_select(:,:,ss) = mean(SST_anom(:,:,sea_idx(ss,:)),3);
    sea_NormAnom_select(:,:,ss) = mean(SST_norm_anom(:,:,sea_idx(ss,:)),3);
end

%% set colormaps
cmap = IROC_2025_fun_anom_colormap;

amap = IROC_2025_fun_normanom_colormap;

%% set figure parameters [left bottom width height]
pw = 0.18;pm = 0.03;
ph = 0.47;

pos5_2_5 = [pm 0.04 pw ph,      pm 0.04+1*(ph+0.005) pw ph;
    pm+1*(pw+0.005) 0.04 pw ph, pm+1*(pw+0.005) 0.04+1*(ph+0.005) pw ph;
    pm+2*(pw+0.005) 0.04 pw ph, pm+2*(pw+0.005) 0.04+1*(ph+0.005) pw ph;
    pm+3*(pw+0.005) 0.04 pw ph, pm+3*(pw+0.005) 0.04+1*(ph+0.005) pw ph;
    pm+4*(pw+0.005) 0.04 pw ph, pm+4*(pw+0.005) 0.04+1*(ph+0.005) pw ph];


%% ANOM SST OI SST relative OISST
toPlot_Anom = cat(3,ann_Anom_select,sea_Anom_select);
toPlot_NormAnom = cat(3,ann_NormAnom_select,sea_NormAnom_select);
toPlot_Titles = {'Annual','JFM','AMJ','JAS','OND'};

lon2plot = [min(lon(:))-0.025;lon+0.025];
lat2plot = [min(lat(:))-0.025;lat+0.025];
dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

%% ANOM SST OI SST relative OISST
close all
figure
for ss=1:5
    ax1 = axes('position',pos5_2_5(ss,5:8));hold on
    heat2plot = toPlot_Anom(:,:,ss);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
    pcolor(lon2plot,lat2plot,heat2plot');shading flat;
    caxis([-2.5 2.5]);
    colormap(ax1,cmap(:,:));
    IROC_2025_fun_coastGLOB
    set(ax1,'position',pos5_2_5(ss,5:8),'xlim',lon_extent,'ylim',lat_extent,'Box','on');

    if ismember(ss,5)
        [hc]=colorbar(ax1,'eastoutside');
        set(hc,'ytick',[-2.5:0.5:2.5],'yticklabel',sprintf('% -3.1f\n',[-2.5:0.5:2.5]'));
        title(hc,'^o C','fontsize',10,'fontname','arial');
        set(hc,'position',[0.955 0.06+1*(ph+0.005) 0.015 ph-0.1]);
    end
    set(ax1,'xticklabel',[]);
    if ismember(ss,[2,3,4,5])
        set(ax1,'yticklabel',[]);
    end
    %if ss==1
        text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{num2str(year_of_interest);toPlot_Titles{ss}},'VerticalAlignment','bottom','HorizontalAlignment','center');
    %else
    %    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,toPlot_Titles{ss},'VerticalAlignment','bottom','HorizontalAlignment','center');
    %end

% Standardised ANOM SST OI SST relative OISST
    ax2 = axes('position',pos5_2_5(ss,1:4));hold on
    heat2plot = toPlot_NormAnom(:,:,ss);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
    pcolor(lon2plot,lat2plot,heat2plot');shading flat;
    caxis([-3.5 3.5])
    colormap(ax2,amap(:,:))

    IROC_2025_fun_coastGLOB
    set(ax2,'position',pos5_2_5(ss,1:4),'xlim',lon_extent,'ylim',lat_extent,'Box','on');

    if ismember(ss,5)
        [hc]=colorbar(ax2,'eastoutside');
        set(hc,'ytick',[-3.5:0.5:3.5],'yticklabel',sprintf('% -3.1f\n',[-3.5:0.5:3.5]'));
        title(hc,{'  St. ';'  Dev.';' Units'},'fontsize',10,'fontname','arial');
        set(hc,'position',[0.955 0.05 0.015 ph-0.1]);
    end
    if ismember(ss,[2,3,4,5])
        set(ax2,'yticklabel',[]);
    end
    %if ss==1
        text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{num2str(year_of_interest);toPlot_Titles{ss}},'VerticalAlignment','bottom','HorizontalAlignment','center')
    %else
    %    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,toPlot_Titles{ss},'VerticalAlignment','bottom','HorizontalAlignment','center')
    %end

end
%%
if save_fig_flag
    figout_name = ['IROC_2025_OISST_strip_anom_norm_anom_',sprintf('%4d',year_of_interest),'_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end

