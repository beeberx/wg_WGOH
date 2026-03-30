%script extract_subset_HADISST1NA_LabradorSea
close all 
clear all
%%code originally used to pick out data for Gijon Poster
%%updated for IROC - Labrador Sea -9 grid points

%BB%cd([getenv('External'),'\HADISST1'])

%positions of in-situ data
INSITU=[56.5 -52.5] %Labrador Sea

        H = IROC_fun_loadHADISSTdataset_NetCDF('I:\Data_External\HADISST1\Datafiles\RAW',...
            [INSITU(2)-1 INSITU(2)+1],[INSITU(1)-1 INSITU(1)+1],[1991 2020]);

%extract timeseries
%find nearest grid cells
[~,ind1]=min(abs((H.lat)-INSITU(1,1)));
[~,ind2]=min(abs((H.lon)-INSITU(1,2)));

latind=ind1(1); %use first value
lonind=ind2(1); %use first value
latind=latind-1:latind+1;
lonind=lonind-1:lonind+1;
[XX,YY]=meshgrid(latind,lonind);

HADPOS(:,1)=H.lat(XX(:));
HADPOS(:,2)=H.lon(YY(:));

clear ind*

%extract selected datasets
HADISST_LAB.decyear=H.decyear;
HADISST_LAB.gdate=H.gdate;
HADISST_LAB.sstall=H.sst(lonind,latind,:);
[rr,cc,tt]=size(HADISST_LAB.sstall);
HADISST_LAB.sstall=reshape(HADISST_LAB.sstall,[tt,rr*cc]);
HADISST_LAB.sst=mean(HADISST_LAB.sstall,2,'omitnan');    

HADISST_LAB.mlat = mean(HADPOS(:,1));
HADISST_LAB.mlon = mean(HADPOS(:,2));

%calculate climatology. 
%uses clim_per 
clim_per = [1991 2020];
indyear=intersect(find(HADISST_LAB.decyear>clim_per(1)),find(HADISST_LAB.decyear<clim_per(1)));
nyrs=HADISST_LAB.gdate(end,1)-HADISST_LAB.gdate(1,1)+1;
HADISST_LAB.clim_mean = NaN.*zeros(12,1);
HADISST_LAB.clim_sdev = NaN.*zeros(12,1);
HADISST_LAB.clim_diff_anom = NaN.*zeros(size(HADISST_LAB.sst,1),1);
HADISST_LAB.clim_norm_anom = NaN.*zeros(size(HADISST_LAB.sst,1),1);
for mm=1:12;
    idx_in_clim = intersect(find(HADISST_LAB.gdate(:,2)==mm),...
        intersect(find(HADISST_LAB.gdate(:,1)>=clim_per(1)),find(HADISST_LAB.gdate(:,1)<=clim_per(2))));
    idx_in_mm = find(HADISST_LAB.gdate(:,2)==mm);
    HADISST_LAB.clim_mean(mm,1)=mean(HADISST_LAB.sst(idx_in_clim,1),1,'omitnan');
    HADISST_LAB.clim_sdev(mm,1)=std(HADISST_LAB.sst(idx_in_clim,1),[],1,'omitnan');
    HADISST_LAB.clim_diff_anom(idx_in_mm,1) = (HADISST_LAB.sst(idx_in_mm,1)-...
        repmat(HADISST_LAB.clim_mean(mm),size(idx_in_mm,1),1));
    HADISST_LAB.clim_norm_anom(idx_in_mm,1) = (HADISST_LAB.sst(idx_in_mm,1)-...
        repmat(HADISST_LAB.clim_mean(mm,1),size(idx_in_mm,1),1))./...
        repmat(HADISST_LAB.clim_sdev(mm,1),size(idx_in_mm,1),1);
end


%% Calculate Annual Information from extended dataset
yr=0;
year=(HADISST_LAB.gdate(:,1));

%shift year to account for the season starting in December
%interval is months so moving back 1, makes 1982 start in December 1981

for iyear=1900:max(year) %update year
    ind=find(year==iyear);%Jan-Dec
    if length(ind)~=12;continue;end
    ind2=ind-1; %Dec-Nov
    yr=yr+1;
    HADISST_LAB.ann(yr)=iyear+0.5;
    
    data1=HADISST_LAB.clim_norm_anom(ind);
    data2=HADISST_LAB.clim_norm_anom(ind2);
    data4=HADISST_LAB.sst(ind); %for annual

    time1 = HADISST_LAB.gdate(ind,:);
    time2 = HADISST_LAB.gdate(ind2,:);
    
    HADISST_LAB.annual_range(yr)=max(data1)-min(data1);
    [HADISST_LAB.annual_mindat(yr),wmin]=min(data1);
    HADISST_LAB.annual_wmin(yr)= week(datetime(time1(wmin,:)),'weekofyear'); %converting time to weeknumber
    [HADISST_LAB.annual_maxdat(yr),wmax]=max(data1);
    HADISST_LAB.annual_wmax(yr)= week(datetime(time1(wmax,:)),'weekofyear'); %convverting month to weeknumberber
    HADISST_LAB.annual_annsst(yr)=mean(data4,'omitnan');
    HADISST_LAB.annual_annmean(yr)=mean(data1,'omitnan');
    HADISST_LAB.annual_winmean(yr)=mean(data2(1:3),'omitnan');%DJF
    HADISST_LAB.annual_sprmean(yr)=mean(data2(4:6),'omitnan');%MAM
    HADISST_LAB.annual_summean(yr)=mean(data2(7:9),'omitnan');%JJA
    HADISST_LAB.annual_autmean(yr)=mean(data2(10:12),'omitnan');%SON
    clear data mmax duff julday ind ilon wmax wmin  ;   
end
clear iyear year year2 iyear yr

%length2=wmax2-wmin2;
%slope2=range2./length2;


plot(HADISST_LAB.decyear,HADISST_LAB.clim_norm_anom,'k-')
hold on
plot(HADISST_LAB.ann,HADISST_LAB.annual_annmean,'r-','linewidth',2)
set(gca,'XLim',[1950 2025]), %set(gca,'YLim',[-3 3])


 fid = fopen('IROC_HADISST_LabSea.csv', 'w') ;                         % Opens file for writing.
 for jj = 1:size(HADISST_LAB.gdate,1)
     fprintf(fid, '%4d,%2d,%5.2f\r\n',[HADISST_LAB.gdate(jj,1),HADISST_LAB.gdate(jj,2),HADISST_LAB.sst(jj)]);
 end
 fclose(fid) ;% Closes file.


for dd=1:size(HADPOS,1);dist(dd) = round(sw_dist([HADPOS(dd,1),INSITU(1)],[HADPOS(dd,2),INSITU(2)],'km'));end
dist_w = 1-dist./sum(dist);

HADISST_LAB.sst_weighted_avg = sum(HADISST_LAB.sstall.*...
    repmat(dist_w,size(HADISST_LAB.sstall,1),1),2)./sum(dist_w);



% 
 % dlmwrite(['IROC_HADISST_LabSea.csv'],[HADISST_LAB.gdate(:,1),HADISST_LAB.gdate(:,2),HADISST_LAB.sst],'precision','%4d %2d %5.2f')