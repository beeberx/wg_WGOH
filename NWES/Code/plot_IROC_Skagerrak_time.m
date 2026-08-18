% PLOT_IROC_SKAGERRAK_TIME
%
%                This code will plot the time evolution of temperature and salinity for the IROC time series
%                from the Central Skagerrak, here displayed as annual values from the 1950s to 2020s.
%
%                Annual values are inferred for those years having data for a minimum of XX months (e.g. XX=9).
%                Monthly/annual climatological values provided in the code and estimated using another 
%                Matlab-program are taken into account to get meaningful yearly estimates.
%
%                In order to store output as png-file, the export_fig-toolbox is required, which can be found here:
%                https://github.com/altmany/export_fig
%
%                usage  : plot_IROC_Skagerrak_time
%
%                input  : define pathways, filenames and input/output directories internally
%
%                output : png plots like "IROC2025_temp_Skagerrak_sfc_time_THRESHx_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_temp_Skagerrak_deep_time_THRESHx_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_temp_Skagerrak_bottom_THRESHx_time_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_sfc_time_THRESHx_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_deep_time_THRESHx_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_bottom_THRESHx_time_2022-2024_ddmmmyyyy.png"
%
%                uses   : IROC time series as provided by ICES-WGOH and/or WGOH members, export_fig-toolbox,
%                         moveto.m and mytitle.m (both provided as local functions at the end of this code)
%
%                Version 1.0, 19.02.2025, dkieke, Matlab 9.5, R2018b@VC34648
%

clear
close all

%% 01. pre-define some parameters ...

% choose modus of interest ...
% 0: original data (creates biased time series; experimental, so use with caution)
% 1: take advantage of climatological means ...

modus = 1;  

% define minimum number of months per year required to compute a valid annual average ...

minMon_THRESH = 9;

% define reference period ...

yr_ref = [1991:2020];

% define x-axis limits ...

xlim = [1960,2030];

% define markersize ...

ms = 2;

% define necessary indices for the selection of time series of interest ...

idx = [1:3]; % temperature and salinity from the surface, deep water range and bottom water of the Central Skagerrak

% define most recent years of interest ...

mry = 2022:2024;

% define output directory ...

fname_prefx = ['IROC2025']; % need for directory and filenames ...
datadir_OUT = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\figures\'];

%% 02. define and load input data ...

datadir_IN = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\data_download\'];
fname_IN   = {
    'Skagerrak_0-10_Surface-water_Timeseries.csv'          % Long-term averaging period data: not given
    'Skagerrak_100-200_Deep-water_Timeseries.csv'          % LTAP: not given
    'Skagerrak_600_Bottom-water_Timeseries.csv'            % LTAP: not given
    };

%% 03. define climatologocal mean values ...

% climatological temperature and salinity values for the Central Skagerrak calculated
% using "plot_IROC_Skgarrak_annual.m" for the reference period 1991-2020 ...

clim_temp = [
    5.88  4.82  4.44  5.98  8.53 12.40 14.70 16.67 15.66 13.04  9.86  7.73   % sfc, 0-10 m
    7.44  6.89  6.46  6.54  6.72  7.01  7.28  7.42  7.58  7.75  8.32  8.53   % deep water, 100-200 m
    6.31  6.28  6.17  5.98  6.04  6.04  6.07  6.07  6.09  6.11  6.13  6.17]; % bottom water, 600 m

clim_sal = [
    33.07 32.55 32.15 31.06 30.43 29.80 30.41 30.83 31.57 32.23 32.50 32.66   % sfc, 0-10 m
    34.99 35.01 35.04 35.10 35.12 35.15 35.14 35.14 35.16 35.13 35.10 35.04   % deep water, 100-200 m
    35.16 35.16 35.15 35.13 35.15 35.14 35.15 35.15 35.15 35.15 35.14 35.15]; % bottom water, 600 m

% define colormap of interest ...

cmap = [
    0.9714    0.3563    0.0118
    0.7059         0    0.4118
    0    0.6078    0.6947
    %     1.0000    0.8683         0
    %     0.9877    0.5529         0
    %     0    0.4650    0.7703
    %     0    0.5742    0.8291
    %     0.0784    0.2521    0.5798
    0.9412         0    0.0824
    0.9966    0.7289         0
    %     0.3361         0    0.4118
    %     0.9384    0.9132         0
    %     0.6762    0.8375    0.0185
    %     0.0275    0.6863    0.1294
    0.0039    0.6190    0.4218];

%% 04. loop over time series of interest identified via pre-selected indices stored in 'idx' ...

