clear all;close all;clc

load AMM7_tempsal_monthly.mat 
box_defs = readtable('../BoxDefs_NWES.csv');

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

time_yy = unique(time_mm(:,1));
box_avg_salinity_annual = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_yy,1));
box_std_salinity_annual = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_yy,1));
box_avg_salclim = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),12);
box_std_salclim = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),12);
box_avg_salanom_annual = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_yy,1));
box_avg_salanom = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_mm,1));
box_avg_salnormanom_annual = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_yy,1));
box_avg_salnormanom = NaN.*zeros(size(box_avg_salinity,1),size(box_avg_salinity,2),size(time_mm,1));
box_avg_temperature_annual = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_yy,1));
box_std_temperature_annual = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_yy,1));
box_avg_tempclim = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),12);
box_std_tempclim = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),12);
box_avg_tempanom_annual = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_yy,1));
box_avg_tempanom = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_mm,1));
box_avg_tempnormanom_annual = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_yy,1));
box_avg_tempnormanom = NaN.*zeros(size(box_avg_temperature,1),size(box_avg_temperature,2),size(time_mm,1));

for mm=1:12
    idxm = find(time_mm(:,2)==mm);
    idxclim = intersect(intersect(find(time_mm(:,1)>=1991),find(time_mm(:,1)<=2020)),find(time_mm(:,2)==mm));
    box_avg_salclim(:,:, mm) = mean(box_avg_salinity(:,:,idxclim),3);
    box_std_salclim(:,:, mm) = std(box_avg_salinity(:,:,idxclim),[],3);
    box_avg_salanom(:,:,idxm)=box_avg_salinity(:,:,idxm)-repmat(box_avg_salclim(:,:,mm),1,1,length(idxm));
    box_avg_salnormanom(:,:,idxm)=(box_avg_salinity(:,:,idxm)-repmat(box_avg_salclim(:,:,mm),1,1,length(idxm)))./repmat(box_std_salclim(:,:,mm),1,1,length(idxm));
    box_avg_tempclim(:,:, mm) = mean(box_avg_temperature(:,:,idxclim),3);
    box_std_tempclim(:,:, mm) = std(box_avg_temperature(:,:,idxclim),[],3);
    box_avg_tempanom(:,:,idxm)=box_avg_temperature(:,:,idxm)-repmat(box_avg_tempclim(:,:,mm),1,1,length(idxm));
    box_avg_tempnormanom(:,:,idxm)=(box_avg_temperature(:,:,idxm)-repmat(box_avg_tempclim(:,:,mm),1,1,length(idxm)))./repmat(box_std_tempclim(:,:,mm),1,1,length(idxm));
end


for yy=1:size(time_yy,1)
    idxy = find(time_mm(:,1)==time_yy(yy));
    box_avg_salinity_annual(:,:,yy)=mean(box_avg_salinity(:,:,idxy),3);
    box_std_salinity_annual(:,:,yy)=std(box_avg_salinity(:,:,idxy),[],3);
    box_avg_temperature_annual(:,:,yy)=mean(box_avg_temperature(:,:,idxy),3);
    box_std_temperature_annual(:,:,yy)=std(box_avg_temperature(:,:,idxy),[],3);
end
% method 1: annual anomaly is mean of anomalies in year
% for yy=1:size(time_yy,1)
%     box_avg_salanom_annual(:,:,yy)=mean(box_avg_salanom(:,:,idxy),3);
%     box_avg_salnormanom_annual(:,:,yy)=mean(box_avg_salnormanom(:,:,idxy),3);
%     box_avg_tempanom_annual(:,:,yy)=mean(box_avg_tempanom(:,:,idxy),3);
%     box_avg_tempnormanom_annual(:,:,yy)=mean(box_avg_tempnormanom(:,:,idxy),3);
% end
% method 2: annual anomaly is annual mean rel to clim period mean and std
idxclim = intersect(find(time_yy(:,1)>=1991),find(time_yy(:,1)<=2020));
box_avg_salclim_annual(:,:)=mean(box_avg_salinity_annual(:,:,idxclim),3);
box_std_salclim_annual(:,:)=std(box_avg_salinity_annual(:,:,idxclim),[],3);
box_avg_tempclim_annual(:,:)=mean(box_avg_temperature_annual(:,:,idxclim),3);
box_std_tempclim_annual(:,:)=std(box_avg_temperature_annual(:,:,idxclim),[],3);
box_avg_salanom_annual(:,:,:)=box_avg_salinity_annual - repmat(box_avg_salclim_annual,1,1,size(box_avg_salinity_annual,3));
box_avg_salnormanom_annual(:,:,:)=box_avg_salanom_annual ./ repmat(box_std_salclim_annual,1,1,size(box_avg_salinity_annual,3));
box_avg_tempanom_annual(:,:,:)=box_avg_temperature_annual - repmat(box_avg_tempclim_annual,1,1,size(box_avg_temperature_annual,3));
box_avg_tempnormanom_annual(:,:,:)=box_avg_tempanom_annual ./ repmat(box_std_tempclim_annual,1,1,size(box_avg_temperature_annual,3));

