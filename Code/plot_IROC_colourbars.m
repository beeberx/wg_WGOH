% bar plot of time series - full length or some other limit
% put value of the long term mean at 0
% include bars that are coloured by anomaly
% similar to GRL paper

clear all;close all;clc

IROC_datafolder = ['../IROC_Timeseries/'];

% find a list of all the Annual files
flist = ls([IROC_datafolder,'*Annual*']);

% set the climatology period
clim_ref_period = [1991 2020];

%define colormaps
% Blue-Red rbc
tmp= cbrewer('div','PiYG',3);
rbc = cat(1,flipud(cbrewer('seq','Blues',6)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',6));
rbc(rbc>1)=1;rbc(rbc<0)=0;
clear tmp

% Green-Pink pgc
tmp= cbrewer('div','PiYG',3);
pgc = cat(1,flipud(cbrewer('seq','Greens',6)),tmp(2,:),tmp(2,:),cbrewer('seq','RdPu',6));
pgc(pgc>1)=1;pgc(pgc<0)=0;
clear tmp

% create empty variables to load in annual time series
IROC_annual_time = [1890:1:2024]';
IROC_annual_data = NaN.*zeros(size(IROC_annual_time,1),6,size(flist,1));
IROC_annual_name(1:size(flist,1),1) = {' '};

% consolidate time series (in order listed in directory)
for ff=1:size(flist,1)
    data_filename = flist(ff,:);
    data_sitename = data_filename(1:regexpi(data_filename,'_Annual')-1);
    IROC_annual_name{ff} = strrep(data_sitename,'_',' ');
    if ~isempty(regexpi(IROC_annual_name{ff},'inflow')) | ~isempty(regexpi(IROC_annual_name{ff},'ice'))
        continue
    end
    NumHeadLines = 0;bline = repmat(' ',1,15);
    fid = fopen([IROC_datafolder,data_filename]);
    %     while ~strncmpi(bline,'year',4)
    while isempty(regexpi(bline,'year'))
        bline = fgetl(fid);
        if length(bline)>15
            bline = bline(1:15);
        end
        NumHeadLines = NumHeadLines +1;
    end
    fid = fclose(fid);clear fid bline
    data = readtable([IROC_datafolder,data_filename],'NumHeaderLines',NumHeadLines-1);
    [~,idxT,idxI] = intersect(data{:,1},IROC_annual_time);
    %switch for those time series with incorrect header structure
    switch size(data,2)
        case 7
            IROC_annual_data(idxI,:,ff) = data{idxT,2:end};
        case 10
            IROC_annual_data(idxI,:,ff) = data{idxT,2:7};
        case 4
            IROC_annual_data(idxI,1:3,ff) = data{idxT,2:end};
        case 5
            IROC_annual_data(idxI,2:3,ff) = data{idxT,2:3};
            IROC_annual_data(idxI,5:6,ff) = data{idxT,4:5};
        otherwise
            error('number columns not recognised in IROC dataset')
    end
    clear data idxT idxI NumHeadLines data_sitename data_filename
end; clear ff

%% temperature figures
Year(:,1) = IROC_annual_time(:,1);

% idxtemp=[1:size(IROC_annual_data,3)];
% idxtemp = [13,1:4,12,6,5,9,10,7,11];
idxtemp = [13,1:4,12,6,5,9,10,7,11];
% idxtemp = [6,5,9,10,7,11];

ymin = 1970;
ymax = 2025;

pnum = length(idxtemp);
pos_mat = zeros(pnum,4);
ph = floor((0.97-(pnum*0.02))/pnum.*100)./100;
pos_mat(:,1)=0.05;
pos_mat(:,2)=0.02+([1:pnum]-1)*(0.02+ph);
pos_mat(:,3)=0.9;
pos_mat(:,4)=ph;

%barval = 't_ano';
barval = 't_nor';
close all
for ss=1:length(idxtemp);
    xdata = Year;
    tdata = squeeze(IROC_annual_data(:,1,idxtemp(ss)));
    lmean = mean(tdata(intersect(find(xdata>=1991),find(xdata<=2020))),'omitnan');
    ydata = squeeze(IROC_annual_data(:,2,idxtemp(ss)));
    switch barval
        case {'t_ano'}
            t_ext = min([abs(floor(min(ydata))),ceil(max(ydata))]);
            t_tic = [-1*t_ext:1:t_ext];
            t_lab = sprintf('% -4.1f\n',cat(1,[-1*t_ext:-1]',lmean,...
                [1:1*t_ext]'));
        case {'t_nor'}
            t_ext = 3.5;
            t_tic = [-3:1:3];
            t_lab = sprintf('% -1d\n',t_tic);
    end
    zdata = squeeze(IROC_annual_data(:,3,idxtemp(ss)));
    %ax = subplot(ceil(length(idxtemp)/2),2,ss);hold on
    subplot(pnum,1,ss);hold on
    ax(ss)=gca;
    plot(ax(ss), [ymin ymax],[0 0],'k-','LineWidth',0.5)
    set(ax(ss),'YTickLabelMode','manual','YTick',t_tic,'YTickLabel',t_lab,...
        'ylim',[-1*t_ext t_ext])
    set(ax(ss),'Xlim',[ymin ymax],'XTicklabel',[],'XAxisLocation','origin')
    set(ax(ss),'Color','none')
    %ylabel(num2str(ss))
    if mod(ss,2)==1
        set(gca,'YaxisLocation','left','Box','off')
        text(ymin+0.5,t_ext,IROC_annual_name{idxtemp(ss)},'HorizontalAlignment','left')
    else
        set(gca,'YaxisLocation','right','Box','off')
        text(ymax-0.5,t_ext,IROC_annual_name{idxtemp(ss)},'HorizontalAlignment','right')
    end
    for yy=1:length(xdata)
        if isnan(ydata(yy)) || isnan(zdata(yy));continue;end
        switch barval
            case {'t_ano'}
                h=bar(xdata(yy),ydata(yy),1.0);
            case {'t_nor'}
                h=bar(xdata(yy),zdata(yy),1.0);
        end
        ind=floor(zdata(yy)*2)+7;
        if (ind<1);ind=1; end
        if (ind>14);ind=14; end
        set(h,'FaceColor',rbc(ind,:),'linestyle','none');
    end
    switch barval
        case {'t_ano'}
    plot(ax(ss),xdata,ydata,'-k.','linewidth',0.5)
        case {'t_nor'}
            plot(ax(ss),xdata,zdata,'-k.','linewidth',0.5)
    end
end
for ss=1:length(idxtemp);
    set(ax(ss),'Position',pos_mat(abs(ss-(pnum+1)),:));
end
print(gcf, '-dpng', '-r300',['temperature_bars.png'])
%% salinity figures

idxsal = [6,5,9,10,7,11];

ymin = 1970;
ymax = 2025;

pnum = length(idxsal);
pos_mat = zeros(pnum,4);
ph = floor((0.97-(pnum*0.02))/pnum.*100)./100;
pos_mat(:,1)=0.05;
pos_mat(:,2)=0.02+([1:pnum]-1)*(0.02+ph);
pos_mat(:,3)=0.9;
pos_mat(:,4)=ph;

%barval = 't_ano';
 barval = 't_nor';
close all
for ss=1:length(idxsal);
    xdata = Year;
    tdata = squeeze(IROC_annual_data(:,4,idxsal(ss)));
    lmean = mean(tdata(intersect(find(xdata>=1991),find(xdata<=2020))),'omitnan');
    ydata = squeeze(IROC_annual_data(:,5,idxsal(ss)));
    zdata = squeeze(IROC_annual_data(:,6,idxsal(ss)));
    switch barval
        case {'t_ano'}
            t_ext = min([abs(floor(min(ydata.*10))),ceil(max(ydata.*10))])./10;
            t_tic = [-1*t_ext:0.1:t_ext];
            t_lab = sprintf('% 6.2f\n',cat(1,[-1*t_ext:0.1:-0.1]',lmean,...
                [0.1:0.1:1*t_ext]'));
        case {'t_nor'}
            t_ext = 3.5;
            t_tic = [-3:1:3];
            t_lab = sprintf('% -1d\n',t_tic);
    end
    %ax = subplot(ceil(length(idxsal)/2),2,ss);hold on
    subplot(pnum,1,ss);hold on
    ax(ss)=gca;
    plot(ax(ss), [ymin ymax],[0 0],'k-','LineWidth',0.5)
    set(ax(ss),'YTickLabelMode','manual','YTick',t_tic,'YTickLabel',t_lab,...
        'ylim',[-1*t_ext t_ext])
    set(ax(ss),'Xlim',[ymin ymax],'XTicklabel',[],'XAxisLocation','origin')
    set(ax(ss),'Color','none')
    %ylabel(num2str(ss))
    if mod(ss,2)==1
        set(gca,'YaxisLocation','left','Box','off')
        text(ymin+0.5,t_ext,IROC_annual_name{idxsal(ss)},'HorizontalAlignment','left')
    else
        set(gca,'YaxisLocation','right','Box','off')
        text(ymax-0.5,t_ext,IROC_annual_name{idxsal(ss)},'HorizontalAlignment','right')
    end
    for yy=1:length(xdata)
        if isnan(ydata(yy)) || isnan(zdata(yy));continue;end
        switch barval
            case {'t_ano'}
                h=bar(xdata(yy),ydata(yy),1.0);
            case {'t_nor'}
                h=bar(xdata(yy),zdata(yy),1.0);
        end
        ind=floor(zdata(yy)*2)+7;
        if (ind<1);ind=1; end
        if (ind>14);ind=14; end
        set(h,'FaceColor',pgc(ind,:),'linestyle','none');
    end
    switch barval
        case {'t_ano'}
    plot(ax(ss),xdata,ydata,'-k.','linewidth',0.5)
        case {'t_nor'}
            plot(ax(ss),xdata,zdata,'-k.','linewidth',0.5)
    end
end
for ss=1:length(idxsal);
    set(ax(ss),'Position',pos_mat(abs(ss-(pnum+1)),:));
end

print(gcf, '-dpng', '-r300',['salinity_bars.png'])