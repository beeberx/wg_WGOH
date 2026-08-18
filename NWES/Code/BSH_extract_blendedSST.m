clear all;close all;clc;

BSH_datafolder = ['../DataCallSubmissions/BSH_blendedSSTgridpoints/'];

clim_ref_period = [1991 2020];

box_defs = readtable('../BoxDefs_NWES.csv');

time_dd = datevec([datenum(1995,1,7):7:now]');
box_avg_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));
box_std_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));
box_num_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));

flist = ls(BSH_datafolder);

for bb=1:size(box_defs,1)
    idxB = find(cellfun(@isempty,regexpi(cellstr(flist),sprintf('%02d',box_defs{bb,"BoxNumber"})))==0);
    if isempty(idxB),clear idxB,continue,end
    SST = readtable([BSH_datafolder,flist(idxB,:)],'NumHeaderLines',5);
    tvec = [SST.Var3,SST.Var4,SST.Var5,SST.Var6,SST.Var7,0.*SST.Var7];
    tnum = datenum(tvec);
    temp_in = SST.Var12;
    for tt=1:size(time_dd,1)
        idxT = intersect(intersect(find(time_dd(tt,1)==tvec(:,1)),...
            find(time_dd(tt,2)==tvec(:,2))),find(time_dd(tt,3)==tvec(:,3)));
        if isempty(idxT),clear idxT,continue,end
        box_avg_temp(bb,tt) = mean(temp_in(idxT));
        box_std_temp(bb,tt) = std(temp_in(idxT));
        box_num_temp(bb,tt) = length(~isnan(temp_in(idxT)));
    end;clear tt
    clear SST tvec tnum temp_in idxB
end;clear bb

time_yy(:,1) = [1991:2024];
time_mm(:,1) = sort(repmat(time_yy(:,1),12,1));
time_mm(:,2) = repmat([1:12]',size(time_yy,1),1);

box_avg_temp_monthly = NaN.*zeros(size(box_defs,1),size(time_mm,1));
box_std_temp_monthly = NaN.*zeros(size(box_defs,1),size(time_mm,1));
box_avg_temp_annual = NaN.*zeros(size(box_defs,1),size(time_yy,1));
box_std_temp_annual = NaN.*zeros(size(box_defs,1),size(time_yy,1));

for yy=1:size(time_yy,1)
    for mm=1:12
        t_idx = intersect(find(time_dd(:,1)==time_yy(yy)),find(time_dd(:,2)==mm));
        if isempty(t_idx),clear t_idx,continue,end
        m_idx = intersect(find(time_mm(:,1)==time_yy(yy)),find(time_mm(:,2)==mm));
        box_avg_temp_monthly(:,m_idx) = mean(box_avg_temp(:,t_idx),2,'omitnan');
        box_std_temp_monthly(:,m_idx) = std(box_avg_temp(:,t_idx),0,2,'omitnan');
        clear t_idx m_idx
    end;clear mm
    y_idx = find(time_mm(:,1)==time_yy(yy));
    box_avg_temp_annual(:,yy) = mean(box_avg_temp_monthly(:,y_idx),2,'omitnan');
    box_std_temp_annual(:,yy) = std(box_avg_temp_monthly(:,y_idx),0,2,'omitnan');
    clear y_idx
end;clear yy

box_avg_tempclim = NaN.*zeros(size(box_avg_temp_monthly,1),12);
box_std_tempclim = NaN.*zeros(size(box_avg_temp_monthly,1),12);
box_avg_tempanom = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_mm,1));
box_avg_tempnormanom = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_mm,1));

for mm=1:12
    idxm = find(time_mm(:,2)==mm);
    idxclim = intersect(intersect(find(time_mm(:,1)>=clim_ref_period(1)),find(time_mm(:,1)<=clim_ref_period(2))),find(time_mm(:,2)==mm));
    box_avg_tempclim(:, mm) = mean(box_avg_temp_monthly(:,idxclim),2,'omitnan');
    box_std_tempclim(:, mm) = std(box_avg_temp_monthly(:,idxclim),[],2,'omitnan');
    box_avg_tempanom(:,idxm)=box_avg_temp_monthly(:,idxm)-repmat(box_avg_tempclim(:,mm),1,length(idxm));
    box_avg_tempnormanom(:,idxm)=(box_avg_temp_monthly(:,idxm)-repmat(box_avg_tempclim(:,mm),1,length(idxm)))./repmat(box_std_tempclim(:,mm),1,length(idxm));
    clear idxm idxclim
end; clear mm

% method 1: annual anomaly is mean of anomalies in year
% box_avg_tempanom_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
% box_avg_tempnormanom_annual = NaN.*zeros(size(box_avg_temp_monthly,1),size(time_yy,1));
% for yy=1:size(time_yy,1)
%     box_avg_tempanom_annual(:,:,yy)=mean(box_avg_tempanom(:,:,idxy),3);
%     box_avg_tempnormanom_annual(:,:,yy)=mean(box_avg_tempnormanom(:,:,idxy),3);
% end
% method 2: annual anomaly is annual mean rel to clim period mean and std
idxclim = intersect(find(time_yy(:,1)>=clim_ref_period(1)),find(time_yy(:,1)<=clim_ref_period(2)));
box_avg_tempclim_annual=mean(box_avg_temp_annual(:,idxclim),2,'omitnan');
box_std_tempclim_annual=std(box_avg_temp_annual(:,idxclim),[],2,'omitnan');
box_avg_tempanom_annual=box_avg_temp_annual - repmat(box_avg_tempclim_annual,1,size(box_avg_temp_annual,2));
box_avg_tempnormanom_annual=box_avg_tempanom_annual ./ repmat(box_std_tempclim_annual,1,size(box_avg_temp_annual,2));
clear idxclim

clear box_defs flist BSH_datafolder 

save BSH_blendedSST.mat