clear all;close all;clc;

filedir_T = ['\\isilonml\Oceanography_Work_Area\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\cmems_mod_nws_phy-t_my_7km-3D_P1M-m\'];
filedir_S = ['\\isilonml\Oceanography_Work_Area\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\cmems_mod_nws_phy-s_my_7km-3D_P1M-m\'];

box_defs = readtable('../BoxDefs_NWES.csv');

time_yy(:,1) = [1993:2024];
time_mm(:,1) = sort(repmat(time_yy(:,1),12,1));
time_mm(:,2) = repmat([1:12]',size(time_yy,1),1);

box_avg_temperature = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));
box_std_temperature = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));
box_avg_salinity = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));
box_std_salinity = NaN.*zeros(24,size(box_defs,1),size(time_mm,1));
for yy=1993:2024
    dirT_interest = [filedir_T,sprintf('%4d',yy),filesep];
    dirS_interest = [filedir_S,sprintf('%4d',yy),filesep];
    if exist(dirT_interest,'dir') && exist(dirS_interest,'dir')
        for mm=1:12
            fname_T = ['metoffice_foam1_amm7_NWS_TEM_mm',sprintf('%4d',yy),sprintf('%02d',mm),'.nc'];
            fname_S = ['metoffice_foam1_amm7_NWS_SAL_mm',sprintf('%4d',yy),sprintf('%02d',mm),'.nc'];
            if ~exist([dirT_interest,fname_T],'file') || ~exist([dirS_interest,fname_S],'file')
                clear fname_T fname_S
                continue
            else
                if ~exist('lon_grid','var')
                    lon = ncread([dirT_interest,fname_T],'longitude');
                    lat = ncread([dirT_interest,fname_T],'latitude');
                    depth = ncread([dirT_interest,fname_T],'depth');
                    [lat_grid,lon_grid] = meshgrid(double(lat),double(lon));
                    clear lon lat
                end
                temp  = ncread([dirT_interest,fname_T],'thetao');
                salty = ncread([dirS_interest,fname_S],'so');
                time = datevec(datenum(1970,1,1) + (ncread([dirT_interest,fname_T],'time')./(24*3600)));
                tt = find(ismember(time_mm(:,1:2),time(1:2),'rows'));
                for bb=1:size(box_defs,1)
                    x_polygon = [box_defs{bb,"p1_lon"},box_defs{bb,"p2_lon"},box_defs{bb,"p3_lon"},box_defs{bb,"p4_lon"},box_defs{bb,"p1_lon"}];
                    y_polygon = [box_defs{bb,"p1_lat"},box_defs{bb,"p2_lat"},box_defs{bb,"p3_lat"},box_defs{bb,"p4_lat"},box_defs{bb,"p1_lat"}];
                    in = abs(inpolygon(lon_grid,lat_grid,x_polygon,y_polygon));
                    in(in==0)=NaN;
                    tmp_temp = temp .*repmat(in,1,1,size(temp ,3));
                    tmp_salt = salty.*repmat(in,1,1,size(salty,3));
                    nh = sum(~isnan(tmp_temp),3);valdpth = min(nh(nh~=0));
                    for hh=1:valdpth
                        subvalT = tmp_temp(:,:,hh);subvalT=subvalT(~isnan(subvalT));
                        box_avg_temperature(hh,bb,tt) = mean(subvalT,'omitnan');
                        box_std_temperature(hh,bb,tt) = std(subvalT,'omitnan');
                        subvalS = tmp_salt(:,:,hh);subvalS=subvalS(~isnan(subvalS));
                        box_avg_salinity(hh,bb,tt) = mean(subvalS,'omitnan');
                        box_std_salinity(hh,bb,tt) = std(subvalS,'omitnan');
                        clear subvalT subvalS
                    end;clear hh
                    clear x_polygon y_polygon in tmp_temp tmp_salt nh valdpth
                end
                clear tt time temp salty
            end
        end
    end
    disp([sprintf('%4d',yy) ' complete.  '])
end
save AMM7_tempsal_monthly.mat box_avg_temperature box_std_temperature box_avg_salinity box_std_salinity time_mm

%%
for bb=1:size(box_defs,1)
    fname_out = ['Box',sprintf('%02d',bb),'_UKMO_AMM7_temp_salt_monthly.csv'];

    fileID_out = fopen(['../DataCallSubmissions/UKMO_AMM7_reanalysis_temp_sal_monthly/',fname_out],'w');
    fprintf(fileID_out,'%s\n',['Box Name: ',sprintf('%02d',box_defs{bb,1}),' ',char(box_defs{bb,10})]);
    fprintf(fileID_out,'%s\n',['Data Source: UK Met Office']);
    fprintf(fileID_out,'%s\n',['Data Contact: Bee Berx (barbara.berx@gov.scot); Richard Renshaw']);
    fprintf(fileID_out,'%s\n',['Comment/Note (incl. method description): Extraction from UK Met Office reanalysis product - average in polygon described by boundaries']);
    fprintf(fileID_out,'%s\n',['Cruise ID / Site ID,Station Name,Year,Month,Day,Hour,Minute,Dec Lat,Dec Lon,Sounding,Pressure,Temp,Temp Flag,Sal,Sal Flag']);
    for dd=1:size(time_mm,1)
        for hh=1:size(box_avg_temperature,1)
            if ~isnan(box_avg_temperature(hh,bb,dd)) && ~isnan(box_avg_salinity(hh,bb,dd))
                fprintf(fileID_out,'%s,',NaN);
                fprintf(fileID_out,'%4d,',NaN);
                fprintf(fileID_out,'%04d,%02d,%02d,%02d,%02d,',[time_mm(dd,[1,2]),15,12,0]);
                fprintf(fileID_out,'%9.4f,%9.4f,%4d,%4d,',[NaN,NaN,NaN,double(depth(hh))]);
                fprintf(fileID_out,'%9.3f,%3d,%9.3f,%3d\n',[box_avg_temperature(hh,bb,dd),8,box_avg_salinity(hh,bb,dd),8]);
            end
        end
    end
    fclose(fileID_out);
end
