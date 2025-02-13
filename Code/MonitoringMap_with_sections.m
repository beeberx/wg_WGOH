clear all;close all;clc;

filedir = '../Stations_and_Sections/';

flist = ls([filedir,'*.csv']);

bmarks = {'.','o','x','+','s','^'};
bcols = cbrewer('qual','Dark2',6);

%% All stations on m_map. requires cbrewer

bcols = cat(1,cbrewer('qual','Set1',9),cbrewer('qual','Set2',7),cbrewer('qual','Dark2',8),cbrewer('qual','Set3',4));

LEGH = [];
LEGT = {};

figure(1);clf;
m_proj('mercator','lat',[50 65],'long',[-22 10]);
m_elev('contour',[-5000,-1000,-500,-200,-100,-50,-25],'edgecolor',[240,237,233]/255)
m_gshhs_i('patch', [240,237,233]/255,'edgecolor',[0 0 0]/255);
hold on
for ff=1:size(flist,1)
    fname = strtrim(flist(ff,:));
    data = readtable([filedir,fname]);
    numsect = max(floor(data.StationNumber/100))+1;

    for ss=1:numsect
        idxss = find(floor(data.StationNumber./100)==ss-1);
        h = m_plot(data.DecimalDegreesLongitude(idxss),data.DecimalDegreesLatitude(idxss),'.');
        set(h,'marker','o','markerfacecolor',bcols(ff,:),'MarkerEdgeColor',bcols(ff,:),...
            'color',bcols(ff,:),'markersize',3,'LineStyle','--');
        if ~isempty(regexpi(fname,'IROC'))
            set(h,'LineStyle','none','markersize',5,'markerfacecolor','k','markeredgecolor','r')
        end
        if ss==1;
            LEGH=cat(1,LEGH,h);
            LEGT = cat(1,LEGT,cellstr(fname(1:regexpi(fname,'.csv')-1)));
        end

    end
end;clear ff
m_grid('xtick',[-20:5:10],'ytick',[50:5:65],...
    'box', 'fancy','gridcolor',[.8 .8 .8],'linestyle','-','fontsize',12,'fontname','Arial')
legend(LEGH,LEGT,'location','southoutside','NumColumns',3,'interpreter','none')

set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(gcf, '-dpng', '-r300', 'WGOH-NWES_all_stations.png')  