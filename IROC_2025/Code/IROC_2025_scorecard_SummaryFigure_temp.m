%


% define data paths
IROC_data_path=[getenv('Working'),'\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\IROC\Data\'];
figpath=[pwd,filesep];

% script to set the timeseries selection for the summary figures
run ('./IROC_2025_SummaryFigure_SelectedTimeseries.m');
clear BBAY_TS NEAS_TS SPNA_TS NSBS_TS NWES_TS BALT_TS BICC_TS

%set colour schemes
% red blue colourmap - requires cbrewer
tmp = cbrewer('div','PiYG',3);
rbc = cat(1,flipud(cbrewer('seq','Blues',7)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',7));
rbc(rbc > 1) = 1;
rbc(rbc < 0) = 0;
clear tmp
%light grey for bar outlines and x-axis at 0
lgrey = [.7 .7 .7];

% find last year and set years
tmp = datevec(now);
last_year = tmp(1);clear tmp

ylower = 1975;
yhigher = last_year;

pnum = size(IROC_TS,1);
deltaplot = 0;%0.02;
deltaoff = 0.02;
pos_mat = zeros(pnum,4);
ph = floor((0.97-(pnum*deltaplot))/pnum.*100)./100;
pos_mat(:,1)=0.05;
pos_mat(:,2)=deltaoff+([1:pnum]-1)*(deltaplot+ph);
pos_mat(:,3)=0.9;
pos_mat(:,4)=ph;

Years_IROC = 1950:last_year;
Data_IROC = NaN.*zeros([length(Years_IROC), 7, length(IROC_TS)]);
Lat_IROC = cell(length(IROC_TS),1);
Lon_IROC = cell(length(IROC_TS),1);

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

run IROC_2025_red_blue_colormap_convention.m

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
plot(Years_IROC,squeeze(Data_IROC(:,2,:)))

IROC_TS_Labels = {'Fyllas Bank';
    'NW Georges Bank';
    'Gulf of St Lawrence';
    'Newfoundland Shelf';
    'Central Labrador Sea';
    'Sub-polar Mode Water, Central Irminger Sea';
    'Upper Waters, Iceland Basin';
    'North Atlantic Water, Faroe-Shetland Channel';
    'East Icelandic Current';
    'Ocean Weather Ship Mike, Norwegian Sea';
    'Helgoland Roads, North Sea';
    'Surface Water, Skagerrak';
    'North_Sea_HelgolandRoads_Annual.csv'    ;
    'Baltic_BY15_Annual.csv'                 ;
    'Biscay_Santander7_300-600_Timeseries.csv';
    'Cadiz_STOCA-SP6_100_300_Timeseries.csv' ;
    'CanaryBasinCTZ_200-800_Timeseries.csv'   }

figh = fun_plot_colourboxes(Years_IROC,[1:size(Data_IROC,3)],squeeze(Data_IROC(:,4,:))',IROC_TS,rbc,'title')

idx2plot = intersect(find(Years_IROC>=1971),find(Years_IROC<=2024));
figh = fun_plot_colourboxes_with_value(Years_IROC(idx2plot),[1:size(Data_IROC,3)],squeeze(Data_IROC(idx2plot,4,:))',squeeze(Data_IROC(idx2plot,4,:))',IROC_TS,rbc,'title')