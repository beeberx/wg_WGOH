%script IROC_2025_MakeFullMetaTable.m

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

OutputTable = cell(size(allFiles,1),50);
AllVarNames={};

for ff=1:size(allFiles,1)
    ftrunk=[IROC_data_path,allFiles{ff},'*'];
    subFiles = ls(ftrunk);
    subIdx = find(cellfun(@isempty,regexpi(cellstr(subFiles),'_Annual'))==0);
    if isempty(subIdx)
        subIdx=1;
    end
    NumHeadLines = 0;bline = repmat(' ',1,15);bline(1)='#';
    fid = fopen(strtrim([IROC_data_path,subFiles(subIdx,:)]));
    bline = fgetl(fid); 
    while ~isempty(regexpi(bline,'#'))  
        tmp = strsplit(bline,':');
        tmp2= strsplit(bline,',');
        VarName = tmp{1};
        VarName = strtrim(VarName(regexpi(VarName,'#')+1:end));
        VarContent = tmp2(2);
        if ismember(VarName,AllVarNames)
            idxC = find(strcmp(VarName,AllVarNames));
        else
            AllVarNames = cat(1,AllVarNames,VarName);
            idxC = length(AllVarNames);
        end
        OutputTable(ff,idxC) = VarContent;
        while ~isempty(regexpi(bline,'#'))  
            bline = fgetl(fid);
            if ~isempty(regexpi(bline,':'));break;end
        end
    end
    fid = fclose(fid);clear fid bline
end

RegionOrder = {'BBAY','NEAS','SPNA','BICC','NSBS','NWES','BALT'};

OutputTable2 = [];
for rr=1:length(RegionOrder)
    regIdx = find(strcmp(OutputTable(:,3),RegionOrder{rr}));
    OutputTable2 = cat(1,OutputTable2,OutputTable(regIdx,:));
end

OutputTable3 = cell2table(OutputTable2(:,1:length(AllVarNames)),'VariableNames',AllVarNames);
writetable(OutputTable3,'IROC_2025_AllMetaData.xlsx');

