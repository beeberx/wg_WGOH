clear all;close all;clc;

filedir_UV = ['\\isilonml\Oceanography_Work_Area\Data_External\CMEMS_NWSHELF_MULTIYEAR_PHY_004_009\'];
filenam_UV = [filedir_UV,'NWS_RAN_transports_1993_2024.nc'];
tmp = ncinfo(filenam_UV);
VarNames = {tmp.Variables.Name};

for vv=1:size(VarNames,2)
    eval([VarNames{vv},'= ncread(''',filenam_UV,''',''',VarNames{vv},''');'])
end

Time = datevec(double(time_counter)+datenum(1991,2,1,0,0,0));

Time_mm = unique(Time(:,1:2),'rows');
Time_mm(:,3)=15;

Time_yy = unique(Time(:,1));

for yy=1:size(Time_yy,1)
    for mm= 1:12
        idxM = intersect(find(Time_mm(:,1)==Time_yy(yy)),find(Time_mm(:,2)==mm));
        if isempty(idxM);clear idxM;continue;end
        idxT = intersect(find(Time(:,1)==Time_yy(yy)),find(Time(:,2)==mm));
        if length(idxT)~=eomday(Time_mm(idxM,1),Time_mm(idxM,2));
            continue
        end
        for vv=1:size(VarNames,2)
            if ismember(VarNames{vv},{'section_name','time_counter'});
                continue
            end
            eval(['tmp = ' VarNames{vv},';'])
            mon_mean = mean(tmp(:,idxT),2);
            mon_std =  std(tmp(:,idxT),[],2);
            if ~exist([VarNames{vv},'_mm'],'var')
                eval([VarNames{vv},'_mm = NaN.*zeros(size(tmp,1),size(Time_mm,1));']);
                eval([VarNames{vv},'_ms = NaN.*zeros(size(tmp,1),size(Time_mm,1));']);
            end
            eval([VarNames{vv},'_mm(:,idxM) = mon_mean;']);
            eval([VarNames{vv},'_ms(:,idxM) = mon_std;']);
            clear mon_mean mon_std tmp
        end;clear vv
        clear idxT idxM
    end;clear mm
    for vv=1:size(VarNames,2)
        if ismember(VarNames{vv},{'section_name','time_counter'});
            continue
        end
        eval(['tmp = ' VarNames{vv},'_mm;'])
        idxM = find(Time_mm(:,1)==Time_yy(yy));
        if sum(isnan(tmp(1,idxM)))>0 || length(idxM)~=12
            continue
        end
        yrs_mean = mean(tmp(:,idxM),2);
        yrs_std =  std(tmp(:,idxM),[],2);
        if ~exist([VarNames{vv},'_ym'],'var')
            eval([VarNames{vv},'_ym = NaN.*zeros(size(tmp,1),size(Time_yy,1));']);
            eval([VarNames{vv},'_ys = NaN.*zeros(size(tmp,1),size(Time_yy,1));']);
            clear mon_mean mon_std tmp
        end
        eval([VarNames{vv},'_ym(:,yy) = yrs_mean;']);
        eval([VarNames{vv},'_ys(:,yy) = yrs_std;']);
        clear yrs_mean yrs_std tmp
    end;clear vv
end;clear yy