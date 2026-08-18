%clear all;close all;clc;

filedir_UV = ['\\isilonml\Oceanography_Work_Area\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\cmems_mod_nws_phy-uv_my_7km-3D_P1M-m\'];

lon_extent = [-20,15];
lat_extent = [45,65];

time_yy(:,1) = [1993:2024];
time_mm(:,1) = sort(repmat(time_yy(:,1),12,1));
time_mm(:,2) = repmat([1:12]',size(time_yy,1),1);

monthly_u = [];
monthly_v = [];
monthly_t = [];

for yy=1993:2024
    dirUV_interest = [filedir_UV,sprintf('%4d',yy),filesep];
    if exist(dirUV_interest,'dir')
        for mm=1:12
            fname_UV = ['metoffice_foam1_amm7_NWS_CUR_mm',sprintf('%4d',yy),sprintf('%02d',mm),'.nc'];
            if ~exist([dirUV_interest,fname_UV],'file') 
                clear fname_UV
                continue
            else
                if ~exist('lon_grid','var')
                    lon_amm = ncread([dirUV_interest,fname_UV],'longitude');
                    lat_amm = ncread([dirUV_interest,fname_UV],'latitude');
                    depth = ncread([dirUV_interest,fname_UV],'depth');
                    [lat_grid,lon_grid] = meshgrid(double(lat_amm),double(lon_amm));
                    clear lon_amm lat_amm
                end
                u_current  = ncread([dirUV_interest,fname_UV],'uo');
                v_current = ncread([dirUV_interest,fname_UV],'vo');
                u_mean = mean(u_current,3,'omitnan');
                v_mean = mean(v_current,3,'omitnan');
                monthly_u = cat(3,monthly_u,u_mean);
                monthly_v = cat(3,monthly_v,v_mean);
                time = datevec(datenum(1970,1,1) + (ncread([dirUV_interest,fname_UV],'time')./(24*3600)));
                monthly_t = cat(1,monthly_t,time);
                clear time u_mean v_mean u_current v_current
            end
        end
    end
    disp([sprintf('%4d',yy) ' complete.  '])
end

monthly_s = sqrt((monthly_u.^2)+(monthly_v.^2));

return
%%
close all
m_proj('mercator','lon',lon_extent+[7.5 -7.5],'lat',lat_extent+[5 -2.5]);
qstep=2;
[CS2,CH2]=m_contour(lon,lat,double(eta)',[-500:100:-100,-75:25:0],'edgecolor',[.8 .8 .8]);
hold on
m_quiver(lon_grid(1:qstep:end,1:qstep:end),lat_grid(1:qstep:end,1:qstep:end),...
    mean(monthly_u(1:qstep:end,1:qstep:end,:),3,'omitnan'),mean(monthly_v(1:qstep:end,1:qstep:end,:),3,'omitnan'),3,'k')

m_grid('linestyle','none','tickdir','out','linewidth',3,'xlim',[-8 -3],'ylim',[57 62]);
m_gshhs_i('patch',coldef_land),

print(gcf, '-dpng', '-r300',['nwes_quiver_contoured.png'])

%%
close all
m_proj('mercator','lon',[-14 0],'lat',[47 57]);
qstep=2;
[CS2,CH2]=m_contour(lon,lat,double(eta)',[-500:100:-100,-75:25:0],'edgecolor',[.8 .8 .8]);
hold on
m_quiver(lon_grid(1:qstep:end,1:qstep:end),lat_grid(1:qstep:end,1:qstep:end),...
    mean(monthly_u(1:qstep:end,1:qstep:end,:),3,'omitnan'),mean(monthly_v(1:qstep:end,1:qstep:end,:),3,'omitnan'),4,'k')

m_grid('linestyle','none','tickdir','out','linewidth',3,'xlim',[-8 -3],'ylim',[57 62]);
m_gshhs_i('patch',coldef_land),

print(gcf, '-dpng', '-r300',['nwes_quiver_contoured_CelticZoom.png'])
%%
close all
m_proj('mercator','lon',[-5 10],'lat',[50 62.5]);
qstep=2;
[CS2,CH2]=m_contour(lon,lat,double(eta)',[-500:100:-100,-75:25:0],'edgecolor',[.8 .8 .8]);
hold on
m_quiver(lon_grid(1:qstep:end,1:qstep:end),lat_grid(1:qstep:end,1:qstep:end),...
    mean(monthly_u(1:qstep:end,1:qstep:end,:),3,'omitnan'),mean(monthly_v(1:qstep:end,1:qstep:end,:),3,'omitnan'),4,'k')

m_grid('linestyle','none','tickdir','out','linewidth',3,'xlim',[-8 -3],'ylim',[57 62]);
m_gshhs_i('patch',coldef_land),

print(gcf, '-dpng', '-r300',['nwes_quiver_contoured_NSeaZoom.png'])
%%
cmap_ocean = flipud(cbrewer('seq','Blues',101));
cmap_ocean(cmap_ocean<0)=0;cmap_ocean(cmap_ocean>1)=1;
cmap_land = cbrewer('seq','Greens',31);
cmap_land(cmap_land<0)=0;cmap_land(cmap_land>1)=1;
coldef_land = cmap_land(end-1,:);
rmap  = cbrewer('seq','Reds',14);
rmap(rmap<0)=0;rmap(rmap>1)=1;

%%
for llon = [-15:15:0];
    for llat=[45:10:55];
        close all
        %m_proj('lambert','lon',XLimVal(rr,:),'lat',YLimVal(rr,:));
        %m_proj('mercator','lon',lon_extent,'lat',lat_extent);
        m_proj('mercator','lon',[llon llon+15],'lat',[llat llat+10]);

        m_pcolor(lon_grid,lat_grid,mean(monthly_s,3,'omitnan'));
        colormap(rmap)
        colorbar
        caxis([0 0.35])
        hold on
        qstep=2;
        m_quiver(lon_grid(1:qstep:end,1:qstep:end),lat_grid(1:qstep:end,1:qstep:end),...
            mean(monthly_u(1:qstep:end,1:qstep:end,:),3,'omitnan'),mean(monthly_v(1:qstep:end,1:qstep:end,:),3,'omitnan'),3,'k')

        m_grid('linestyle','none','tickdir','out','linewidth',3,'xlim',[-8 -3],'ylim',[57 62]);
        m_gshhs_i('patch',coldef_land),

        print(gcf, '-dpng', '-r300',['nwes_quiver_',num2str(llon),'lon_',num2str(llat),'lat.png'])
    end
end

%%
close all
m_proj('mercator','lon',lon_extent,'lat',lat_extent);

m_pcolor(lon_grid,lat_grid,mean(monthly_s,3,'omitnan'));
colormap(rmap)
colorbar
caxis([0 0.35])
hold on
qstep=2;
m_quiver(lon_grid(1:qstep:end,1:qstep:end),lat_grid(1:qstep:end,1:qstep:end),...
    mean(monthly_u(1:qstep:end,1:qstep:end,:),3,'omitnan'),mean(monthly_v(1:qstep:end,1:qstep:end,:),3,'omitnan'),3,'k')

m_grid('linestyle','none','tickdir','out','linewidth',3,'xlim',[-8 -3],'ylim',[57 62]);
m_gshhs_i('patch',coldef_land),

print(gcf, '-dpng', '-r300',['nwes_quiver_full.png'])
