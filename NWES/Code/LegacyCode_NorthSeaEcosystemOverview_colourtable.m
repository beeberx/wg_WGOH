clear all;close all;clc

addpath([getenv('Working'),'\ICES Working Group Oceanic Hydrography\IROC Matlab']);
% fpath=[getenv('Working'),'\ICES Working Group Oceanic Hydrography\TechnicalReviewMethods\IROC-data-2021-05-14\']
fpath=[getenv('Working'),'\ICES Working Group Oceanic Hydrography\TechnicalReviewMethods\IROC-data-2022-10-06\']


%define colormap
rbc=[    0         0    0.3922
         0         0    0.6961
         0         0    1.0000
    0.2863    0.2837    1.0000
    0.5725    0.5673    1.0000
    0.8588    0.8510    1.0000
    1.0000    0.8510    0.8667
    1.0000    0.5673    0.5778
    1.0000    0.2837    0.2889
    1.0000         0         0
    0.6961         0         0
    0.3922         0         0];
ogc=[         0    0.7137         0
    0.2333    0.8118    0.1373
    0.4667    0.9098    0.2745
    0.6235    0.9399    0.4667
    0.7804    0.9699    0.6588
    0.9373    1.0000    0.8510
    1.0000    0.9451    0.8235
    1.0000    0.8654    0.5490
    1.0000    0.7856    0.2745
    1.0000    0.7059         0
    0.9980    0.5529    0.0020
    0.9961    0.4000    0.0039];


stationfiles = {'North_Sea_HelgolandRoads_Annual';
'North_Sea_SST_Annual';
'NSea_FairIsle_Annual';
'NSea_CooledAtlantic_Annual';
'NSea_Utsira_A_Annual';
'NSea_Utsira_B_Annual';
'Skagerrak_0-10_Surface-water_Timeseries';
'Skagerrak_100-200_Deep-water_Timeseries';
'Skagerrak_600_Bottom-water_Timeseries';
'NSea_Inflow_Annual'};
%Ifremer_Astan_Annual

stationname = strrep(stationfiles,'_',' ')

stationheader = [16,21,22,22,15,15,15,15,15,15];

idxsal = [3,4,5,6];%1
idxvol = size(stationfiles,1);

Year(:,1) = [1950:1:2021];
Data = NaN.*zeros(size(Year,1),6,size(stationfiles,1));
ylen=9;

for istat = 1:size(stationfiles,1)
filename=[fpath,stationfiles{istat},'.csv'];
[timdata]=textread(filename,'','delimiter',',','headerlines',stationheader(istat),'emptyvalue',-99);
[~,ia,ib]=intersect(timdata,Year);
Data(ib,1:size(timdata,2)-1,istat)=timdata(ia,2:size(timdata,2));
clear ia ib timdata filename
end

close all
ax1=axes;hold on,%ax2 = axes;set(ax2,'color','none')
im= imagesc(ax1,[Year(end-ylen) Year(end)],[1 size(Data,3)-4],squeeze(Data(end-ylen:end,3,1:end-4))');im.AlphaData=0.8;
set(ax1,'xlim',[Year(end-ylen)-0.5 Year(end)+0.5],'ylim',[0.5 size(Data,3)-4+0.5],'color','none');
set(ax1,'xtick',[Year(end-ylen):1:Year(end)])
set(ax1,'ytick',[1:size(Data,3)-4],'yticklabel',stationname)
set(ax1,'TickLength',[0 0],'box','off')
set(ax1,'xcolor',[.2 .2 .2],'ycolor',[.2 .2 .2],'fontsize',12);
plot(ax1,repmat([Year(end-ylen)-0.5 Year(end)+0.5],size(Data,3)-4+1,1)',repmat([0.5:1:size(Data,3)-4+0.5]',1,2)','-','linewidth',1,'color',[.2 .2 .2])
plot(ax1,repmat([Year(end-ylen)-0.5:Year(end)+0.5],2,1),repmat([0.5 size(Data,3)-4+0.5],(ylen+2),1)','-','linewidth',1,'color',[.2 .2 .2])
set(ax1,'xaxislocation','top')
set(ax1,'ylim',[1.5 6.5])
caxis([-3 3])
colormap(rbc)
h = colorbar(ax1,'eastoutside','fontsize',12,'fontname','arial');
htick = [-3:0.5:3];
%pos1 = get(ax1,'position');posh = get(h,'position');
set(h,'tickdir','both','ytick',htick,'yticklabel',sprintf('%+4.2f \n',htick),'ycolor',[.2 .2 .2])
ylabel(h,['Standardised Anomalies'])
%'position',[pos1(1)+pos1(3)+0.02 pos1(2) 0.02 pos1(4)],
[cc,~,rr]=size(Data);
rr=rr-4;
for ir = 1:rr
    for ic = cc-ylen:cc
        if isnan(Data(ic,1,ir));
            patch(Year(ic)+[-0.5,0.5,0.5,-0.5,-0.5],ir+[-0.5,-0.5,0.5,0.5,-0.5],'w','edgecolor',[.2 .2 .2])
        %elseif ir==2
        %    patch(Year(ic)+[-0.5,0.5,0.5,-0.5,-0.5],ir+[-0.5,-0.5,0.5,0.5,-0.5],'w','edgecolor',[.2 .2 .2])
        %    text(ax1,Year(ic),ir,sprintf('%4.2f \n',round(Data(ic,1,ir)*100)/100),'verticalalignment','middle','horizontalalignment','center','color','k','fontsize',12)
        else
            text(ax1,Year(ic),ir,sprintf('%4.2f \n',round(Data(ic,1,ir)*100)/100),'verticalalignment','middle','horizontalalignment','center','color','k','fontsize',12)
        end
    end
end
title('Ocean Temperature (^oC)')
set(gcf,'color','w')
fun_MA2020_savepngL(gcf,'IROC_GreaterNorthSea_Timeseries_Temperature.png')


close all
ax1=axes;hold on,%ax2 = axes;set(ax2,'color','none')
im= imagesc(ax1,[Year(end-ylen) Year(end)],[1 length(idxsal)],squeeze(Data(end-ylen:end,6,idxsal))');im.AlphaData=0.8;
set(ax1,'xlim',[Year(end-ylen)-0.5 Year(end)+0.5],'ylim',[0.5 length(idxsal)+0.5],'color','none');
set(ax1,'xtick',[Year(end-ylen):1:Year(end)])
set(ax1,'ytick',[1:length(idxsal)],'yticklabel',stationname(idxsal))
set(ax1,'TickLength',[0 0],'box','off')
set(ax1,'xcolor',[.2 .2 .2],'ycolor',[.2 .2 .2],'fontsize',12);
plot(ax1,repmat([Year(end-ylen)-0.5 Year(end)+0.5],length(idxsal)+1,1)',repmat([0.5:1:length(idxsal)+0.5]',1,2)','-','linewidth',1,'color',[.2 .2 .2])
plot(ax1,repmat([Year(end-ylen)-0.5:Year(end)+0.5],2,1),repmat([0.5 length(idxsal)+0.5],(ylen+2),1)','-','linewidth',1,'color',[.2 .2 .2])
set(ax1,'xaxislocation','top')
set(ax1,'XTickLabelRotation',90)
caxis([-3 3])
colormap(ogc)
h = colorbar(ax1,'eastoutside','fontsize',12,'fontname','arial');
htick = [-3:0.5:3];
%pos1 = get(ax1,'position');posh = get(h,'position');
set(h,'tickdir','both','ytick',htick,'yticklabel',sprintf('%+4.2f \n',htick),'ycolor',[.2 .2 .2])
ylabel(h,['Standardised Anomalies'])
%'position',[pos1(1)+pos1(3)+0.02 pos1(2) 0.02 pos1(4)],
[cc,~,rr]=size(Data(:,:,idxsal));
for ir = 1:rr
    for ic = cc-ylen:cc
        if isnan(Data(ic,4,idxsal(ir)));
            patch(Year(ic)+[-0.5,0.5,0.5,-0.5,-0.5],ir+[-0.5,-0.5,0.5,0.5,-0.5],'w','edgecolor',[.2 .2 .2])
        else
            text(ax1,Year(ic),ir,sprintf('%5.3f \n',round(Data(ic,4,idxsal(ir))*1000)/1000),'verticalalignment','middle','horizontalalignment','center','color','k','fontsize',12,'rotation',90)
        end
    end
end
title('Ocean Practical Salinity')
set(gcf,'color','w')
fun_MA2020_savepngL(gcf,'IROC_GreaterNorthSea_Timeseries_Salinity.png')



vol_anom(:,1) = (Data(:,1,end)-nanmean(Data(:,1,end)))./nanstd(Data(:,1,end));
vol_anom(:,2) = (Data(:,2,end)-nanmean(Data(:,2,end)))./nanstd(Data(:,2,end));
vol_anom(:,3) = (Data(:,3,end)-nanmean(Data(:,3,end)))./nanstd(Data(:,3,end));
volname = {'Inflow';'Outflow';'Net'};

close all
ax1=axes;hold on,%ax2 = axes;set(ax2,'color','none')
im= imagesc(ax1,[Year(end-ylen) Year(end)],[1 size(vol_anom,2)],vol_anom(end-ylen:end,:)');im.AlphaData=0.8;
set(ax1,'xlim',[Year(end-ylen)-0.5 Year(end)+0.5],'ylim',[0.5 size(vol_anom,2)+0.5],'color','none');
set(ax1,'xtick',[Year(end-ylen):1:Year(end)])
set(ax1,'ytick',[1:size(vol_anom,2)],'yticklabel',volname)
set(ax1,'TickLength',[0 0],'box','off')
set(ax1,'xcolor',[.2 .2 .2],'ycolor',[.2 .2 .2],'fontsize',12);
plot(ax1,repmat([Year(end-ylen)-0.5 Year(end)+0.5],size(vol_anom,2)+1,1)',repmat([0.5:1:size(vol_anom,2)+0.5]',1,2)','-','linewidth',1,'color',[.2 .2 .2])
plot(ax1,repmat([Year(end-ylen)-0.5:Year(end)+0.5],2,1),repmat([0.5 size(vol_anom,2)+0.5],(ylen+2),1)','-','linewidth',1,'color',[.2 .2 .2])
set(ax1,'xaxislocation','top')
caxis([-3 3])
colormap(ogc)
h = colorbar(ax1,'eastoutside','fontsize',12,'fontname','arial');
htick = [-3:0.5:3];
%pos1 = get(ax1,'position');posh = get(h,'position');
set(h,'tickdir','both','ytick',htick,'yticklabel',sprintf('%+4.2f \n',htick),'ycolor',[.2 .2 .2])
ylabel(h,['Standardised Anomalies'])
%'position',[pos1(1)+pos1(3)+0.02 pos1(2) 0.02 pos1(4)],
[cc,~,rr]=size(Data(:,:,idxvol));
for ir=1:3
for ic=cc-ylen:cc
    text(ax1,Year(ic),ir,sprintf('%5.2f \n',round(Data(ic,ir,idxvol)*100)/100),'verticalalignment','middle','horizontalalignment','center','color','k','fontsize',12)
end
end
title('North Sea Volume Transport')
set(gcf,'color','w')
fun_MA2020_savepngL(gcf,'IROC_GreaterNorthSea_Timeseries_Transport.png')

return

