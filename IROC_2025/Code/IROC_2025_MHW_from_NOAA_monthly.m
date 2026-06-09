%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Script to load NOAA MHW Category dataset and create monthly mean and %
%    maximum category within large IROC region and create monthly plots   % 
%    and save figures.                                                    %
%                                                                         %
%                                                                         %
%  Author - Bee Berx                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc

%% set lon and lat extents for area, time_extent for data and data directory
lon_extent = [-80 30];
lat_extent = [ 20 85];
data_dir = ['I:\Data_External\NOAA_MarineHeatwaveWatch\v1.0.1\category\nc\'];
year_of_interest = 2025;
%% set whether or not to save figures
save_fig_flag = 1;

%% set colour maps
MHW_cmap = IROC_2025_fun_MHW_colormap;

%% to save memory, go get data in monthly chunks, get monthly means and max's
MHW_mon_time = [sort(repmat(year_of_interest,12,1)) repmat([1:12]',1,1)];
for yy=year_of_interest
    for mm=1:12
        time_extent = [datenum(MHW_mon_time(mm,1),MHW_mon_time(mm,2),1),...
            datenum(MHW_mon_time(mm,1),MHW_mon_time(mm,2),eomday(MHW_mon_time(mm,1),MHW_mon_time(mm,2)))];
        % go get MHW data using extents defined above
        [MHW_cat,MHW_time,MHW_lon,MHW_lat] = IROC_2025_fun_get_NOAA_MHW_spatial('time_extent',time_extent,...
            'lon_extent', lon_extent, 'lat_extent', lat_extent,...
            'data_dir',data_dir);
        if mm==1;
            MHW_mon_cat_avg = NaN.*zeros(size(MHW_cat,1),size(MHW_cat,2),size(MHW_mon_time,1));
            MHW_mon_cat_max = NaN.*zeros(size(MHW_cat,1),size(MHW_cat,2),size(MHW_mon_time,1));
        end
        idx_mm   = intersect(find(MHW_mon_time(:,1)==yy),find(MHW_mon_time(:,2)==mm));
        MHW_mon_cat_avg(:,:,idx_mm) = mean(MHW_cat(:,:,:),3,'omitnan');
        MHW_mon_cat_max(:,:,idx_mm) = max(MHW_cat(:,:,:),[],3,'omitnan');
        clear MHW_cat MHW_time
        clear idx_full idx_mm
    end;clear mm
end;clear yy

%%
% create plots - to use pcolor, need to shift lon and lat by half a grid
% spacing and need to pad the category with NaNs
pos12 = [0.02 0.68 0.225 0.3;0.255 0.68 0.225 0.3;0.49 0.68 0.225 0.3;0.725 0.68 0.225 0.3;...
    0.02 0.36 0.225 0.3;0.255 0.36 0.225 0.3;0.49 0.36 0.225 0.3;0.725 0.36 0.225 0.3;...
    0.02 0.04 0.225 0.3;0.255 0.04 0.225 0.3;0.49 0.04 0.225 0.3;0.725 0.04 0.225 0.3];

%% plot of mean MHW for each month
lon2plot = [min(MHW_lon(:))-0.025;MHW_lon+0.025];
lat2plot = [min(MHW_lat(:))-0.025;MHW_lat+0.025];
figure
for mm=1:12
    heat2plot = MHW_mon_cat_avg(:,:,mm);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
    s1=subplot(3,4,mm);
    pcolor(lon2plot,lat2plot,heat2plot')
    ax = gca;
    shading flat
    caxis([-0.5 5.5])
    colormap(MHW_cmap)
    IROC_2025_fun_coastGLOB
        set(gca,'XLim',lon_extent,'YLim',lat_extent)
    set(ax,'position',pos12(mm,:));
    if ismember(mm,[1])
        [hc]=colorbar(ax,'eastoutside');
        set(hc,'ytick',[-0.5:1:5.5],'yticklabel',sprintf('% -3.1f\n',[0:1:5]'))
        colormap(MHW_cmap)
        title(hc,'cat','fontsize',10,'fontname','arial')
        set(hc,'position',[0.96 0.06 0.015 0.90])
    end
    if ~ismember(mm,[9,10,11,12])
        set(ax,'xticklabel',[])
    end
    if ~ismember(mm,[1,5,9])
        set(ax,'yticklabel',[])
    end
    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{'mean';datestr(datenum([MHW_mon_time(mm,:),1]),'mmm-yy')},'VerticalAlignment','bottom','HorizontalAlignment','center')
end
if save_fig_flag
    figout_name = ['IROC_2025_MHW_mean_monthly_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end

%% plot of max MHW for each month
lon2plot = [min(MHW_lon(:))-0.025;MHW_lon+0.025];
lat2plot = [min(MHW_lat(:))-0.025;MHW_lat+0.025];
figure
for mm=1:12
    heat2plot = MHW_mon_cat_max(:,:,mm);
    heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
    heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
    s1=subplot(3,4,mm);
    pcolor(lon2plot,lat2plot,heat2plot')
    ax = gca;
    shading flat
    caxis([-0.5 5.5])
    colormap(MHW_cmap)
    IROC_2025_fun_coastGLOB
        set(gca,'XLim',lon_extent,'YLim',lat_extent)
    set(ax,'position',pos12(mm,:));
    if ismember(mm,[1])
        [hc]=colorbar(ax,'eastoutside');
        set(hc,'ytick',[-0.5:1:5.5],'yticklabel',sprintf('% -3.1f\n',[0:1:5]'))
        colormap(MHW_cmap)
        title(hc,'cat','fontsize',10,'fontname','arial')
        set(hc,'position',[0.96 0.06 0.015 0.90])
    end
    if ~ismember(mm,[9,10,11,12])
        set(ax,'xticklabel',[])
    end
    if ~ismember(mm,[1,5,9])
        set(ax,'yticklabel',[])
    end
    text(lon_extent(1)+abs(diff(lon_extent))*0.89,lat_extent(1)+abs(diff(lat_extent))*0.01,{'max';datestr(datenum([MHW_mon_time(mm,:),1]),'mmm-yy')},'VerticalAlignment','bottom','HorizontalAlignment','center')
end
if save_fig_flag
    figout_name = ['IROC_2025_MHW_max_monthly_',datestr(now,'yymmdd'),'.png'];
    set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
        'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
    print(gcf, '-dpng', '-r300', figout_name)
    clear figout_name
end