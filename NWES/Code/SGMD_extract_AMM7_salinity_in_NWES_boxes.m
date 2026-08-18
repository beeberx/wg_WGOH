clear all;close all;clc;

filedir = ['\\isilonml\Oceanography_Work_Area\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\cmems_mod_nws_phy-s_my_7km-3D_P1D-m\'];
% filedir = [getenv('Isilon'),'\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\cmems_mod_nws_phy-s_my_7km-3D_P1D-m\'];
% [filedir 'extract\Salinity_' num2str(yy) '.nc']

box_defs = readtable('../BoxDefs_NWES.csv');

time_mm(:,1) = sort(repmat([1993:2024]',12,1));
time_mm(:,2) = repmat([1:12]',32,1);
time_dd = datevec([datenum(1993,1,1):1:now]);

box_avg_salinity = NaN.*zeros(24,size(box_defs,1),size(time_dd,1));
box_std_salinity = NaN.*zeros(24,size(box_defs,1),size(time_dd,1));
for yy=1993:2024
    for mm=1:12
        dir_interest = [filedir,sprintf('%4d',yy),filesep,sprintf('%02d',mm),filesep];
        if exist(dir_interest,'dir')
            for dd=1:eomday(yy,mm)
                fname = ['metoffice_foam1_amm7_NWS_SAL_dm',sprintf('%4d',yy),sprintf('%02d',mm),sprintf('%02d',dd),'.nc'];
                if ~exist([dir_interest,fname],'file')
                    clear fname dir_interest
                    continue
                else
                    if ~exist('lon_grid','var')
                        lon = ncread([dir_interest,fname],'longitude');
                        lat = ncread([dir_interest,fname],'latitude');
                        depth = ncread([dir_interest,fname],'depth');
                        [lat_grid,lon_grid] = meshgrid(double(lat),double(lon));
                        clear lon lat
                    end
                    salty = ncread([dir_interest,fname],'so');
                    time = datevec(datenum(1970,1,1) + (ncread([dir_interest,fname],'time')./(24*3600)));
                    tt = find(ismember(time_dd(:,1:3),time(1:3),'rows'));
                    for bb=1:size(box_defs,1)
                        x_polygon = [box_defs{bb,"p1_lon"},box_defs{bb,"p2_lon"},box_defs{bb,"p3_lon"},box_defs{bb,"p4_lon"},box_defs{bb,"p1_lon"}];
                        y_polygon = [box_defs{bb,"p1_lat"},box_defs{bb,"p2_lat"},box_defs{bb,"p3_lat"},box_defs{bb,"p4_lat"},box_defs{bb,"p1_lat"}];
                        in = abs(inpolygon(lon_grid,lat_grid,x_polygon,y_polygon));
                        in(in==0)=NaN;
                        tmp_salty = salty.*repmat(in,1,1,size(salty,3));
                        nh = sum(~isnan(tmp_salty),3);valdpth = min(nh(nh~=0));
                        for hh=1:valdpth
                            subval = tmp_salty(:,:,hh);subval=subval(~isnan(subval));
                            box_avg_salinity(hh,bb,tt) = mean(subval,'omitnan');
                            box_std_salinity(hh,bb,tt) = std(subval,'omitnan');
                            clear subval
                        end;clear hh
                        clear x_polygon y_polygon in tmp_salty nh valdpth
                    end
                    clear tt time salty
                end
            end
        else
            clear dir_interest
            continue
        end
    end
    disp([sprintf('%4d',yy) ' complete.  '])
end
save AMM7_salinity_daily.mat box_avg_salinity box_std_salinity time_dd

%%
box_avg_salinity_monthly = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));
box_std_salinity_monthly = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));

for yy=1993:2024
    for mm=1:12
        t_idx = intersect(find(time_dd(:,1)==yy),find(time_dd(:,2)==mm));
        m_idx = intersect(find(time_mm(:,1)==yy),find(time_mm(:,2)==mm));
        box_avg_salinity_monthly(:,:,m_idx) = mean(box_avg_salinity(:,:,t_idx),3,'omitnan');
        box_std_salinity_monthly(:,:,m_idx) = std(box_avg_salinity(:,:,t_idx),0,3,'omitnan');
    end
end
save AMM7_salinity_monthly.mat box_avg_salinity_monthly box_std_salinity_monthly time_mm

%%
for bb=1:size(box_defs,1)
    fname_out = ['Box',sprintf('%02d',bb),'_UKMO_AMM7salinity.csv'];

    fileID_out = fopen(['../DataCallSubmissions/UKMO_AMM7_reanalysis_salinity/',fname_out],'w');
    fprintf(fileID_out,'%s\n',['Box Name: ',sprintf('%02d',box_defs{bb,1}),' ',char(box_defs{bb,10})]);
    fprintf(fileID_out,'%s\n',['Data Source: UK Met Office']);
    fprintf(fileID_out,'%s\n',['Data Contact: Bee Berx (barbara.berx@gov.scot); Richard Renshaw']);
    fprintf(fileID_out,'%s\n',['Comment/Note (incl. method description): Extraction from UK Met Office reanalysis product - average in polygon described by boundaries']);
    fprintf(fileID_out,'%s\n',['Cruise ID / Site ID,Station Name,Year,Month,Day,Hour,Minute,Dec Lat,Dec Lon,Sounding,Pressure,Temp,Temp Flag,Sal,Sal Flag']);
    for dd=1:size(time_dd,1)
        for hh=1:size(box_avg_salinity,1)
            if ~isnan(box_avg_salinity(hh,bb,dd))
            fprintf(fileID_out,'%s,',NaN);
            fprintf(fileID_out,'%4d,',NaN);
            fprintf(fileID_out,'%04d,%02d,%02d,%02d,%02d,',time_dd(dd,[1,2,3,4,5]));
            fprintf(fileID_out,'%9.4f,%9.4f,%4d,%4d,',[NaN,NaN,NaN,double(depth(hh))]);
            fprintf(fileID_out,'%9.3f,%3d,%9.3f,%3d\n',[NaN,9,box_avg_salinity(hh,bb,dd),8]);
            end
        end
    end
    fclose(fileID_out);
end
