clear all;close all;clc;

box_defs = readtable('../BoxDefs_NWES.csv');
TimeBoxes = datenum(1985,1,1):datenum(2023,12,31);

cmap = flipud(cbrewer('div','RdYlBu',10));
cmap(cmap<0)=0;cmap(cmap>1)=1;cmap=cmap(5:end,:);


for bb=1:size(box_defs,1)
    x_polygon = [box_defs{bb,"p1_lon"},box_defs{bb,"p2_lon"},box_defs{bb,"p3_lon"},box_defs{bb,"p4_lon"},box_defs{bb,"p1_lon"}];
                    y_polygon = [box_defs{bb,"p1_lat"},box_defs{bb,"p2_lat"},box_defs{bb,"p3_lat"},box_defs{bb,"p4_lat"},box_defs{bb,"p1_lat"}];
                    
    [tmp_cat,tmp_tim,tmp_lon,tmp_lat] = ...
        fun_get_NOAA_MHW_spatial(TimeBoxes,...
        [min(x_polygon) max(x_polygon)],[min(y_polygon) max(y_polygon)]);
    [yy,xx]=meshgrid(double(tmp_lat),double(tmp_lon));
    in = abs(inpolygon(xx,yy,x_polygon,y_polygon));
    in(in==0)=NaN;
    tmp_cat = tmp_cat .*repmat(in,1,1,size(tmp_cat ,3));
    if bb==1;
        BoxesCat50 = NaN.*zeros(size(box_defs,1),size(tmp_cat,3));
        BoxesCat90  = NaN.*zeros(size(box_defs,1),size(tmp_cat,3));
        TimeCat = datevec(tmp_tim);
    end
    tmp2 = [];
    for jj=1:size(tmp_cat,2);
        tmp2 = cat(1,tmp2,squeeze(tmp_cat(:,jj,:)));
    end
    BoxesCat50(bb,:) = prctile(tmp2,50,1,'Method','exact');
    BoxesCat90(bb,:) = prctile(tmp2,90,1,'Method','exact');
    clear tmp2

%     [tmp_oi,tmp_tim,tmp_lon,tmp_lat] = ...
%         fun_get_NOAA_OISST_timeseries([min(TimeBoxes) max(TimeBoxes)],...
%         [min(x_polygon) max(x_polygon)],[min(y_polygon) max(y_polygon)]);
%     if bb==1;
%         BoxesOI50 = NaN.*zeros(size(box_defs,1),size(tmp_oi,3));
%         BoxesOI90  = NaN.*zeros(size(box_defs,1),size(tmp_oi,3));
%         TimeOI = datevec(tmp_tim);
%     end
%     tmp2 = [];
%     for jj=1:size(tmp_oi,2);
%         tmp2 = cat(1,tmp2,squeeze(tmp_oi(:,jj,:)));
%     end
%     BoxesOI50(bb,:) = prctile(tmp2,50,1,'Method','exact');
%     BoxesOI90(bb,:) = prctile(tmp2,90,1,'Method','exact');
%     clear tmp2
% 
%     [tmp_had,tmp_tim,tmp_lon,tmp_lat] = ...
%         fun_get_Hadley_SST_timeseries([datenum(1870,1,1), max(TimeBoxes)],...
%         [min(x_polygon) max(x_polygon)],[min(y_polygon) max(y_polygon)]);
%     tmp_had(tmp_had<-100)=NaN;
%     if bb==1;
%         BoxesHAD50 = NaN.*zeros(size(box_defs,1),size(tmp_had,3));
%         BoxesHAD90  = NaN.*zeros(size(box_defs,1),size(tmp_had,3));
%         TimeHAD = datevec(tmp_tim);
%     end
%     tmp2 = [];
%     for jj=1:size(tmp_had,2);
%         tmp2 = cat(1,tmp2,squeeze(tmp_had(:,jj,:)));
%     end
%     BoxesHAD50(bb,:) = prctile(tmp2,50,1,'Method','exact');
%     BoxesHAD90(bb,:) = prctile(tmp2,90,1,'Method','exact');
%     clear tmp2

    clear tmp_had tmp_tim tmp_lon tmp_lat tmp_oi tmp_cat
