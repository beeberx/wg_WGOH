clear all;close all;clc;


DataFolders = {'BSH_blendedSSTgridpoints';
    'BSH_CTD';'BSH_stations';'Cefas_Buoy';'IMR_ShipHydrography';
    'SGMD_ShipBottle';'SGMD_ShipBottleFromCTD';'TI_IBTS_CTD'};


Years = [1930:10:2020]';
YearsTick = datenum(Years,1+0.*Years,1+0.*Years);

cmap = cbrewer('qual','Set1',5);

AllData = [];
for bb=4%1:16

    sel_box = ['Box' sprintf('%02d',bb)];

    for dd=1:size(DataFolders,1)
        fnames = ls(['./',DataFolders{dd},'/',sel_box,'*']);
        if isempty(fnames);continue;end

        if dd==1
            fidd1 = fopen(['./',DataFolders{dd},'/',fnames(1,:)]);
            C = textscan(fidd1,...
                '%s %s %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',5,'TreatAsEmpty','NaN',...
                'delimiter',',');
            fclose(fidd1);

            Date = [C{3},C{4},C{5},C{6},C{7},0.*C{3}];
            Temp = C{12};
            TFlag = C{13};
            Long = C{9};
            Lati = C{8};
            Sound = C{10};
            Press = C{11};
            Salt = NaN.*ones(size(Date,1),1);
            SFlag = 9.*ones(size(Date,1),1);
        else
            fidd1 = fopen(['./',DataFolders{dd},'/',fnames(1,:)]);
            C = textscan(fidd1,...
                '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',5,'TreatAsEmpty','NaN',...
                'delimiter',',');
            fclose(fidd1)

            Date = [C{3},C{4},C{5},C{6},C{7},0.*C{3}];
            Temp = C{12};
            TFlag = C{13};
            Temp(TFlag==9)=NaN;
            Salt = C{14};
            SFlag = C{15};
            Salt(SFlag==9)=NaN;
            Long = C{9};
            Lati = C{8};
            Sound = C{10};
            Press = C{11};
        end

        AllData = cat(1,AllData,[dd*ones(size(Date,1),1),Long,Lati,Date,Sound,Press,Temp,TFlag,Salt,SFlag]);
        clear Long Lati Date Sound Press Temp Tflag Salt Sflag
    end
    AllData(find(ismember(AllData(:,13),[3,4])),12)=NaN;
    AllData(find(ismember(AllData(:,15),[3,4])),14)=NaN;
    DpthsU = [5:10:ceil((max(unique(AllData(~isnan(AllData(:,11)),11)))+1)./10).*10]';
    TimeU  = unique(AllData(:,[4:5]),'rows','stable');TimeU(isnan(TimeU(:,1)),:)=[];
    GriddedData = NaN.*zeros(size(DpthsU,1),size(AllData,2)+2,size(TimeU,1));
    for tt=1:size(TimeU,1)
        for dd=1:size(DpthsU)
            idx = intersect(intersect(find(AllData(:,4)==TimeU(tt,1)),find(AllData(:,5)==TimeU(tt,2))),...
                intersect(find(AllData(:,11)>=DpthsU(dd)-5),find(AllData(:,11)<DpthsU(dd)+5)));
            GriddedData(dd,1:size(AllData,2),tt)=mean(AllData(idx,:),1,'omitnan');
            GriddedData(dd,size(AllData,2)+1,tt)=sum(~isnan(AllData(idx,12)));
            GriddedData(dd,size(AllData,2)+2,tt)=sum(~isnan(AllData(idx,14)));
            clear idx
        end
    end
return
end
return

figure(1),clf;hold on
plot(BSH_SST_Long,BSH_SST_Lati,'b.','color',cmap(1,:));
plot(IMR_HYD_Long,IMR_HYD_Lati,'g.','color',cmap(2,:));
plot(SGMD_HYD_Long,SGMD_HYD_Lati,'r.','color',cmap(3,:));
plot(SGMD_DBHYD_Long,SGMD_DBHYD_Lati,'r.','color',cmap(5,:));
plot(BSH_CTD_Long,BSH_CTD_Lati,'c.','color',cmap(4,:));
bplot_coastNWEU
saveas(gcf,[sel_box,'_map.png'])

% figure(2);clf,hold on,
% plot(datenum(BSH_SST_Date),BSH_SST_Temp,'b.','color',cmap(1,:))
% plot(datenum(IMR_HYD_Date),IMR_HYD_Temp,'g.','color',cmap(2,:))
% plot(datenum(SGMD_HYD_Date),SGMD_HYD_Temp,'r.','color',cmap(3,:))
% plot(datenum(SGMD_DBHYD_Date),SGMD_DBHYD_Temp,'r.','color',cmap(5,:))
% plot(datenum(BSH_CTD_Date),BSH_CTD_Temp,'c.','color',cmap(4,:))
% saveas(gcf,[sel_box,'_map.png'])


