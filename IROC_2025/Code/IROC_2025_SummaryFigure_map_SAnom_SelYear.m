function IROC_2025_SummaryFigure_map_SAnom_SelYear(selyear_sumfig)
% Map of Selected Stations - Summary Figure S Anomalies in selected year
edge_W =  -180;
edge_E =   180;
edge_S =    10;
edge_N =    85;


%%
run IROC_2025_SummaryFigure_SelectedTimeseries.m
run IROC_2025_LoadAnnualData.m
run IROC_2025_pink_green_colormap_convention.m
%%
IROC_marker  = cell(length(IROC_TS),1);
IROC_marker(:) = {'o'};
IROC_marker([5,10,13]) = {'s'};
%
IROC_txtcol  = cell(length(IROC_TS),1);
IROC_txtcol(:) = {'k'};
IROC_txtcol([5,10,13]) = {'r'};


% removed because made to function
% %%
% prompt={'Enter year for plotting'};
% name='Select Year';
% numlines=1;
% defaultanswer={datestr(now,'yyyy')};
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% selyear_sumfig = str2num(answer{1});
% clear prompt name numlines defaultanswer answer

%%
selidx = find(Data_IROC(:,1)==selyear_sumfig);

selcol = fun_lookup_anom_colour(squeeze(Data_IROC(selidx,7,:)),pgc,[-3.5 3.5]);

%%
close all
clf
% m_proj('lambert','lon',[-105 70],'lat',[25 85]);hold on
m_proj('lambert','lon',[-80 30],'lat',[20 85]);hold on

m_coast('patch',[0.75 0.75 0.75],'edgecolor','k');
m_nolakes([0.75 0.75 0.75],[0.75 0.75 0.75])

m_grid('xtick',[-80,-60:30:30],'ytick',[20,30:15:75,85],'XaxisLocation','bottom',...
    'YaxisLocation','left','tickdir','out','fontsize',14);%,'box','fancy'

for ii=1:length(IROC_Longitudes)
    switch IROC_marker{ii}
        case 'o'
            msize = 19;
        case 's'
            msize = 21;
    end
    if isnan(selcol(ii));
        m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
            'marker',IROC_marker{ii},'markersize',msize,'markerfacecolor',[.6 .6 .6],'markeredgecolor','r')
    else
        m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
            'marker',IROC_marker{ii},'markersize',msize,'markerfacecolor',pgc(selcol(ii),:),'markeredgecolor','k')
    end
end

m_text(-17.5,87,sprintf('%4d',selyear_sumfig),'fontsize',20,'fontweight','bold','horizontalalignment','center')

axl = fun_plot_collegend_anom(gcf,pgc,12);
set(axl,'position',[0.025 0.03 0.95 0.03])

set(gcf,'position',IROC_2025_fun_framesize(),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,['IROC_2025_Map_SAnom_' sprintf('%4d',selyear_sumfig),'.png'],'png','XResolution',1200)
%%
