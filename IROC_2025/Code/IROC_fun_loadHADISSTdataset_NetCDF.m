function HADISST = IROC_fun_loadHADISSTdataset_NetCDF(Data_Directory,lon_extent,lat_extent,clim_per)
%script loadHADDISTdataset_NetCDF
%modified from original loadHADISST script
%reads from netcdf

if ~strcmpi(Data_Directory(end),filesep)
    Data_Directory = [Data_Directory,filesep];
end

Data_SstName = [Data_Directory,'HadISST_sst.nc'];
Data_IceName = [Data_Directory,'HadISST_ice.nc'];
if ~exist(Data_SstName,'file')
    error('HadISST SST data file not found')
end
if ~exist(Data_IceName,'file')
    warning('HadISST ICE data file not found')
end

lon = ncread(Data_SstName,'longitude');lon=double(lon);
lat = ncread(Data_SstName,'latitude');lat=double(lat);
time = ncread(Data_SstName,'time');time=double(time);

idxlat=intersect(find(lat>=lat_extent(1)),find(lat<=lat_extent(2)));
idxlon=intersect(find(lon>=lon_extent(1)),find(lon<=lon_extent(2)));

idxstart = [min(idxlon),min(idxlat),1];
idxstrid = [length(idxlon),length(idxlat),Inf];

sst = ncread(Data_SstName,'sst',idxstart,idxstrid);sst(sst<-100)=NaN;
if exist(Data_IceName,'file')
    ice = ncread(Data_IceName,'sic',idxstart,idxstrid);
else
    ice = 0.*sst;
end


%put data in the main structure
HADISST.gdate=datevec(double(time)+datenum(1870,1,1,0,0,0));
%HADISST.jdate=julian(HADISST.gdate);


tmp=(datenum(HADISST.gdate)-datenum(HADISST.gdate(:,1),0.*HADISST.gdate(:,1)+1,0.*HADISST.gdate(:,1)+1,0.*HADISST.gdate(:,1),...
    0.*HADISST.gdate(:,1),0.*HADISST.gdate(:,1)));
tmp2 = datenum(HADISST.gdate(:,1),0.*HADISST.gdate(:,1)+12,0.*HADISST.gdate(:,1)+31,0.*HADISST.gdate(:,1),...
    0.*HADISST.gdate(:,1),0.*HADISST.gdate(:,1))-datenum(HADISST.gdate(:,1),0.*HADISST.gdate(:,1)+1,0.*HADISST.gdate(:,1)+1,0.*HADISST.gdate(:,1),...
    0.*HADISST.gdate(:,1),0.*HADISST.gdate(:,1))+1;
HADISST.decyear=HADISST.gdate(:,1)+(tmp./tmp2);clear tmp tmp2

HADISST.sst=sst;
HADISST.lat=lat(idxlat);
HADISST.lon=lon(idxlon);

lsmask = sum(isnan(sst),3)./size(sst,3);
lsmask(lsmask~=1)=0;

icemask=sum(ice<0.50,3);
%flag for ice
% ice cover greater than 50% for more than 1 month each year
nyrs=HADISST.gdate(end,1)-HADISST.gdate(1,1)+1;
limit=nyrs*1;
iceflag=icemask;
iceflag(icemask>=limit)=1;
iceflag(icemask<limit)=0;
iceflag(iceflag==0)=NaN;

%calculate climatology.
[nlon,nlat,ntim]=size(HADISST.sst);
HADISST.clim_mean = NaN.*zeros(nlon,nlat,12);
HADISST.clim_sdev = NaN.*zeros(nlon,nlat,12);
HADISST.clim_diff_anom = NaN.*HADISST.sst;
HADISST.clim_norm_anom = NaN.*HADISST.sst;
for mm=1:12;
    idx_in_clim = intersect(find(HADISST.gdate(:,2)==mm),...
        intersect(find(HADISST.gdate(:,1)>=clim_per(1)),find(HADISST.gdate(:,1)<=clim_per(2))));
    idx_in_mm = find(HADISST.gdate(:,2)==mm);
    HADISST.clim_mean(:,:,mm)=mean(HADISST.sst(:,:,idx_in_clim),3,'omitnan').*iceflag;
    HADISST.clim_sdev(:,:,mm)=std(HADISST.sst(:,:,idx_in_clim),[],3,'omitnan').*iceflag;
    HADISST.clim_diff_anom(:,:,idx_in_mm) = (HADISST.sst(:,:,idx_in_mm)-...
        repmat(HADISST.clim_mean(:,:,mm),1,1,size(idx_in_mm,1)));
    HADISST.clim_norm_anom(:,:,idx_in_mm) = (HADISST.sst(:,:,idx_in_mm)-...
        repmat(HADISST.clim_mean(:,:,mm),1,1,size(idx_in_mm,1)))./...
        repmat(HADISST.clim_sdev(:,:,mm),1,1,size(idx_in_mm,1));
end

HADISST.ls_mask=lsmask;
HADISST.ic_mask=iceflag;