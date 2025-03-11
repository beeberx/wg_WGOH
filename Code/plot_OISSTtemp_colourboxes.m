clear all;close all;clc

load OISST_temp_monthly.mat 
box_defs = readtable('../BoxDefs_NWES.csv');

%define colormap
tmp= cbrewer('div','PiYG',3);
%tmp= cbrewer('div','RdYlBu',3);
%rbc= cbrewer('div','RdYlBu',13);
rbc = cat(1,flipud(cbrewer('seq','Blues',6)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',6));
rbc(rbc>1)=1;rbc(rbc<0)=0;
clear tmp

time_yy = unique(time_mm(:,1));
box_avg_temp_monthly_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
box_std_temperature_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
box_avg_tempclim = NaN.*zeros(size(box_avg_temp_monthly,1),12);
box_std_tempclim = NaN.*zeros(size(box_avg_temp_monthly,1),12);
box_avg_tempanom_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
box_avg_tempanom = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_mm,1));
box_avg_tempnormanom_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
box_avg_tempnormanom = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_mm,1));

for mm=1:12
    idxm = find(time_mm(:,2)==mm);
    idxclim = intersect(intersect(find(time_mm(:,1)>=1991),find(time_mm(:,1)<=2020)),find(time_mm(:,2)==mm));
    box_avg_tempclim(:, mm) = mean(box_avg_temp_monthly(:,idxclim),2);
    box_std_tempclim(:, mm) = std(box_avg_temp_monthly(:,idxclim),[],2);
    box_avg_tempanom(:,idxm)=box_avg_temp_monthly(:,idxm)-repmat(box_avg_tempclim(:,mm),1,length(idxm));
    box_avg_tempnormanom(:,idxm)=(box_avg_temp_monthly(:,idxm)-repmat(box_avg_tempclim(:,mm),1,length(idxm)))./repmat(box_std_tempclim(:,mm),1,length(idxm));
end


for yy=1:size(time_yy,1)
    idxy = find(time_mm(:,1)==time_yy(yy));
    box_avg_temp_monthly_annual(:,yy)=mean(box_avg_temp_monthly(:,idxy),2);
    box_std_temperature_annual(:,yy)=std(box_avg_temp_monthly(:,idxy),[],2);
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
box_avg_tempclim_annual=mean(box_avg_temp_monthly_annual(:,idxclim),2);
box_std_tempclim_annual=std(box_avg_temp_monthly_annual(:,idxclim),[],2);
box_avg_tempanom_annual=box_avg_temp_monthly_annual - repmat(box_avg_tempclim_annual,1,size(box_avg_temp_monthly_annual,2));
box_avg_tempnormanom_annual=box_avg_tempanom_annual ./ repmat(box_std_tempclim_annual,1,size(box_avg_temp_monthly_annual,2));

%% temperature figures
Year(:,1) = time_yy(:,1);
Data = NaN.*zeros(size(Year,1),6,size(box_avg_tempnormanom_annual,1));

for bb=1:size(box_avg_tempnormanom_annual,1)
    Data(:,:,bb)=cat(1,NaN.*squeeze(box_avg_tempnormanom_annual(bb,:)),...
        NaN.*squeeze(box_avg_tempnormanom_annual(bb,:)),NaN.*squeeze(box_avg_tempnormanom_annual(bb,:)),...
        squeeze(box_avg_temp_monthly_annual(bb,:)),squeeze(box_avg_tempanom_annual(bb,:)),...
        squeeze(box_avg_tempnormanom_annual(bb,:)))';
end

idxtemp=[1:size(box_avg_tempnormanom_annual,1)];

ylen=31;
figh1 = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh1,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh1, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxes_all-years.png')

ylen=9;
figh2 = fun_plot_colourboxes_with_value([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',round(squeeze(Data(end-ylen:end,4,idxtemp))'*1000)/1000,...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh2,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxes_last10years_with_text.png')

ylen=9;
figh2b = fun_plot_colourboxes([Year(end-ylen):1:Year(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-ylen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')

set(figh2b,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh2b, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxes_last10years.png')

%%monthly in last 3 years
XData(:,1) = [1:size(time_mm,1)]';
Data = NaN.*zeros(size(XData,1),6,size(box_avg_tempnormanom,1));

for bb=1:size(box_avg_tempnormanom,1)
    Data(:,:,bb)=cat(1,NaN.*squeeze(box_avg_tempnormanom(bb,:)),...
        NaN.*squeeze(box_avg_tempnormanom(bb,:)),NaN.*squeeze(box_avg_tempnormanom(bb,:)),...
        squeeze(box_avg_temp_monthly(bb,:)),squeeze(box_avg_tempanom(bb,:)),...
        squeeze(box_avg_tempnormanom(bb,:)))';
end

mlen=35;
figh3 = fun_plot_colourboxes_with_value([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',round(squeeze(Data(end-mlen:end,4,idxtemp))'*1000)/1000,...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh3,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh3, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxeslast3years_with_text.png')

mlen=35;
figh4 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh4,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh4, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxeslast3years.png')

mlen=(5*12)-1;
figh5 = fun_plot_colourboxes([XData(end-mlen):1:XData(end)],[1:1:length(idxtemp)],...
    squeeze(Data(end-mlen:end,6,idxtemp))',...
    box_defs{:,'Alias'},rbc,'Ocean Temperature')
set(gca,'XTickLabel',datestr(datenum([time_mm(end-mlen:end,1),time_mm(end-mlen:end,2),1+0.*time_mm(end-mlen:end,1)]),'mm-yy'))

set(figh5,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(figh5, '-dpng', '-r300', 'OISST_Tmonthly_NWESboxeslast5years.png')