%% temperature figures
Year(:,1) = time_yy(:,1);
Data = NaN.*zeros(size(Year,1),6,size(box_avg_tempnormanom_annual,2));

for bb=1:size(box_avg_tempnormanom_annual,2)
    Data(:,:,bb)=cat(2,NaN.*squeeze(box_avg_tempnormanom_annual(1,bb,:)),...
        NaN.*squeeze(box_avg_tempnormanom_annual(1,bb,:)),NaN.*squeeze(box_avg_tempnormanom_annual(1,bb,:)),...
        squeeze(box_avg_temperature_annual(1,bb,:)),squeeze(box_avg_tempanom_annual(1,bb,:)),...
        squeeze(box_avg_tempnormanom_annual(1,bb,:)));
end

idxtemp=[1:size(box_avg_tempnormanom_annual,2)];

ylen=31;
figh1 = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh1,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh1, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxes_all-years.png')

ylen=9;
figh2 = fun_plot_colourboxes_with_value([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',round(squeeze(Data(end-ylen:end,4,idxtemp))'*1000)/1000,...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh2,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxes_last10years_with_text.png')

ylen=9;
figh2b = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh2b,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2b, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxes_last10years.png')

%%monthly in last 3 years
XData(:,1) = [1:size(time_mm,1)]';
Data = NaN.*zeros(size(XData,1),6,size(box_avg_tempnormanom,2));

for bb=1:size(box_avg_tempnormanom,2)
    Data(:,:,bb)=cat(2,NaN.*squeeze(box_avg_tempnormanom(1,bb,:)),...
        NaN.*squeeze(box_avg_tempnormanom(1,bb,:)),NaN.*squeeze(box_avg_tempnormanom(1,bb,:)),...
        squeeze(box_avg_temperature(1,bb,:)),squeeze(box_avg_tempanom(1,bb,:)),...
        squeeze(box_avg_tempnormanom(1,bb,:)));
end

mlen=35;
figh3 = fun_plot_colourboxes_with_value([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',round(squeeze(Data(end-mlen:end,4,idxtemp))'*1000)/1000,...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh3,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh3, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxeslast3years_with_text.png')

mlen=35;
figh4 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh4,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh4, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxeslast3years.png')

mlen=(5*12)-1;
figh5 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh5,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh5, '-dpng', '-r300', 'AMM7_TSmonthly_T_NWESboxeslast5years.png')

%% salinity figures
Year(:,1) = time_yy(:,1);
Data = NaN.*zeros(size(Year,1),6,size(box_avg_salnormanom_annual,2));

for bb=1:size(box_avg_salnormanom_annual,2)
    Data(:,:,bb)=cat(2,NaN.*squeeze(box_avg_salnormanom_annual(1,bb,:)),...
        NaN.*squeeze(box_avg_salnormanom_annual(1,bb,:)),NaN.*squeeze(box_avg_salnormanom_annual(1,bb,:)),...
        squeeze(box_avg_salinity_annual(1,bb,:)),squeeze(box_avg_salanom_annual(1,bb,:)),...
        squeeze(box_avg_salnormanom_annual(1,bb,:)));
end

idxsal=[1:size(box_avg_salnormanom_annual,2)];

ylen=31;
figh1 = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-ylen:end,6,idxsal))',...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')

set(figh1,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh1, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxes_all-years.png')

ylen=9;
figh2 = fun_plot_colourboxes_with_value([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-ylen:end,6,idxsal))',round(squeeze(Data(end-ylen:end,4,idxsal))'*1000)/1000,...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')

set(figh2,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxes_last10years_with_text.png')

ylen=9;
figh2b = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-ylen:end,6,idxsal))',...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')

set(figh2b,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2b, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxes_last10years.png')

%%monthly in last 3 years
XData(:,1) = [1:size(time_mm,1)]';
Data = NaN.*zeros(size(XData,1),6,size(box_avg_salnormanom,2));

for bb=1:size(box_avg_salnormanom,2)
    Data(:,:,bb)=cat(2,NaN.*squeeze(box_avg_salnormanom(1,bb,:)),...
        NaN.*squeeze(box_avg_salnormanom(1,bb,:)),NaN.*squeeze(box_avg_salnormanom(1,bb,:)),...
        squeeze(box_avg_salinity(1,bb,:)),squeeze(box_avg_salanom(1,bb,:)),...
        squeeze(box_avg_salnormanom(1,bb,:)));
end

mlen=35;
figh3 = fun_plot_colourboxes_with_value([XData(end-mlen):1:XData(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-mlen:end,6,idxsal))',round(squeeze(Data(end-mlen:end,4,idxsal))'*1000)/1000,...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh3,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh3, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxeslast3years_with_text.png')

mlen=35;
figh4 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-mlen:end,6,idxsal))',...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh4,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh4, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxeslast3years.png')

mlen=(5*12)-1;
figh5 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxsal)],...
    squeeze(Data(end-mlen:end,6,idxsal))',...
    box_defs{:,'Alias'},ogc,'Ocean Practical Salinity')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh5,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh5, '-dpng', '-r300', 'AMM7_TSmonthly_S_NWESboxeslast5years.png')