idxBSH_CTD = find(BSH_CTD_Press<=5);
idxIMR_HYD = find(IMR_HYD_Press<=5);
idxSGMD_HYD = find(SGMD_HYD_Press<=5);
idxSGMD_DBHYD = find(SGMD_DBHYD_Press<=5);

figure(3),clf,hold on,
p1 = plot(datenum(BSH_SST_Date),BSH_SST_Temp,'b.','markersize',3,'color',cmap(1,:));
p2 = plot(datenum(IMR_HYD_Date(idxIMR_HYD,:)),IMR_HYD_Temp(idxIMR_HYD,:),'g.','color',cmap(2,:));
p3 = plot(datenum(SGMD_HYD_Date(idxSGMD_HYD,:)),SGMD_HYD_Temp(idxSGMD_HYD,:),'r.','color',cmap(3,:));
p3a = plot(datenum(SGMD_DBHYD_Date(idxSGMD_DBHYD,:)),SGMD_DBHYD_Temp(idxSGMD_DBHYD,:),'r.','color',cmap(5,:));
p4 = plot(datenum(BSH_CTD_Date(idxBSH_CTD,:)),BSH_CTD_Temp(idxBSH_CTD,:),'c.','color',cmap(4,:));
set(gca,'xtick',YearsTick,'XTickLabel',datestr(YearsTick,'yy'),'Box','on')
grid on
legend({'BSH SST','IMR HYD','SGMD HYD','SGMD DBHYD','BSH CTD'},'location','southoutside','NumColumns',2)
%set(gca,'xlim',[YearsTick(end-3),now])
set([p2,p3,p4],'markersize',8)
saveas(gcf,[sel_box,'_timeseries.png'])

ymin = min([min(BSH_SST_Date(:,1)),min(BSH_CTD_Date(:,1)),min(IMR_HYD_Date(:,1)),...
    min(SGMD_HYD_Date(:,1)),min(SGMD_DBHYD_Date(:,1))]);
ymax = max([max(BSH_SST_Date(:,1)),max(BSH_CTD_Date(:,1)),max(IMR_HYD_Date(:,1)),...
    max(SGMD_HYD_Date(:,1)),max(SGMD_DBHYD_Date(:,1))]);
nyears = ymax-ymin+1;

MonMean(:,1:2) = [sort(repmat([ymin:ymax]',12,1)),repmat([1:12]',nyears,1)];
MonMean(:,3:7) = NaN;
MonVal = MonMean;
for ii=1:size(MonMean,1)
    idxm = intersect(find(BSH_SST_Date(:,1)==MonMean(ii,1)),find(BSH_SST_Date(:,2)==MonMean(ii,2)));
    if ~isempty(idxm)
        MonMean(ii,3)=mean(BSH_SST_Temp(idxm),'omitnan');
        MonVal(ii,3)=length(idxm);
    end
    idxm = intersect(find(SGMD_HYD_Date(:,1)==MonMean(ii,1)),find(SGMD_HYD_Date(:,2)==MonMean(ii,2)));
    if ~isempty(idxm)
        MonMean(ii,4)=mean(SGMD_HYD_Temp(idxm),'omitnan');
        MonVal(ii,4)=length(idxm);
    end
    idxm = intersect(find(SGMD_DBHYD_Date(:,1)==MonMean(ii,1)),find(SGMD_DBHYD_Date(:,2)==MonMean(ii,2)));
    if ~isempty(idxm)
        MonMean(ii,5)=mean(SGMD_DBHYD_Temp(idxm),'omitnan');
        MonVal(ii,5)=length(idxm);
    end
    idxm = intersect(find(IMR_HYD_Date(:,1)==MonMean(ii,1)),find(IMR_HYD_Date(:,2)==MonMean(ii,2)));
    if ~isempty(idxm)
        MonMean(ii,6)=mean(IMR_HYD_Temp(idxm),'omitnan');
        MonVal(ii,6)=length(idxm);
    end
    idxm = intersect(find(BSH_CTD_Date(:,1)==MonMean(ii,1)),find(BSH_CTD_Date(:,2)==MonMean(ii,2)));
    if ~isempty(idxm)
        MonMean(ii,7)=mean(BSH_CTD_Temp(idxm),'omitnan');
        MonVal(ii,7)=length(idxm);
    end
end


%%


idxclim = intersect(find(MonMean(:,1)>=1991),find(MonMean(:,1)<=2020))
monval = abs(~isnan(MonMean));