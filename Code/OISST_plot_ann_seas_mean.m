%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Script to plot annual mean and seasonal means for the selected years %
%                                                                         %
%  Author - Bee Berx                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Work through selected years and make plots
for yy=1:length(selectyear)

    yidx = find(OISST_tvec(:,1)==selectyear(yy))-1;
    yidx(yidx<1)=[];

    if length(yidx)~=12;disp(['insufficient months in year ' sprintf('%4d',selectyear(yy))]);continue;end

    OI_Anom_select = OI_Anom(:,:,yidx);
    OI_NormAnom_select = OI_NormAnom(:,:,yidx);

    OI_ann_Anom_select = mean(OI_Anom_select,3);
    OI_ann_NormAnom_select = mean(OI_NormAnom_select,3);


    OI_sea_Anom_select = NaN.*OI_Anom_select(:,:,1:4);
    OI_sea_NormAnom_select = NaN.*OI_NormAnom_select(:,:,1:4);
    sea_idx = [1,2,3;4,5,6;7,8,9;10,11,12];
    for ss=1:4;
        OI_sea_Anom_select(:,:,ss) = mean(OI_Anom_select(:,:,sea_idx(ss,:)),3);
        OI_sea_NormAnom_select(:,:,ss) = mean(OI_NormAnom_select(:,:,sea_idx(ss,:)),3);
    end

    %% mapping parameters
    %cmap = flipud(cbrewer('div','RdYlBu',22));
    cmap = cat(1,flipud(cbrewer('seq','PuBu',10)),cbrewer('seq','YlOrRd',10));
    cmap(cmap>1)=1;cmap(cmap<0)=0;

    tmp= cbrewer('div','PiYG',3);
    amap = cat(1,flipud(cbrewer('seq','Blues',6)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',6));
    amap(amap>1)=1;amap(amap<0)=0;
    clear tmp

    pl = 0.182;
    ph = 2*pl;
    pos5 = [0.02 0.04 pl ph;0.02+1*(pl+0.005) 0.04 pl ph;0.02+2*(pl+0.005) 0.04 pl ph;...
        0.02+3*(pl+0.005) 0.04 pl ph;0.02+4*(pl+0.005) 0.04 pl ph];


    %% ANOM SST OI SST relative OISST
    OI_toPlot_Anom = cat(3,OI_ann_Anom_select,OI_sea_Anom_select);
    OI_toPlot_NormAnom = cat(3,OI_ann_NormAnom_select,OI_sea_NormAnom_select);
    OI_toPlot_Titles = {'Annual','DJF','MAM','JJA','SON'};

    close all;
    figure(1)
    for ss=1:size(OI_toPlot_Anom,3)
        subplot(1,5,ss)

        lon2plot = [min(OISST_lon(:))-0.025;OISST_lon+0.025];
        lat2plot = [min(OISST_lat(:))-0.025;OISST_lat+0.025];
        heat2plot = OI_toPlot_Anom(:,:,ss);

        heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
        heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
        dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
        dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

        pcolor(lon2plot,lat2plot,heat2plot');shading flat;
        ax = gca;

        caxis([-2.5 2.5])
        colormap(cmap(:,:))
        NWES_IROC_fun_coastGLOB
        set(ax,'position',pos5(ss,:));
        if ismember(ss,[1])
            [hc]=colorbar(ax,'eastoutside');%([.05 .9],.05,CS,CH,'endpiece','no','axfrac',.025,'levels','set','fontsize',10,'fontname','arial');
            set(hc,'ytick',[-2.5:0.5:2.5],'yticklabel',sprintf('% -3.1f\n',[-2.5:0.5:2.5]'))%,'yticklabelrotation',0,'ticklength',[0.01     0.05])
            title(hc,'^o C','fontsize',10,'fontname','arial')
            set(hc,'position',[0.955 0.04 0.015 ph])
        end
        if ~ismember(ss,[1,2,3,4,5])
            set(ax,'xticklabel',[])
        end
        if ~ismember(ss,[1])
            set(ax,'yticklabel',[])
        end
        if ss==1
            text(max(lon2plot(:))-7,min(lat2plot(:))+2,num2str(selectyear(yy)),'VerticalAlignment','middle','HorizontalAlignment','center')
        end
        text(max(lon2plot(:))-7,min(lat2plot(:))+1,OI_toPlot_Titles{ss},'VerticalAlignment','middle','HorizontalAlignment','center')
    end
    NWES_IROC_fun_savepngL(gcf,['..\OISST_AnomSST\SST_Maps_OISST_AnomSST_',num2str(selectyear(yy)),'_YearSeasons.png'])

    %% Standardised ANOM SST OI SST relative OISST
    close all;
    figure(1)
    for ss=1:size(OI_toPlot_Anom,3)
        subplot(1,5,ss)

        lon2plot = [min(OISST_lon(:))-0.025;OISST_lon+0.025];
        lat2plot = [min(OISST_lat(:))-0.025;OISST_lat+0.025];
        heat2plot = OI_toPlot_NormAnom(:,:,ss);

        heat2plot = cat(1,heat2plot,NaN.*heat2plot(1,:));
        heat2plot = cat(2,heat2plot,heat2plot(:,1).*NaN);
        dlon = ceil(double(max(lon2plot)-min(lon2plot))/5);
        dlat = ceil(double(max(lat2plot)-min(lat2plot))/5);

        pcolor(lon2plot,lat2plot,heat2plot');shading flat;
        ax = gca;

        caxis([-3.5 3.5])
        colormap(amap(:,:))
        NWES_IROC_fun_coastGLOB
        set(ax,'position',pos5(ss,:));
        if ismember(ss,[1])
            [hc]=colorbar(ax,'eastoutside');%([.05 .9],.05,CS,CH,'endpiece','no','axfrac',.025,'levels','set','fontsize',10,'fontname','arial');
            set(hc,'ytick',[-3.5:0.5:3.5],'yticklabel',sprintf('% -3.1f\n',[-3.5:0.5:3.5]'))%,'yticklabelrotation',0,'ticklength',[0.01     0.05])
            title(hc,{'St. Dev.','Units'},'fontsize',10,'fontname','arial')
            set(hc,'position',[0.955 0.04 0.015 ph])
        end
        if ~ismember(ss,[1,2,3,4,5])
            set(ax,'xticklabel',[])
        end
        if ~ismember(ss,[1])
            set(ax,'yticklabel',[])
        end
        if ss==1
            text(max(lon2plot(:))-7,min(lat2plot(:))+2,num2str(selectyear(yy)),'VerticalAlignment','middle','HorizontalAlignment','center')
        end
        text(max(lon2plot(:))-7,min(lat2plot(:))+1,OI_toPlot_Titles{ss},'VerticalAlignment','middle','HorizontalAlignment','center')
    end
    NWES_IROC_fun_savepngL(gcf,['..\OISST_AnomSST\SST_Maps_OISST_NormAnomSST_',num2str(selectyear(yy)),'_YearSeasons.png'])

end