%
clear all;close all;clc

% define data paths
figpath=[pwd,filesep];

% script to set the timeseries selection for the summary figures
run IROC_2025_SummaryFigure_SelectedTimeseries.m

% script to load data
run IROC_2025_LoadAnnualData.m

%set colour schemes
run IROC_2025_pink_green_colormap_convention.m

%light grey for bar outlines and x-axis at 0
lgrey = [.7 .7 .7];

ylower = 1975;
yhigher = last_year;

pnum = size(IROC_TS,1);
deltaplot = 0;%0.02;
deltaoff = 0.02;
pos_mat = zeros(pnum,4);
ph = floor((0.97-(pnum*deltaplot))/pnum.*100)./100;
pos_mat(:,1)=0.05;
pos_mat(:,2)=deltaoff+([1:pnum]-1)*(deltaplot+ph);
pos_mat(:,3)=0.9;
pos_mat(:,4)=ph;

run IROC_2025_red_blue_colormap_convention.m

plot(Years_IROC,squeeze(Data_IROC(:,2,:)))


idx2plot = intersect(find(Years_IROC>=1951),find(Years_IROC<=2024));
AData = flipud(squeeze(Data_IROC(idx2plot,7,:))');

figh = fun_plot_colourboxes(Years_IROC(idx2plot),[1:size(Data_IROC,3)],AData,...
    flipud(IROC_TS_Codes),pgc,'')
set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,['IROC_ScoreCard_S_',datestr(now,'yyyymmdd'),'.png'],'png')

idx2plot = intersect(find(Years_IROC>=2005),find(Years_IROC<=2024));
figh = fun_plot_colourboxes_with_value(Years_IROC(idx2plot),[1:size(Data_IROC,3)],...
    flipud(squeeze(Data_IROC(idx2plot,7,:))'),flipud(squeeze(Data_IROC(idx2plot,7,:))'),flipud(IROC_TS_Codes),pgc,'')
set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,['IROC_ScoreCard_S_with_values',datestr(now,'yyyymmdd'),'.png'],'png')