for ii = idx
    
    if exist([datadir_IN,char(fname_IN(ii))],'file')
        
        disp([' '])
        disp(['--> load input data: ',[datadir_IN,char(fname_IN(ii))]])
        
        X = readtable([datadir_IN,char(fname_IN(ii))]);
        
        if ii == 1 
            %% 05. 'Skagerrak_0-10_Surface-water_Timeseries.csv'
            
            data = X(12:end,:);
            
            % replace empty matrix entries with NaN ...
            
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};
            
            year = floor(str2num(char((data{:,1}))));                                    % year
            mnth = ceil((str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12); % month 1:12
            temp = str2num(char((data{:,2})));                                           % temperature
            sal  = str2num(char((data{:,3})));                                           % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);  % years with data
            mn_id = unique(mnth);  % months with data
            
            % create vectors prefilled with NaNs ...
            
            temp_tim = nan(1,length(yr_id));
            sal_tim  = nan(1,length(yr_id));
            
            % only needed if modus = 0 ...
            
            temp_tim_num = nan(1,length(yr_id));
            sal_tim_num  = nan(1,length(yr_id));
            
            % get mean values for reference period ...           
            
            for kk = 1:length(yr_ref)
                
                knd = find(year == yr_ref(kk));
                temp_ref(kk) = nanmean(temp(knd));                
                sal_ref(kk) = nanmean(sal(knd));
            end
            
            % get Long-Term Mean (LTM) and STD for the reference preiod of interest  ...
            
            temp_LTM_mean = nanmean(temp_ref);
            temp_LTM_std  = nanstd(temp_ref);
            
            sal_LTM_mean = nanmean(sal_ref);
            sal_LTM_std  = nanstd(sal_ref);
            
            % loop over number of years ...
            
            for jj = 1:length(yr_id)
                
                % identify data for each year ...
                
                jnd = find(year == yr_id(jj));
                
                if ~isempty(jnd)
                    
                    if modus == 0 % pure mean with biased data
                        
                        % get annual averages ...
                        
                        temp_tim(jj) = nanmean(temp(jnd));
                        sal_tim(jj)  = nanmean(sal(jnd));
                        
                        temp_tim_num(jj) = length(find(isfinite(temp(jnd)) == 1));
                        sal_tim_num(jj)  = length(find(isfinite(sal(jnd)) == 1));
                        
                    elseif modus == 1 % consider climatological means ...
                        
                        idx_t = (year == yr_id(jj) & ~isnan(temp));
                        idx_s = (year == yr_id(jj) & ~isnan(sal));
                        
                        % only process years with enough data ...
                        
                        if sum(idx_t) >= minMon_THRESH
                            
                            % get SST and corresponding months for the current year ...
                            
                            temp_current   = temp(idx_t); % observed temperature for current year
                            months_current = mnth(idx_t); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            temp_anom = temp_current - clim_temp(ii,months_current)';
                            
                            % average the anomalies over the available months ...
                            
                            avg_anomaly = mean(temp_anom);
                            
                            % Add the annual climatological mean to the average anomaly to get the annual temperature estimate
                            
                            temp_tim(jj) = temp_LTM_mean + avg_anomaly;
                            
                        else                            
                            % if not enough data, leave as NaN  ...                            
                            temp_tim(jj) = NaN;                            
                        end
                        
                        if sum(idx_s) >= minMon_THRESH
                            
                            % get salinity and corresponding months for the current year ...
                            
                            sal_current      = sal(idx_s); % observed salinity for current year
                            months_current_s = mnth(idx_s); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            sal_anom = sal_current - clim_sal(ii,months_current_s)';
                            
                            % average the salinity anomalies over the available months ...
                            
                            avg_anomaly_s = mean(sal_anom);
                            
                            % add the annual climatological salinity mean to the average salinity anomaly to get the annual salinity estimate
                            
                            sal_tim(jj) = sal_LTM_mean + avg_anomaly_s;
                            
                        else                            
                            % if not enough data, leave as NaN  ...                            
                            sal_tim(jj) = NaN;                            
                        end
                        
                    end
                end
            end
            
            % plot temperature ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[temp_LTM_mean,temp_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[temp_LTM_mean+temp_LTM_std,temp_LTM_mean+temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[temp_LTM_mean-temp_LTM_std,temp_LTM_mean-temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot time series for entire time range ...
            
            hp(3) = plot(yr_id,temp_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[7,13])
            xlabel('Year')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Surface Temperature (0-10m)'])
                 
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_sfc_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological salinity mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[sal_LTM_mean,sal_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[sal_LTM_mean+sal_LTM_std,sal_LTM_mean+sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[sal_LTM_mean-sal_LTM_std,sal_LTM_mean-sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot salinity time series for entire time range ...
            
            hp(3) = plot(yr_id,sal_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[29,34])
            xlabel('Year')
            ylabel('Salinity [°C]')
            mytitle(['Skagerrak Surface Salinity (0-10m)'])
            
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_sfc_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
        elseif ii == 2 
            %% 06. 'Skagerrak_100-200_Deep-water_Timeseries.csv'
            
            data = X(12:end,:);
            
            % replace empty entries with NaN ...
            
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};
                        
            year = floor(str2num(char((data{:,1}))));                                    % year
            mnth = ceil((str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12); % month 1:12
            temp = str2num(char((data{:,2})));                                           % temperature
            sal  = str2num(char((data{:,3})));                                           % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);  % years with data
            mn_id = unique(mnth);  % months with data
            
            % create vectors prefilled with NaNs ...
            
            temp_tim = nan(1,length(yr_id));
            sal_tim  = nan(1,length(yr_id));
            
            temp_tim_num = nan(1,length(yr_id));
            sal_tim_num  = nan(1,length(yr_id));
            
            % get mean values for reference period ...   
            
            for kk = 1:length(yr_ref)
                
                knd = find(year == yr_ref(kk));
                temp_ref(kk) = nanmean(temp(knd));
                sal_ref(kk) = nanmean(sal(knd));
            end
            
            % get Long-Term Mean (LTM) and STD for the reference preiod of interest  ...
            
            temp_LTM_mean = nanmean(temp_ref);
            temp_LTM_std  = nanstd(temp_ref);
            
            sal_LTM_mean = nanmean(sal_ref);
            sal_LTM_std  = nanstd(sal_ref);
            
            % loop over number of years ...
            
            for jj = 1:length(yr_id)
                
                % identify data for each year ...
                
                jnd = find(year == yr_id(jj));
                
                if ~isempty(jnd)
                    
                    if modus == 0 % pure mean
                        
                        % get annual averages ...
                        
                        temp_tim(jj) = nanmean(temp(jnd));
                        sal_tim(jj)  = nanmean(sal(jnd));
                        
                        temp_tim_num(jj) = length(find(isfinite(temp(jnd)) == 1));
                        sal_tim_num(jj)  = length(find(isfinite(sal(jnd)) == 1));
                        
                    elseif modus == 1 % weighted mean
                        
                        idx_t = (year == yr_id(jj) & ~isnan(temp));
                        idx_s = (year == yr_id(jj) & ~isnan(sal));
                        
                        % only process years with enough data ...
                        
                        if sum(idx_t) >= minMon_THRESH
                            
                            % get SST and corresponding months for the current year ...
                            
                            temp_current   = temp(idx_t); % observed temperature for current year
                            months_current = mnth(idx_t); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            temp_anom = temp_current - clim_temp(ii,months_current)';
                            
                            % average the anomalies over the available months ...
                            
                            avg_anomaly = mean(temp_anom);
                            
                            % Add the annual climatological mean to the average anomaly to get the annual temperature estimate
                            
                            temp_tim(jj) = temp_LTM_mean + avg_anomaly;
                            
                        else
                            
                            % if not enough data, leave as NaN  ...
                            
                            temp_tim(jj) = NaN;
                            
                        end
                        
                        if sum(idx_s) >= minMon_THRESH
                            
                            % get salinity and corresponding months for the current year ...
                            
                            sal_current      = sal(idx_s); % observed salinity for current year
                            months_current_s = mnth(idx_s); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            sal_anom = sal_current - clim_sal(ii,months_current_s)';
                            
                            % average the salinity anomalies over the available months ...
                            
                            avg_anomaly_s = mean(sal_anom);
                            
                            % add the annual climatological salinity mean to the average salinity anomaly to get the annual salinity estimate
                            
                            sal_tim(jj) = sal_LTM_mean + avg_anomaly_s;
                            
                        else                            
                            % if not enough data, leave as NaN  ...                            
                            sal_tim(jj) = NaN;                            
                        end                        
                    end
                end
            end
            
            % plot temperature ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[temp_LTM_mean,temp_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[temp_LTM_mean+temp_LTM_std,temp_LTM_mean+temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[temp_LTM_mean-temp_LTM_std,temp_LTM_mean-temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot time series for entire time range ...
            
            hp(3) = plot(yr_id,temp_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[5,10])
            xlabel('Year')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Deep Water Temperature (100-200 m)'])
                   
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_deep_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological salinity mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[sal_LTM_mean,sal_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[sal_LTM_mean+sal_LTM_std,sal_LTM_mean+sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[sal_LTM_mean-sal_LTM_std,sal_LTM_mean-sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot salinity time series for entire time range ...
            
            hp(3) = plot(yr_id,sal_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[34.6,35.4])
            xlabel('Year')
            ylabel('Salinity [°C]')
            mytitle(['Skagerrak Deep Water Salinity (100-200 m)'])
            
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_deep_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');            

        elseif ii == 3 
            %% 07. 'Skagerrak_600_Bottom-water_Timeseries.csv'
            
            data = X(12:end,:);
            
            % replace empty entries with NaN ...
            
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};
            
            year = floor(str2num(char((data{:,1}))));                                    % year
            mnth = ceil((str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12); % month 1:12
            temp = str2num(char((data{:,2})));                                           % temperature
            sal  = str2num(char((data{:,3})));                                           % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);  % years with data
            mn_id = unique(mnth);  % months with data
            
            % create vectors prefilled with NaNs ...
            
            temp_tim = nan(1,length(yr_id));
            sal_tim  = nan(1,length(yr_id));
            
            % only needed if modus = 0 ...
            
            temp_tim_num = nan(1,length(yr_id));
            sal_tim_num  = nan(1,length(yr_id));
            
            % get mean values for reference period ...           
            
            for kk = 1:length(yr_ref)
                
                knd = find(year == yr_ref(kk));
                temp_ref(kk) = nanmean(temp(knd));
                sal_ref(kk) = nanmean(sal(knd));
            end
            
            % get Long-Term Mean (LTM) and STD for the reference preiod of interest  ...
            
            temp_LTM_mean = nanmean(temp_ref);
            temp_LTM_std  = nanstd(temp_ref);
            
            sal_LTM_mean = nanmean(sal_ref);
            sal_LTM_std  = nanstd(sal_ref);
            
            % loop over number of years ...
            
            for jj = 1:length(yr_id)
                
                % identify data for each year ...
                
                jnd = find(year == yr_id(jj));
                
                if ~isempty(jnd)
                    
                    if modus == 0 % pure mean with biased data
                        
                        % get annual averages ...
                        
                        temp_tim(jj) = nanmean(temp(jnd));
                        sal_tim(jj)  = nanmean(sal(jnd));
                        
                        temp_tim_num(jj) = length(find(isfinite(temp(jnd)) == 1));
                        sal_tim_num(jj)  = length(find(isfinite(sal(jnd)) == 1));
                        
                    elseif modus == 1 % consider climatological means ...
                        
                        idx_t = (year == yr_id(jj) & ~isnan(temp));
                        idx_s = (year == yr_id(jj) & ~isnan(sal));
                        
                        % only process years with enough data ...
                        
                        if sum(idx_t) >= minMon_THRESH
                            
                            % get SST and corresponding months for the current year ...
                            
                            temp_current   = temp(idx_t); % observed temperature for current year
                            months_current = mnth(idx_t); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            temp_anom = temp_current - clim_temp(ii,months_current)';
                            
                            % average the anomalies over the available months ...
                            
                            avg_anomaly = mean(temp_anom);
                            
                            % Add the annual climatological mean to the average anomaly to get the annual temperature estimate
                            
                            temp_tim(jj) = temp_LTM_mean + avg_anomaly;
                            
                        else                            
                            % if not enough data, leave as NaN  ...                            
                            temp_tim(jj) = NaN;                            
                        end
                        
                        if sum(idx_s) >= minMon_THRESH
                            
                            % get salinity and corresponding months for the current year ...
                            
                            sal_current      = sal(idx_s); % observed salinity for current year
                            months_current_s = mnth(idx_s); % months of current year
                            
                            % compute anomalies: difference between observed temperature and the climatological mean for that month
                            
                            sal_anom = sal_current - clim_sal(ii,months_current_s)';
                            
                            % average the salinity anomalies over the available months ...
                            
                            avg_anomaly_s = mean(sal_anom);
                            
                            % add the annual climatological salinity mean to the average salinity anomaly to get the annual salinity estimate
                            
                            sal_tim(jj) = sal_LTM_mean + avg_anomaly_s;
                            
                        else                            
                            % if not enough data, leave as NaN  ...                            
                            sal_tim(jj) = NaN;                            
                        end
                        
                    end
                end
            end
            
            % plot temperature ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[temp_LTM_mean,temp_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[temp_LTM_mean+temp_LTM_std,temp_LTM_mean+temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[temp_LTM_mean-temp_LTM_std,temp_LTM_mean-temp_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot time series for entire time range ...
            
            hp(3) = plot(yr_id,temp_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[3,9])
            xlabel('Year')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Bottom Temperature (600 m)'])
                        
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_bottom_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological salinity mean value and STD representing the reference period ...
            
            hp(1) = plot(yr_ref([1,end]),[sal_LTM_mean,sal_LTM_mean],'-','linewidth',0.3,'color',cmap(ii,:));
            hp(2) = plot(yr_ref([1,end]),[sal_LTM_mean+sal_LTM_std,sal_LTM_mean+sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            plot(yr_ref([1,end]),[sal_LTM_mean-sal_LTM_std,sal_LTM_mean-sal_LTM_std],'--k','linewidth',0.1,'color',cmap(ii,:));
            
            % plot salinity time series for entire time range ...
            
            hp(3) = plot(yr_id,sal_tim,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+1);
            
            set(gca,'fontweight','bold','box','on','xtick',[xlim(1):10:xlim(2)],'xticklabel',[xlim(1):10:xlim(2)],'xlim',xlim,'ylim',[34.8,35.4])
            xlabel('Year')
            ylabel('Salinity [°C]')
            mytitle(['Skagerrak Bottom Salinity (600 m)'])
            
            moveto('s',0.4)
            
            % [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_bottom_time_',num2str(mry(1)),'-',num2str(mry(end)),'_THRESH',num2str(minMon_THRESH),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
        end        
    end    
end

%% local functions ...

%%%%%%% local function: mytitle.m %%%%%%%%

function hh = mytitle(string,varargin)
%MYTITLE  Graph title.
%   MYTITLE('text') adds text at the top left corner of the current axis.
%
%   MYTITLE('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the title.
%
%   H = MYTITLE(...) returns the handle to the text object used as the title.
%
%   See also XLABEL, YLABEL, ZLABEL, TEXT.
%
%
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.8 $  $Date: 1997/11/21 23:33:15 $
%
%   Vers. 2.0, 19.07.2009, dkieke, Matlab 7.5, R2007b@gazelle
%   Vers. 1.0, 24.11.2003, d.kieke, based on title.m

ax  = gca;
h2  = get(ax,'xlim');
h3  = get(ax,'ylim');
dx  = abs(diff(h2));
dy  = 1*abs(diff(h3));
h   = get(ax,'title');
pos = get(h,'position');

if nargin > 1 & (nargin-1)/2-fix((nargin-1)/2),
    error('Incorrect number of input arguments')
end

% Over-ride text objects default font attributes with
% the Axes' default font attributes.

set(h,'FontAngle',get(ax, 'FontAngle'), ...
      'FontName',get(ax, 'FontName'), ...
      'FontSize',get(ax, 'FontSize'), ...
      'FontWeight',get(ax, 'FontWeight'), ...
      'Rotation',0, ...
      'HorizontalAlignment','left', ...
      'position',[h2(1)+(0*dx)/100,h3(2)+(3*dy)/100,pos(3)], ...
      'string',string, varargin{:});

if nargout > 0
    hh = h;
end
end

%%%%%%% local function: moveto.m %%%%%%%%
function     moveto(pos,dx)

% MOVETO      Move CURRENT figure to new left/right/upper/lower position.
%
%             usage  : moveto(pos,dx)
%
%             input  : pos   'u','d','l','r': up, down,left,right
%                            's','e'        : shorten, elongate
%                            'squ','brd'    : squeeze, broaden
%                      dx    figure is shifted by this value 
%                            (screen coordinates)
%
%             output : ---
%
%             uses   : ---
%
%             check values : moveto(0.05,'u')
%
%             $Log: moveto.m,v $
%             Revision 1.1  2002-10-30 13:03:40+01  dkieke
%             Initial revision
%

if nargin < 2
  dx =0.05;
end

opos = get(gca,'position');

if strcmp(pos,'u')
  set(gca,'position',[opos(1) opos(2)+dx opos(3:4)])
elseif strcmp(pos,'d')
  set(gca,'position',[opos(1) opos(2)-dx opos(3:4)])
elseif strcmp(pos,'r')
  set(gca,'position',[opos(1)+dx opos(2:4)])
elseif strcmp(pos,'l')
  set(gca,'position',[opos(1)-dx opos(2:4)])
elseif strcmp(pos,'e')
  set(gca,'position',[opos(1:3) opos(4)+dx])
elseif strcmp(pos,'s')
  set(gca,'position',[opos(1:3) opos(4)-dx])
elseif strcmp(pos,'squ')
  set(gca,'position',[opos(1:2) opos(3)-dx opos(4)])
elseif strcmp(pos,'brd')
  set(gca,'position',[opos(1:2) opos(3)+dx opos(4)])
end

end