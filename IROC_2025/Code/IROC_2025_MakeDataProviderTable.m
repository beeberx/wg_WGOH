%script IROC_2025_MakeDataProviderTable.m

clear all;close all;clc;

IROC_data_path=[getenv('Working'),'\ICES Working Group Oceanic Hydrography\GitHub_wg_WGOH\IROC\Data\'];

allFiles = ls(IROC_data_path);

for ff=1:size(allFiles,1)
    allFiles(ff,:) = strrep(allFiles(ff,:),    '_Annual.csv',    '           ');
    allFiles(ff,:) = strrep(allFiles(ff,:),    '_Mnthly.csv',    '           ');
    allFiles(ff,:) = strrep(allFiles(ff,:),'_Timeseries.csv','               ');
    allFiles(ff,:) = strrep(allFiles(ff,:),'.',' ');
end


allFiles=unique(allFiles,'rows');
allFiles=cellstr(allFiles);
allFiles([1,34])=[];

OutputTable = cell(size(allFiles,1),8);

for ff=1:size(allFiles,1)
    ftrunk=[IROC_data_path,allFiles{ff},'*'];
    subFiles = ls(ftrunk);
    subIdx = find(cellfun(@isempty,regexpi(cellstr(subFiles),'_Annual'))==0);
    if isempty(subIdx)
        subIdx=1;
    end
    NumHeadLines = 0;bline = repmat(' ',1,15);bline(1)='#';
    fid = fopen(strtrim([IROC_data_path,subFiles(subIdx,:)]));
    %     while ~strncmpi(bline,'year',4)
    while ~isempty(regexpi(bline,'#'))
        bline = fgetl(fid);
        if regexpi(bline,'Region Code')
            tmp = strsplit(bline,','); 
            OutputTable(ff,1) = tmp(2);
        elseif regexpi(bline,'Index')
            tmp = strsplit(bline,','); 
            OutputTable(ff,2) = tmp(2);
        elseif regexpi(bline,'Station Description')
            tmp = strsplit(bline,','); 
            OutputTable(ff,3) = tmp(2);
        elseif regexpi(bline,'latitude')
            tmp = strsplit(bline,','); 
            OutputTable(ff,4) = tmp(2);
        elseif regexpi(bline,'longitude')
            tmp = strsplit(bline,','); 
            OutputTable(ff,5) = tmp(2);
        elseif regexpi(bline,'measurement depth')
            tmp = strsplit(bline,','); 
            OutputTable(ff,6) = tmp(2);
        elseif regexpi(bline,'data source')
            tmp = strsplit(bline,','); 
            OutputTable(ff,7) = tmp(2);
        elseif regexpi(bline,'Contact Name')
            tmp = strsplit(bline,','); 
            OutputTable(ff,8) = tmp(2);
        end
        if length(bline)>15
            bline = bline(1:15);
        end
        NumHeadLines = NumHeadLines +1;
    end
    fid = fclose(fid);clear fid bline
end

RegionOrder = {'BBAY','NEAS','SPNA','BICC','NSBS','NWES','BALT'};

OutputTable2 = [];
for rr=1:length(RegionOrder)
    regIdx = find(strcmp(OutputTable(:,1),RegionOrder{rr}));
    OutputTable2 = cat(1,OutputTable2,OutputTable(regIdx,:));
end

OutputTable3 = cell2table(OutputTable2,'VariableNames',{'Region','Index','Station Description','Latitude','Longitude','Measurement Depth (m)','Data Source','Contact Name'});
writetable(OutputTable3,'IROC_2025_DataContributors.xlsx');