end

% %%
% HadClim = NaN.*zeros(size(BoxesHAD50,1),12);
% HadAnom50 = NaN.*BoxesHAD50;
% HadAnom90 = NaN.*BoxesHAD50;
% for mm=1:12;
%     idxt = intersect(find(TimeHAD(:,2)==mm),intersect(find(TimeHAD(:,1)>=1991),find(TimeHAD(:,1)<=2020)));
%     HadClim(:,mm) = mean(BoxesHAD50(:,idxt),2);
%     idxt2 = find(TimeHAD(:,2)==mm);
%     HadAnom50(:,idxt2) = BoxesHAD50(:,idxt2) - repmat(HadClim(:,mm),1,length(idxt2));
%     HadAnom90(:,idxt2) = BoxesHAD90(:,idxt2) - repmat(HadClim(:,mm),1,length(idxt2));
% end
    

% %%
% p = plot(datenum(TimeHAD(end-36:end,:)),HadAnom90(:,end-36:end)','.-');
% set(p(8:end),'marker','o')
% set(gca,'xticklabel',datestr(get(gca,'xtick'),'mm-yy'))
% legend(LEGT,'location','eastoutside')
% grid on

%%
Years = 1985:2024;
Data4Bar50 = NaN.*zeros(size(BoxesCat50,1),length(Years),6);
Data4Bar90 = NaN.*zeros(size(BoxesCat50,1),length(Years),6);
for yy=1:length(Years)
    idx=find(TimeCat(:,1)==Years(yy));
    tmp = BoxesCat50(:,idx);
    tmp3= BoxesCat90(:,idx);
    for cc=1:6
    tmp2 = tmp;tmp2(floor(tmp2)~=cc-1)=NaN;tmp2(floor(tmp2)==cc-1)=1;
    tmp4 =tmp3;tmp4(floor(tmp4)~=cc-1)=NaN;tmp4(floor(tmp4)==cc-1)=1;
    Data4Bar50(:,yy,cc) = sum(tmp2,2,'omitnan');
    Data4Bar90(:,yy,cc) = sum(tmp4,2,'omitnan');
    clear tmp2 tmp4
    end;clear cc
    clear tmp tmp3 idx
end;clear yy
Data4Bar50(isnan(Data4Bar50))=0;
Data4Bar90(isnan(Data4Bar90))=0;

%%
for ss=1:size(Data4Bar90,1)
    figure(1),clf,
    b1 = bar(Years,squeeze(Data4Bar90(ss,:,:)),'stacked','facecolor','flat');
    for k = 1:size(Data4Bar90,3)
        b1(k).CData = cmap(k,:);
    end
    set(gca,'xlim',[1984 2026],'ylim',[0 366])
    legend({'Cat 0','Cat 1','Cat 2','Cat 3','Cat 4','Cat 5'},'location','southwest');
    title([sprintf('%02d',box_defs{ss,1}),'-' char(box_defs{ss,10})])
    fun_MA2020_savepngL(gcf,['MHW_2023_ICES_MHW_90thMHWCategory_inBox_',sprintf('%02d',box_defs{ss,1}),'_',datestr(now,'yy-mmm-dd') '.png'])
end



%% 
function [HeatWave_Category,HeatWave_TimeFromFile,lon,lat] = fun_get_NOAA_MHW_spatial(HeatWave_Time,lon_extent,lat_extent)
% function fun_get_NOAA_MHW_spatial
%
% Extract spatial field of Marine Heatwave Category at a single point.  Data
% from NOAA Daily Marine Heatwave Watch product
% (https://coralreefwatch.noaa.gov/product/marine_heatwave/).  Requires FTP
% download to be up to date in
% [getenv('isilon'),'\Data_External\NOAA_MarineHeatwaveWatch\v1.0.1\category\nc\'].
%
%
% USE:
%       [HeatWave_Category,HeatWave_TimeFromFile,lon,lat] = fun_get_NOAA_MHW_spatial(HeatWave_Time,lon_extent,lat_extent)
%
% INPUT:
%       HeatWave_Time = time for field (matlab datenum format)
%       lon_extent    = western & eastern extent of longitude for field [-180 180]
%       lat_extent    = southern & northern extent of longitude for field [-90 90]
%
%
% OUTPUT:
%       HeatWave_Category     = spatial of heatwave category from NOAA Marine Heatwave Watch product
%       HeatWave_TimeFromFile = time stamp from datafile for field
%       lon                   = longitude of grid extracted
%       lat                   = latitude of grid extracted
%
% DEPENDENCIES:
%   The function needs access to the following
%       DATA: [getenv('isilon'),'\Data_External\NOAA_MarineHeatwaveWatch\v1.0.1\category\nc\']
%
%
% EXAMPLE:
%       [HeatWave_Category,HeatWave_TimeFromFile,lon,lat] = ...
%               fun_get_NOAA_MHW_spatial(floor(now)-3,[-25 15],[45 65]);
%
% WRITTEN BY:
%       Bee Berx, 23-June-2023
% MODIFIED BY:
%
% OCEANOGRAPHY GROUP


NOAA_HeatWaveDir = [getenv('isilon'),'\Data_External\NOAA_MarineHeatwaveWatch\v1.0.1\category\nc\'];

fname = [NOAA_HeatWaveDir '1985\noaa-crw_mhw_v1.0.1_category_19850101.nc'];

lat = ncread(fname,'lat');
lon = ncread(fname,'lon');
idxlon = intersect(find(lon>=lon_extent(1)),find(lon<=lon_extent(2)));
idxlat = intersect(find(lat>=lat_extent(1)),find(lat<=lat_extent(2)));
clear lon lat
lon  = ncread(fname,'lon',[min(idxlon)],[max(idxlon)-min(idxlon)+1]);
lat  = ncread(fname,'lat',[min(idxlat)],[max(idxlat)-min(idxlat)+1]);
clear fname

HeatWave_TimeFromFile = NaN.*HeatWave_Time(1);
HeatWave_Category = NaN.*zeros(length(lon),length(lat),1);

for ff=1:length(HeatWave_Time)
    fname = [NOAA_HeatWaveDir datestr(HeatWave_Time(ff),'yyyy') '\noaa-crw_mhw_v1.0.1_category_' datestr(HeatWave_Time(ff),'yyyymmdd') '.nc'];
    if ~exist(fname,'file')
        disp(['MHW Category File does not exist: ' fname])
        continue
    end
    heatwave_tim = (double(ncread(fname,'time'))/(24*3600))+datenum(1981,1,1,0,0,0);
    heatwave_cat = ncread(fname,'heatwave_category',[min(idxlon),min(idxlat),1],[max(idxlon)-min(idxlon)+1,max(idxlat)-min(idxlat)+1,1]);
    mask = ncread(fname,'mask',[min(idxlon),min(idxlat),1],[max(idxlon)-min(idxlon)+1,max(idxlat)-min(idxlat)+1,1]);
    heatwave_cat(mask~=0)=NaN;
    if ff==1
        HeatWave_Category(:,:,1)=heatwave_cat;
        HeatWave_TimeFromFile(1)=heatwave_tim;
    else
        HeatWave_Category=cat(3,HeatWave_Category,heatwave_cat);
        HeatWave_TimeFromFile=cat(1,HeatWave_TimeFromFile,heatwave_tim);
    end
    clear heatwave_cat mask fname heatwave_tim
end; clear ff
end