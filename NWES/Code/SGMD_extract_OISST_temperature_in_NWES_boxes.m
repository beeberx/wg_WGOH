clear all;close all;clc;

OISST_datafolder = ['I:\Data_External\NOAA_oisst.v2.highres\'];

clim_ref_period = [1991 2020];

box_defs = readtable('../BoxDefs_NWES.csv');

time_yy(:,1) = [1981:2024];
time_mm(:,1) = sort(repmat(time_yy(:,1),12,1));
time_mm(:,2) = repmat([1:12]',size(time_yy,1),1);
time_dd = datevec([datenum(1981,1,1):1:now]);

lon_choice = [-20 15];
lat_choice = [45 65];

box_avg_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));
box_std_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));
box_num_temp = NaN.*zeros(size(box_defs,1),size(time_dd,1));
for yy=1:size(time_yy,1)
    fname = {[OISST_datafolder 'sst.day.mean.' num2str(time_yy(yy)) '.nc']};
    iname = {[OISST_datafolder 'icec.day.mean.' num2str(time_yy(yy)) '.nc']};
    lat = ncread(fname{1},'lat');
    lon = ncread(fname{1},'lon');
    lon(lon>180)=lon(lon>180)-360;
    ilat1 = intersect(find(lat>=lat_choice(1)),find(lat<=lat_choice(2)));
    ilon2 = intersect(find(lon>=0),find(lon<=lon_choice(2)));
    ilon1 = intersect(find(lon>=lon_choice(1)),find(lon<=0));

    sellon1  = double(ncread(fname{1},'lon',[ilon1(1)],[length(ilon1)]));
    sellon2  = double(ncread(fname{1},'lon',[ilon2(1)],[length(ilon2)]));
    sellon = cat(1,sellon1,sellon2);
    sellon(sellon>180)=sellon(sellon>180)-360;

    sellat  = double(ncread(fname{1},'lat',[ilat1(1)],[length(ilat1)]));
    lsmask = cat(1,ncread([OISST_datafolder,'lsmask.oisst.nc'],'lsmask',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),1]),...
        ncread([OISST_datafolder,'lsmask.oisst.nc'],'lsmask',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),1]));
    lsmask(lsmask==0) = NaN;lsmask = double(lsmask);

    sst_in = cat(1,ncread(fname{1},'sst',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
        ncread(fname{1},'sst',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
    sst_in = double(sst_in);
    sst_in(sst_in==-9.969209968386869e+36)=NaN;

    ice_in = cat(1,ncread(iname{1},'icec',[ilon1(1),ilat1(1),1],[length(ilon1),length(ilat1),Inf]),...
        ncread(iname{1},'icec',[ilon2(1),ilat1(1),1],[length(ilon2),length(ilat1),Inf]));
    ice_in = double(ice_in);
    ice_in(ice_in==-9.969209968386869e+36)=NaN;

    icemask = abs(isnan(ice_in));
    icemask(icemask==0)=NaN;

    clear ice_in;

    sst_in_masked = sst_in.* icemask .*repmat(lsmask,1,1,size(sst_in,3));

    [lat_grid,lon_grid] = meshgrid(double(sellat),double(sellon));

    time_orig = datevec(datenum(1800,1,1)+ncread(fname{1},'time'));

    for bb=1:size(box_defs,1)
        x_polygon = [box_defs{bb,"p1_lon"},box_defs{bb,"p2_lon"},box_defs{bb,"p3_lon"},box_defs{bb,"p4_lon"},box_defs{bb,"p1_lon"}];
        y_polygon = [box_defs{bb,"p1_lat"},box_defs{bb,"p2_lat"},box_defs{bb,"p3_lat"},box_defs{bb,"p4_lat"},box_defs{bb,"p1_lat"}];
        in = abs(inpolygon(lon_grid,lat_grid,x_polygon,y_polygon));
        in(in==0)=NaN;
        tmp_temp = sst_in_masked.*repmat(in,1,1,size(sst_in_masked,3));
        for tt=1:size(tmp_temp,3)
            idxt = intersect(intersect(find(time_orig(tt,1)==time_dd(:,1)),...
                find(time_orig(tt,2)==time_dd(:,2))),find(time_orig(tt,3)==time_dd(:,3)));
            subval = tmp_temp(:,:,tt);
            subval = subval(~isnan(subval));
        box_avg_temp(bb,idxt) = mean(subval,'omitnan');
        box_std_temp(bb,idxt) = std(subval,'omitnan');
        box_num_temp(bb,idxt) = length(subval);
            clear subval idxt
        end;clear tt
        clear x_polygon y_polygon in tmp_temp
    end
    clear sst_in_masked lat_grid lon_grid
    disp([sprintf('%4d',time_yy(yy)) ' complete.  '])
end
save OISST_temp_daily.mat box_avg_temp box_std_temp box_num_temp time_dd
return
%%
box_avg_temp_monthly = NaN.*zeros(size(box_defs,1),size(time_mm,1));
box_std_temp_monthly = NaN.*zeros(size(box_defs,1),size(time_mm,1));

for yy=1:size(time_yy,1)
    for mm=1:12
        t_idx = intersect(find(time_dd(:,1)==time_yy(yy)),find(time_dd(:,2)==mm));
        m_idx = intersect(find(time_mm(:,1)==time_yy(yy)),find(time_mm(:,2)==mm));
        box_avg_temp_monthly(:,m_idx) = mean(box_avg_temp(:,t_idx),2,'omitnan');
        box_std_temp_monthly(:,m_idx) = std(box_avg_temp(:,t_idx),0,2,'omitnan');
    end
end
save OISST_temp_monthly.mat box_avg_temp_monthly box_std_temp_monthly time_mm

%%
for bb=1:size(box_defs,1)
    fname_out = ['Box',sprintf('%02d',bb),'_OISST_temperature.csv'];

    fileID_out = fopen(['../DataCallSubmissions/OISST_temperature/',fname_out],'w');
    fprintf(fileID_out,'%s\n',['Box Name: ',sprintf('%02d',box_defs{bb,1}),' ',char(box_defs{bb,10})]);
    fprintf(fileID_out,'%s\n',['Data Source: UK Met Office']);
    fprintf(fileID_out,'%s\n',['Data Contact: Bee Berx (barbara.berx@gov.scot)']);
    fprintf(fileID_out,'%s\n',['Comment/Note (incl. method description): Extraction from NOAA OISST data product - average in polygon described by boundaries']);
    fprintf(fileID_out,'%s\n',['Cruise ID / Site ID,Station Name,Year,Month,Day,Hour,Minute,Dec Lat,Dec Lon,Sounding,Pressure,Temp,Temp Flag,Sal,Sal Flag']);
    for dd=1:size(time_dd,1)
            fprintf(fileID_out,'%s,',NaN);
            fprintf(fileID_out,'%4d,',NaN);
            fprintf(fileID_out,'%04d,%02d,%02d,%02d,%02d,',time_dd(dd,[1,2,3,4,5]));
            fprintf(fileID_out,'%9.4f,%9.4f,%4d,%4d,',[NaN,NaN,NaN,NaN]);
            fprintf(fileID_out,'%9.3f,%3d,%9.3f,%3d\n',[box_avg_temp(bb,dd),8,NaN,9]);
        end
    fclose(fileID_out);
end