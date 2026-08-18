% seasonal cycle plot
% bars for climatology
% +/- 1 SD dotted black lines
% 3 years - 2022-2024 in different colours
% around a map

clear all;close all;clc

IROC_datafolder = ['../IROC_Timeseries/'];

tseries_files = {'test1.csv','test2.csv','test3.csv'};
tseries_num = length(tseries_files);

h1 = figure;
hh1 = subplot(4,4,[6,7,10,11]);

h2 = figure;
hh2 = subplot(4,4,[6,7,10,11]);

plotmatch = [1,2,3];%variable with which subplots match which time series

for ss=1:tseries_num
    %load in timeseries
    data_filename = tseries_files(ss,:);
    NumHeadLines = 0;bline = '';
    fid = fopen([IROC_datafolder,data_filename]);
    while ~strncmpi(bline,'year',4)
        bline = fgetl(fid);
        NumHeadLines = NumHeadLines +1;
    end
    fid = fclose(fid);clear fid bline
    data = readtable([IROC_datafolder,data_filename],'NumHeaderLines',NumHeadLines-1);

    figure(h1)
    subplot(4,4,plotmatch(ss))
    HB=bar(1:12,clim(:,1),'FaceColor',[0.8 0.8 0.8]); %climatology bar
    hold on
    plot(1:12,dec_clim(:,1),'k.-');% decade mean
    plot(1:12,all_clim_max(:,pp),':','color',[0.2 0.2 0.2]);%max in climatology - note replace with +1SD
    plot(1:12,all_clim_min(:,pp),':','color',[0.2 0.2 0.2]);%min in climatology - note replace with -1SD
    %plot(1:12,ypclim(:,1),'b.-');
    plot(1:12,yclim(:,1),'r.-');


    set(gca,'Ylim',[pmin pmax]); %set fixed limits here
    set(HB,'BaseValue',0);
    set(gca,'XLim',[0.5 12.5]);
    set(gca,'XTicklabel',mlabs,'Fontsize',6);
    text(1,ppp(1)+0.9*(ppp(2)-ppp(1)),str,'Fontsize',6);%str is station name
    clear str s sidx
    a=get(gca,'position');
    set(gca,'position',[a(1) a(2) a(3) a(4)]);
    set(gca,'box','on');
    plot([0 15],[ppp(1) ppp(1)],'k')

end