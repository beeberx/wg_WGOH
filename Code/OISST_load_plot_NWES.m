%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%    NorthWest European Shelf Region                                      %
%                                                                         %
%    Script to load NOAA OISST Hi Res Sea Surface Temperature Data,       %
%    calculate anomalies (obs - mean in reference period) and normalised  %
%    anomalies (obs - mean, scaled by standard deviation in reference     %
%    period), and create plots of these within region of interest         %
%                                                                         %
%    Key dependencies: cbrewer function for colormap                      %
%                                                                         %
%  Author - Bee Berx                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc

%% USER DEFINED VARIABLES 
% set region of interest, data folder location and climatology ref period
lon_extent = [-20 15];
lat_extent = [45 65];

OISST_datafolder = ['I:\Data_External\NOAA_oisst.v2.highres\'];

clim_ref_period = [1991 2020];

%% set folder structure for output
if ~exist(['..\OISST_AnomSST'],'dir')
    mkdir(['..\OISST_AnomSST\'])
end
if ~exist(['..\OISST_NormAnomSST'],'dir')
    mkdir(['..\OISST_NormAnomSST\'])
end

%% Load OISST data
[OISST,OISST_time,OISST_lon,OISST_lat] = ...
    NWES_IROC_fun_get_OISST_timeseries(OISST_datafolder,[datenum(1981,1,1),floor(now)],lon_extent,lat_extent);
OISST_tvec = datevec(OISST_time);
OISST(OISST<-100)=NaN;

%% Calculate Climatology
[OIClimMean,OIClimSdev,OIClimNval] = NWES_IROC_fun_get_OISST_climatology(OISST_tvec,OISST,clim_ref_period);

%% Calculate anomalies and normalised anomalies
OI_Anom = NaN.*zeros(size(OISST,1),size(OISST,2),size(OISST,3));
OI_NormAnom = NaN.*zeros(size(OISST,1),size(OISST,2),size(OISST,3));
for mm=1:12;
    idxOI =  find(OISST_tvec(:,2)==mm);
    OI_Anom(:,:,idxOI) = OISST(:,:,idxOI) - repmat(OIClimMean(:,:,mm),1,1,length(idxOI));
    OI_NormAnom(:,:,idxOI) = (OISST(:,:,idxOI) - repmat(OIClimMean(:,:,mm),1,1,length(idxOI)))./ ...
        repmat(OIClimSdev(:,:,mm),1,1,length(idxOI));
end

%% Select year or year range to plot
ButtonName = questdlg('Process all years or specific year?', ...
    'Years Question', ...
    'All', 'Range', 'Specific', 'Specific');
tim_chck=datevec(floor(now));
switch ButtonName
    case 'All'
        selectyear=1981:tim_chck(1);
    case 'Range'
        prompt={'Begin Year:','End Year:'};
        name='Input Year Range';
        numlines=1;
        defaultanswer={num2str(1981),num2str(tim_chck(1))};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        selectyear = str2num(answer{1}):str2num(answer{2});
        clear name prompt answer numlines defaultanswer
    case 'Specific'
        prompt={'Selected Year:'};
        name='Input Year';
        numlines=1;
        defaultanswer={num2str(tim_chck(1))};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        selectyear = str2num(answer{1});
        clear name prompt answer numlines defaultanswer
end % switch
clear tim_chck ButtonName

%% Work through selected years and make plots
close all
for yy=1:length(selectyear)
    OI_Anom_select = OI_Anom(:,:,OISST_tvec(:,1)==selectyear(yy));
    OI_NormAnom_select = OI_NormAnom(:,:,OISST_tvec(:,1)==selectyear(yy));


    %% mapping parameters
    %cmap = flipud(cbrewer('div','RdYlBu',22));
    cmap = cat(1,flipud(cbrewer('seq','PuBu',10)),cbrewer('seq','YlOrRd',10));
    cmap(cmap>1)=1;cmap(cmap<0)=0;

    pos12 = [0.02 0.68 0.225 0.3;0.255 0.68 0.225 0.3;0.49 0.68 0.225 0.3;0.725 0.68 0.225 0.3;...
        0.02 0.36 0.225 0.3;0.255 0.36 0.225 0.3;0.49 0.36 0.225 0.3;0.725 0.36 0.225 0.3;...
        0.02 0.04 0.225 0.3;0.255 0.04 0.225 0.3;0.49 0.04 0.225 0.3;0.725 0.04 0.225 0.3];


    %% ANOM SST OI SST relative OISST
    close all;
    figure(1)
    for mm=1:12
        [tim_chck]=intersect(OISST_tvec(:,1:2),[selectyear(yy),mm],'rows');
        if isempty(tim_chck);clear tim_chck;continue;else;clear tim_chck;end;

        subplot(3,4,mm)

        lon2plot = [min(OISST_lon(:))-0.025;OISST_lon+0.025];
        lat2plot = [min(OISST_lat(:))-0.025;OISST_lat+0.025];
        heat2plot = OI_Anom_select(:,:,mm);

        heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
        heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
        dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
        dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

        pcolor(lon2plot,lat2plot,heat2plot');shading flat;
        ax = gca;

        caxis([-2.5 2.5])
        colormap(cmap(:,:))
        NWES_IROC_fun_coastGLOB
        set(ax,'position',pos12(mm,:));
        if ismember(mm,[1])
            [hc]=colorbar(ax,'eastoutside');%([.05 .9],.05,CS,CH,'endpiece','no','axfrac',.025,'levels','set','fontsize',10,'fontname','arial');
            set(hc,'ytick',[-2.5:0.5:2.5],'yticklabel',sprintf('% -3.1f\n',[-2.5:0.5:2.5]'))%,'yticklabelrotation',0,'ticklength',[0.01     0.05])
            title(hc,'^o C','fontsize',10,'fontname','arial')
            set(hc,'position',[0.955 0.06 0.015 0.90])
        end
        if ~ismember(mm,[9,10,11,12])
            set(ax,'xticklabel',[])
        end
        if ~ismember(mm,[1,5,9])
            set(ax,'yticklabel',[])
        end
        text(8.5,50,datestr(datenum(selectyear(yy),mm,1),'mmm-yy'),'VerticalAlignment','middle','HorizontalAlignment','center')
        % title(datestr(datenum(2023,mm,1),'mmm-yy'))
        %
    end
    NWES_IROC_fun_savepngL(gcf,['..\OISST_AnomSST\SST_Maps_OISST_AnomSST_',num2str(selectyear(yy)),'_NWES.png'])

    %% Standardised ANOM SST OI SST relative OISST
    close all;
    figure(1)
    for mm=1:12
        [tim_chck]=intersect(OISST_tvec(:,1:2),[selectyear(yy),mm],'rows');
        if isempty(tim_chck);clear tim_chck;continue;else;clear tim_chck;end;

        subplot(3,4,mm)

        lon2plot = [min(OISST_lon(:))-0.025;OISST_lon+0.025];
        lat2plot = [min(OISST_lat(:))-0.025;OISST_lat+0.025];
        heat2plot = OI_NormAnom_select(:,:,mm);

        heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
        heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
        dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
        dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

        pcolor(lon2plot,lat2plot,heat2plot');shading flat;
        ax = gca;

        caxis([-5 5])
        colormap(cmap(:,:))
        NWES_IROC_fun_coastGLOB
        set(ax,'position',pos12(mm,:));
        if ismember(mm,[1])
            [hc]=colorbar(ax,'eastoutside');%([.05 .9],.05,CS,CH,'endpiece','no','axfrac',.025,'levels','set','fontsize',10,'fontname','arial');
            set(hc,'ytick',[-5:1:5],'yticklabel',sprintf('% -3.1f\n',[-5:1:5]'))%,'yticklabelrotation',0,'ticklength',[0.01     0.05])
            title(hc,{'St. Dev.','Units'},'fontsize',10,'fontname','arial')
            set(hc,'position',[0.965 0.06 0.01 0.875])
        end
        if ~ismember(mm,[9,10,11,12])
            set(ax,'xticklabel',[])
        end
        if ~ismember(mm,[1,5,9])
            set(ax,'yticklabel',[])
        end
        text(8.5,50,datestr(datenum(selectyear(yy),mm,1),'mmm-yy'),'VerticalAlignment','middle','HorizontalAlignment','center')
        % title(datestr(datenum(2023,mm,1),'mmm-yy'))
        %
    end
    NWES_IROC_fun_savepngL(gcf,['..\OISST_NormAnomSST\SST_Maps_OISST_NormAnomSST_',num2str(selectyear(yy)),'_NWES.png'])
end
return

