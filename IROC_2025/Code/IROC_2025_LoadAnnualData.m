%script IROC_2025_LoadAnnualData.m
% requires IROC_TS to have been set- for example using IROC_2025_SummaryFigure_SelectedTimeseries.m


IROC_data_path=[getenv('Working'),'\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\IROC\Data\'];
% find last year and set years
tmp = datevec(now);
last_year = tmp(1);clear tmp

Years_IROC = 1950:last_year;
Data_IROC = NaN.*zeros([length(Years_IROC), 7, length(IROC_TS)]);
Lat_IROC = cell(length(IROC_TS),1);
Lon_IROC = cell(length(IROC_TS),1);
Depth_IROC = cell(length(IROC_TS),1);

% load data from timeseries file
for ff=1:size(IROC_TS,1)
    filename=[IROC_data_path,IROC_TS{ff}];
    ftext=IROC_TS{ff};
    NumHeadLines = 0;bline = repmat(' ',1,15);
    fid = fopen(filename);
    %     while ~strncmpi(bline,'year',4)
    while isempty(regexpi(bline,'year'))
        bline = fgetl(fid);
        if regexpi(bline,'latitude')
            tmp = strsplit(bline,','); 
            Lat_IROC(ff) = tmp(2);
        elseif regexpi(bline,'longitude')
            tmp = strsplit(bline,','); 
            Lon_IROC(ff) = tmp(2);
        elseif regexpi(bline,'measurement depth')
            tmp = strsplit(bline,','); 
            Depth_IROC(ff) = tmp(2);
        end
        if length(bline)>15
            bline = bline(1:15);
        end
        NumHeadLines = NumHeadLines +1;
    end
    fid = fclose(fid);clear fid bline
    timdata = readtable(filename,'NumHeaderLines',NumHeadLines,'EmptyValue',NaN);
    if regexpi(IROC_TS{ff},'GulfStLawrence')
        dat=[timdata.Var1,timdata.Var6,NaN.*timdata.Var6,NaN.*timdata.Var6,...
            timdata.Var7,NaN.*timdata.Var7,NaN.*timdata.Var7];
    elseif regexpi(IROC_TS{ff},'Biscay') 
        dat1=[timdata.Var1,timdata.Var2,NaN.*timdata.Var2,NaN.*timdata.Var2,...
            timdata.Var3,NaN.*timdata.Var3,NaN.*timdata.Var3];
        yrs = unique(floor(dat1(:,1)));
        dat = NaN.*zeros(size(yrs,1),7);
        dat(:,1) = yrs;
        for yy=1:size(yrs,1)
            idxy = find(floor(dat1(:,1))==dat(yy,1));
            dat(yy,2)=mean(dat1(idxy,2));
            dat(yy,5)=mean(dat1(idxy,5));
            clear idxy
        end
        clear yrs dat1
    elseif regexpi(IROC_TS{ff},'Cadiz')
        dat1=[timdata.Var1,timdata.Var2,NaN.*timdata.Var2,NaN.*timdata.Var2,...
            timdata.Var3,NaN.*timdata.Var3,NaN.*timdata.Var3];
        yrs = unique(floor(dat1(:,1)));
        dat = NaN.*zeros(size(yrs,1),7);
        dat(:,1) = yrs;
        for yy=1:size(yrs,1)
            idxy = find(floor(dat1(:,1))==dat(yy,1));
            dat(yy,2)=mean(dat1(idxy,2));
            dat(yy,5)=mean(dat1(idxy,5));
            clear idxy
        end
        clear yrs dat1
    elseif regexpi(IROC_TS{ff},'Canary') 
        dat1=[timdata.Var1,timdata.Var2,NaN.*timdata.Var2,NaN.*timdata.Var2,...
            timdata.Var3,NaN.*timdata.Var3,NaN.*timdata.Var3];
        yrs = unique(floor(dat1(:,1)));
        dat = NaN.*zeros(size(yrs,1),7);
        dat(:,1) = yrs;
        for yy=1:size(yrs,1)
            idxy = find(floor(dat1(:,1))==dat(yy,1));
            dat(yy,2)=mean(dat1(idxy,2));
            dat(yy,5)=mean(dat1(idxy,5));
            clear idxy
        end
        clear yrs dat1
    else
        dat=[timdata.Var1,timdata.Var2,timdata.Var3,timdata.Var4,...
            timdata.Var5,timdata.Var6,timdata.Var7];
    end
    [~,idx1,idx2]=intersect(Years_IROC,dat(:,1));
    Data_IROC(idx1,:,ff)=dat(idx2,:);
    clear dat refind refdat refstd idx1 idx2 timdata NumHeadLines ftext filename
end

IROC_Latitudes = zeros(size(Lat_IROC));
for ii=1:size(IROC_Latitudes,1)
    if ii==5;continue;end
    if length(regexp(Lat_IROC{ii},'N'))==1
        C = textscan(Lat_IROC{ii}(1:regexp(Lat_IROC{ii},'N')-1),'%f');
        IROC_Latitudes(ii) = C{1};
    end
end

IROC_Longitudes = zeros(size(Lon_IROC));
for ii=1:size(IROC_Longitudes,1)
    if ii==5;continue;end
    if length(regexp(Lon_IROC{ii},'E'))==1
        C = textscan(Lon_IROC{ii}(1:regexp(Lon_IROC{ii},'E')-1),'%f');
        IROC_Longitudes(ii) = C{1};
    elseif length(regexp(Lon_IROC{ii},'W'))==1
        C = textscan(Lon_IROC{ii}(1:regexp(Lon_IROC{ii},'W')-1),'%f');
        IROC_Longitudes(ii) = -1.*C{1};
    end
end

IROC_Latitudes(5)= (55.457+60.073)./2;
IROC_Longitudes(5)= -1.*(55.493+48.401)./2;

clear Lat_IROC Lon_IROC

idx_clim_per = intersect(find(Years_IROC>=1991),find(Years_IROC<=2020));
for ff=1:size(Data_IROC,3)
    mean_clim_per = mean(Data_IROC(idx_clim_per,2,ff),'omitnan');
    std_clim_per = std(Data_IROC(idx_clim_per,2,ff),[],'omitnan');
    Data_IROC(:,3,ff) = Data_IROC(:,2,ff)-repmat(mean_clim_per,size(Data_IROC,1),1);
    Data_IROC(:,4,ff) = (Data_IROC(:,2,ff)-repmat(mean_clim_per,size(Data_IROC,1),1))./...
        repmat(std_clim_per,size(Data_IROC,1),1);
    mean_clim_per = mean(Data_IROC(idx_clim_per,5,ff),'omitnan');
    std_clim_per = std(Data_IROC(idx_clim_per,5,ff),[],'omitnan');
    Data_IROC(:,6,ff) = Data_IROC(:,5,ff)-repmat(mean_clim_per,size(Data_IROC,1),1);
    Data_IROC(:,7,ff) = (Data_IROC(:,5,ff)-repmat(mean_clim_per,size(Data_IROC,1),1))./...
        repmat(std_clim_per,size(Data_IROC,1),1);
    clear mean_clim_per std_clim_per
end
