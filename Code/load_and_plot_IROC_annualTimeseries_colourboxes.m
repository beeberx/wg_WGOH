clear all;close all;clc

IROC_datafolder = ['../IROC_Timeseries/'];

flist = ls([IROC_datafolder,'*Annual*']);

clim_ref_period = [1991 2020];

box_defs = readtable('../BoxDefs_NWES.csv');

%define colormap
%define colormap
tmp= cbrewer('div','PiYG',3);
%tmp= cbrewer('div','RdYlBu',3);
%rbc= cbrewer('div','RdYlBu',13);
rbc = cat(1,flipud(cbrewer('seq','Blues',6)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',6));
rbc(rbc>1)=1;rbc(rbc<0)=0;
clear tmp

tmp= cbrewer('div','PiYG',3);
ogc = cat(1,flipud(cbrewer('seq','Greens',6)),tmp(2,:),tmp(2,:),cbrewer('seq','RdPu',6));
ogc(ogc>1)=1;ogc(ogc<0)=0;
clear tmp

IROC_annual_time = [1890:1:2024]';
IROC_annual_data = NaN.*zeros(size(IROC_annual_time,1),6,size(flist,1));
IROC_annual_name(1:size(flist,1),1) = {' '};
%% consolidate time series (in order listed in directorary)
for ff=1:size(flist,1)
    data_filename = flist(ff,:);
    data_sitename = data_filename(1:regexpi(data_filename,'_Annual')-1);
    IROC_annual_name{ff} = strrep(data_sitename,'_',' ');
    if regexpi(data_filename,'Inflow');continue;end
    NumHeadLines = 0;bline = '';
    fid = fopen([IROC_datafolder,data_filename]);
    while ~strncmpi(bline,'year',4)
        bline = fgetl(fid);
        NumHeadLines = NumHeadLines +1;
    end
    fid = fclose(fid);clear fid bline
    data = readtable([IROC_datafolder,data_filename],'NumHeaderLines',NumHeadLines-1);
    [~,idxT,idxI] = intersect(data{:,"Year"},IROC_annual_time);
    switch size(data,2)
        case 7
            IROC_annual_data(idxI,:,ff) = data{idxT,2:end};
        case 4
            IROC_annual_data(idxI,1:3,ff) = data{idxT,2:end};
        otherwise
            error('number columns not recognised in IROC dataset')
    end
    clear data idxT idxI NumHeadLines data_sitename data_filename
end; clear ff

%% temperature figures
Year(:,1) = IROC_annual_time(:,1);

% idxtemp=[1:size(IROC_annual_data,3)];
idxtemp = [13,1:4,12,6,5,9,10,7,11];

ylen=31;
figh1 = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(IROC_annual_data(end-ylen:end,3,idxtemp))',...
    IROC_annual_name(idxtemp),rbc,'Ocean Temperature')

set(figh1,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh1, '-dpng', '-r300', 'IROC_TimeSeries_Temperature_Last30years.png')

ylen=9;
figh2 = fun_plot_colourboxes_with_value([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(IROC_annual_data(end-ylen:end,3,idxtemp))',round(squeeze(IROC_annual_data(end-ylen:end,1,idxtemp))'*10)/10,...
    IROC_annual_name(idxtemp),rbc,'Ocean Temperature')

set(figh2,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2, '-dpng', '-r300', 'IROC_TimeSeries_Temperature_last10years_with_text.png')

ylen=9;
figh2b = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(IROC_annual_data(end-ylen:end,3,idxtemp))',...
    IROC_annual_name(idxtemp),rbc,'Ocean Temperature')

set(figh2b,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2b, '-dpng', '-r300', 'IROC_TimeSeries_Temperature_last10years.png')


%% salinity figures
%idxsal=[1:size(IROC_annual_data,3)];
idxsal = [13,6,5,9,10,7,11];

ylen=31;
figh1 = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(IROC_annual_data(end-ylen:end,6,idxsal))',...
    IROC_annual_name(idxsal),ogc,'Ocean Practical Salinity')

set(figh1,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh1, '-dpng', '-r300', 'IROC_TimeSeries_Salinity_Last30years.png')

ylen=9;
figh2 = fun_plot_colourboxes_with_value([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(IROC_annual_data(end-ylen:end,6,idxsal))',round(squeeze(IROC_annual_data(end-ylen:end,4,idxsal))'*100)/100,...
    IROC_annual_name(idxsal),ogc,'Ocean Practical Salinity')

set(figh2,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2, '-dpng', '-r300', 'IROC_TimeSeries_Salinity_last10years_with_text.png')

ylen=9;
figh2b = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(IROC_annual_data(end-ylen:end,6,idxsal))',...
    IROC_annual_name(idxsal),ogc,'Ocean Practical Salinity')

set(figh2b,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2b, '-dpng', '-r300', 'IROC_TimeSeries_Salinity_last10years.png')