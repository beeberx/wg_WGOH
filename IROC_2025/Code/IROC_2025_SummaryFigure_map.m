% Map of Selected Stations - Summary Figure
clear all;close all;clc;
edge_W =  -180;
edge_E =   180;
edge_S =    10;
edge_N =    85;

fname = [getenv('Bathy') '\GEBCO_2024\GEBCO_2024_sub_ice_topo.nc'];

lon = ncread(fname,'lon');
lat = ncread(fname,'lat');

idxlon = intersect(find(lon>=edge_W-5),find(lon<=edge_E+5));
idxlat = intersect(find(lat>=edge_S-5),find(lat<=edge_N+5));

istride = 20;
eta = ncread(fname,'elevation',[idxlon(1) idxlat(1)],[Inf Inf],[istride istride]);
lon = ncread(fname,'lon',[idxlon(1)],[Inf],[istride]);
lat = ncread(fname,'lat',[idxlat(1)],[Inf],[istride]);

clear idxlon idxlat
%%
%load('H:\Working_Projects\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\wg_WGOH\IROC_2025\RegionBoundaries\Code\IROC_2025_regions.mat')


%%
run IROC_2025_SummaryFigure_SelectedTimeseries.m
run IROC_2025_LoadAnnualData.m

%%
IROC_marker  = cell(length(IROC_TS),1);
IROC_marker(:) = {'o'};
IROC_marker([5,10,13]) = {'s'};
%
IROC_txtcol  = cell(length(IROC_TS),1);
IROC_txtcol(:) = {'k'};
IROC_txtcol([5,10,13]) = {'r'};

%%
close all
clf
% m_proj('mercator','lon',[edge_W,edge_E],'lat',[edge_S,edge_N]);
%m_proj('Stereographic','longitudes',[-37],'latitudes',[60],'radius',[45],'rect','on');
m_proj('lambert','lon',[-105 70],'lat',[10 85]);

%bathymetry map
cmap_ocean = flipud(cbrewer('seq','Blues',101));
cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;
[CS,CH]=m_contourf(lon,lat,double(eta)',[-10000:1000:1000 1000:100:0],'edgecolor','none');
colormap([cmap_ocean]);
hold on
caxis([-10000 10])

% coldef_land = [0 0.3059 0.1059];
% m_gshhs_i('patch',coldef_land,'edgecolor','none')
m_coast('patch',[0.75 0.75 0.75],'edgecolor','k');
m_nolakes([0.75 0.75 0.75],[0.75 0.75 0.75])

% m_grid('linestyle','none','tickdir','out','linewidth',3);
m_grid('xtick',[60:-60:-120],'ytick',[30:15:85],'XaxisLocation','bottom','YaxisLocation','left');%,'box','fancy'

for ii=1:length(IROC_Longitudes)
    %     m_text(IROC_Longitudes(ii),IROC_Latitudes(ii),IROC_TS_Codes{ii},...
    %         'backgroundcolor','w','color','k','edgecolor','k','fontsize',12,...
    %         'horizontalalignment','center','verticalalignment','middle')
    switch IROC_marker{ii}
        case 'o'
            m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
                'marker',IROC_marker{ii},'markersize',15,'markerfacecolor','w','markeredgecolor','k')
        case 's'
            m_plot(IROC_Longitudes(ii),IROC_Latitudes(ii),...
                'marker',IROC_marker{ii},'markersize',17,'markerfacecolor','w','markeredgecolor','k')
    end
    m_text(IROC_Longitudes(ii),IROC_Latitudes(ii),num2str(ii),...
        'color',IROC_txtcol{ii},'fontsize',10,...
        'horizontalalignment','center','verticalalignment','middle')
end

axTxt = axes;hold(axTxt,'on');
set(axTxt,'xlim',[0 1],'ylim',[0 1],'color','none','position',[0 0 1 1],'Visible','off')
for ii=1:7;
    if ~isempty(regexpi(IROC_TS_Codes{ii},')'))
        txtlab = IROC_TS_Codes{ii}(regexpi(IROC_TS_Codes{ii},')')+2:end);
    else
        txtlab = IROC_TS_Codes{ii};
    end
    text(axTxt,0.125,0.98-3*(ii/100),[sprintf('%-2d',ii),': ',txtlab],'fontsize',12)
end
for ii=8:10;
    if ~isempty(regexpi(IROC_TS_Codes{ii},')'))
        txtlab = IROC_TS_Codes{ii}(regexpi(IROC_TS_Codes{ii},')')+2:end) 
    else
        txtlab = IROC_TS_Codes{ii};
    end
    text(axTxt,0.62,0.37-3*((ii-7)/100),[sprintf('%-2d',ii),': ',txtlab],'fontsize',12)
end
for ii=11:17;
    if ~isempty(regexpi(IROC_TS_Codes{ii},')'))
        txtlab = IROC_TS_Codes{ii}(regexpi(IROC_TS_Codes{ii},')')+2:end) 
    else
        txtlab = IROC_TS_Codes{ii};
    end
    text(axTxt,0.725,0.98-3*((ii-10)/100),[sprintf('%-2d',ii),': ',txtlab],'fontsize',12)
end


set(gcf,'position',get(0, 'Screensize'),'color','w', 'MenuBar', 'none')
F    = getframe(gcf);
imwrite(F.cdata,'IROC_2025_Map_Timeseries_Positions.png','png')
%%
