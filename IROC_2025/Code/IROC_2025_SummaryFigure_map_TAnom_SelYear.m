% Map of Selected Stations - Summary Figure T Anomalies in selected year
clear all;close all;clc;
edge_W =  -180;
edge_E =   180;
edge_S =    10;
edge_N =    85;


%%
run IROC_2025_SummaryFigure_SelectedTimeseries.m
run IROC_2025_LoadAnnualData.m
run IROC_2025_red_blue_colormap_convention.m
%%
IROC_marker  = cell(length(IROC_TS),1);
IROC_marker(:) = {'o'};
IROC_marker([5,10,13]) = {'s'};
%
IROC_txtcol  = cell(length(IROC_TS),1);
IROC_txtcol(:) = {'k'};
IROC_txtcol([5,10,13]) = {'r'};


%%
prompt={'Enter year for plotting'};
name='Select Year';
numlines=1;
defaultanswer={datestr(now,'yyyy')};
answer=inputdlg(prompt,name,numlines,defaultanswer);

selyear = str2num(answer{1});
clear prompt name numlines defaultanswer answer

%%
selidx = find(Data_IROC(:,1)==selyear);

selcol = fun_lookup_anom_colour(squeeze(Data_IROC(selidx,4,:)),rbc,[-3.5 3.5]);

%%
close all
clf
m_proj('lambert','lon',[-105 70],'lat',[25 85]);hold on

m_coast('patch',[0.75 0.75 0.75],'edgecolor','k');
m_nolakes([0.75 0.75 0.75],[0.75 0.75 0.75])

m_grid('xtick',[60:-60:-120],'ytick',[30:15:85],'XaxisLocation','bottom','YaxisLocation','left');%,'box','fancy'

for ii=1:length(IROC_Longitudes)
    if isnan(selcol(ii));
    m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
        'marker',IROC_marker{ii},'markersize',16,'markerfacecolor',[.3 .3 .3],'markeredgecolor','w')        
    else
    m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
        'marker',IROC_marker{ii},'markersize',16,'markerfacecolor',rbc(selcol(ii),:),'markeredgecolor','k')
    end
end

m_text(-17.5,87,sprintf('%4d',selyear),'fontsize',16,'fontweight','bold','horizontalalignment','center')

fun_plot_collegend_anom(gcf,rbc)

set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,['IROC_2025_Map_TAnom_' sprintf('%4d',selyear),'.png'],'png')
%%
