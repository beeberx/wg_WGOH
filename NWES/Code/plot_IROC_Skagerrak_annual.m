
% PLOT_IROC_SKAGERRAK_ANNUAL
%
%                This code will plot the annual evolution of temperature and salinity for the IROC time series 
%                from the Central Skagerrak.
%                In order to store output as png-file, the export_fig-toolbox is required, which can be found here: 
%                https://github.com/altmany/export_fig
%
%                Time series are plotted with long-term averages +/- STD and max/min lines added. These values 
%                are taken calculated from the input files.
%
%                usage  : plot_IROC_Skagerrak_annual
%
%                input  : define pathways, filenames and input/output directories internally
%
%                output : png plots like "IROC2025_temp_Skagerrak_sfc_annual_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_temp_Skagerrak_deep_annual_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_temp_Skagerrak_bottom_annual_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_sfc_annual_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_deep_annual_2022-2024_ddmmmyyyy.png",
%                                        "IROC2025_sal_Skagerrak_bottom_annual_2022-2024_ddmmmyyyy.png"
%
%                uses   : IROC time series as provided by ICES-WGOH and/or WGOH members, export_fig-toolbox,
%                         mytitle.m (provided as local function at the end of this code)
%
%                Version 1.0, 18.02.2025, dkieke, Matlab 9.5, R2018b@VC34648
%

clear
close all

% define markersize ...

ms = 2;

% define necessary indices for the selection of time series of interest ...

idx = [1:3]; % temperature and salinity from the surface, deep water range and bottom water of the Central Skagerrak

% define most recent years of interest ...

mry = 2022:2024;

% define output directory ...

fname_prefx = ['IROC2025']; % need for directory and filenames ...
datadir_OUT = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\figures\'];

%% 01. define and load input data ...

datadir_IN = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\data_download\'];
fname_IN   = {
    'Skagerrak_0-10_Surface-water_Timeseries.csv'          % Longterm averaging period: not given
    'Skagerrak_100-200_Deep-water_Timeseries.csv'          % LTAP: not given
    'Skagerrak_600_Bottom-water_Timeseries.csv'            % LTAP: not given
    };

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

% loop over time series of interest identified via pre-selected indices stored in 'idx' ...

for ii = idx
    
    if exist([datadir_IN,char(fname_IN(ii))],'file')
        
        disp([' '])
        disp(['--> load input data: ',[datadir_IN,char(fname_IN(ii))]])
        
        X = readtable([datadir_IN,char(fname_IN(ii))]);
        
        if ii == 1 % 'Skagerrak_0-10_Surface-water_Timeseries.csv'
            
            data = X(12:end,:);
            
            % replace empty entries with NaN ...
            
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};            
            
            year = floor(str2num(char((data{:,1}))));                              % year
            mnth = (str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12; % month
            temp = str2num(char((data{:,2})));                                     % temperature
            sal  = str2num(char((data{:,3})));                                     % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);
            mn_id = unique(mnth);
            
            % define reference period of interest ...
            
            yr_ref = [1991,2020];
            
            ind = find(year >= yr_ref(1) & year <= yr_ref(2));
            
            % get mean and STD ...
            
            temp_LTM_mean = nanmean(temp(ind));
            temp_LTM_std  = nanstd(temp(ind));
            
            sal_LTM_mean = nanmean(sal(ind));
            sal_LTM_std  = nanstd(sal(ind));
            
            temp_ann_ref = nan(1,12);
            sal_ann_ref  = nan(1,12);
            
            temp_ann_ref_std = nan(1,12);
            sal_ann_ref_std  = nan(1,12);
            
            temp_ann_ref_min = nan(1,12);
            sal_ann_ref_min  = nan(1,12);
            
            temp_ann_ref_max = nan(1,12);
            sal_ann_ref_max  = nan(1,12);
            
            % get climatological annual evolution for the reference period ...
            
            for jj = 1:length(mn_id)
                
                jnd = find(mnth(ind) == mn_id(jj));
                
                temp_ann_ref(jj) = nanmean(temp(ind(jnd)));     % monthly mean temperature values for reference period
                sal_ann_ref(jj)  = nanmean(sal(ind(jnd)));      % monthly mean salinity values for reference period
                
                temp_ann_ref_std(jj) = nanstd(temp(ind(jnd)));  % monthly std temperature values for reference period
                sal_ann_ref_std(jj)  = nanstd(sal(ind(jnd)));   % monthly std salinity values for reference period
                
                temp_ann_ref_min(jj) = min(temp(ind(jnd)));     % monthly min temperature values for reference period
                sal_ann_ref_min(jj)  = min(sal(ind(jnd)));      % monthly min salinity values for reference period
                
                temp_ann_ref_max(jj) = max(temp(ind(jnd)));     % monthly max temperature values for reference period
                sal_ann_ref_max(jj)  = max(sal(ind(jnd)));      % monthly max salinity values for reference period
            end            
            
            % plot temperature ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value, STD, and min/max representing the reference period ...
            
            hp(1) = plot(mn_id,temp_ann_ref,'-k','linewidth',0.3);
            hp(2) = plot(mn_id,temp_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hp(3) = plot(mn_id,temp_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for most recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hp(kk+3) = plot(mn_id,temp(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[0,20])
            xlabel('Month')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Surface Temperature (0-10m)'])
            
            [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_sfc_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];            
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
                        disp([' '])
            disp(['monthly means, ref period: ', num2str(temp_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(temp_LTM_mean,'%6.2f')])
            
            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hpp(1) = plot(mn_id,sal_ann_ref,'-k','linewidth',0.3);
            hpp(2) = plot(mn_id,sal_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hpp(3) = plot(mn_id,sal_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for moszt recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hpp(kk+3) = plot(mn_id,sal(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[24,36])
            xlabel('Month')
            ylabel('Salinity')
            mytitle(['Skagerrak Surface Salinity (0-10m)'])
            
            [hll1,hll2] = legend(hpp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_sfc_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');      
            
            disp([' '])
            disp(['monthly means, ref period: ', num2str(sal_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(sal_LTM_mean,'%6.2f')])
            
        elseif ii == 2 % 'Skagerrak_100-200_Deep-water_Timeseries.csv'
            
            data = X(12:end,:);
            
            % replace empty entries with NaN ...
            
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};
                        
            year = floor(str2num(char((data{:,1})))); % year
            mnth = (str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12; % month
            temp = str2num(char((data{:,2}))); % temperature
            sal  = str2num(char((data{:,3}))); % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);
            mn_id = unique(mnth);
            
            yr_ref = [1991,2020];
            
            ind = find(year >= yr_ref(1) & year <= 2020);
            
            temp_LTM_mean = nanmean(temp(ind));
            temp_LTM_std  = nanstd(temp(ind));
            
            sal_LTM_mean = nanmean(sal(ind));
            sal_LTM_std  = nanstd(sal(ind));
            
            temp_ann_ref = nan(1,12);
            sal_ann_ref  = nan(1,12);
            
            temp_ann_ref_std = nan(1,12);
            sal_ann_ref_std  = nan(1,12);
            
            temp_ann_ref_min = nan(1,12);
            sal_ann_ref_min  = nan(1,12);
            
            temp_ann_ref_max = nan(1,12);
            sal_ann_ref_max  = nan(1,12);
            
            % get climatological annual evolution for the reference period ...
            
            for jj = 1:length(mn_id)
                
                jnd = find(mnth(ind) == mn_id(jj));
                
                temp_ann_ref(jj) = nanmean(temp(ind(jnd)));  % monthly mean temperature values for reference period
                sal_ann_ref(jj)  = nanmean(sal(ind(jnd)));   % monthly mean salinity values for reference period
                
                temp_ann_ref_std(jj) = nanstd(temp(ind(jnd)));  % monthly std temperature values for reference period
                sal_ann_ref_std(jj)  = nanstd(sal(ind(jnd)));   % monthly std salinity values for reference period
                
                temp_ann_ref_min(jj) = min(temp(ind(jnd)));  % monthly min temperature values for reference period
                sal_ann_ref_min(jj)  = min(sal(ind(jnd)));   % monthly min salinity values for reference period
                
                temp_ann_ref_max(jj) = max(temp(ind(jnd)));  % monthly max temperature values for reference period
                sal_ann_ref_max(jj)  = max(sal(ind(jnd)));   % monthly max salinity values for reference period
            end
                                    
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hp(1) = plot(mn_id,temp_ann_ref,'-k','linewidth',0.3);
            hp(2) = plot(mn_id,temp_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hp(3) = plot(mn_id,temp_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for moszt recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hp(kk+3) = plot(mn_id,temp(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[3,12])
            xlabel('Month')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Deep Water Temperature (100-200m)'])
            
            [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_deep_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];            
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
            disp([' '])
            disp(['monthly means, ref period: ', num2str(temp_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(temp_LTM_mean,'%6.2f')])
            
            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hpp(1) = plot(mn_id,sal_ann_ref,'-k','linewidth',0.3);
            hpp(2) = plot(mn_id,sal_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hpp(3) = plot(mn_id,sal_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for moszt recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hpp(kk+3) = plot(mn_id,sal(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[33,36])
            xlabel('Month')
            ylabel('Salinity')
            mytitle(['Skagerrak Deep Water Salinity (100-200m)'])
            
            [hll1,hll2] = legend(hpp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_deep_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');              
            
            disp([' '])
            disp(['monthly means, ref period: ', num2str(sal_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(sal_LTM_mean,'%6.2f')])
            
        elseif ii == 3 % 'Skagerrak_600_Bottom-water_Timeseries.csv'            
            
            data = X(12:end,:);
            
            % replace empty entries with NaN ...
                    
            data.StationDescription_(cellfun(@isempty,data.StationDescription_)) = {'NaN'};
            data.CentralSkagerrak(cellfun(@isempty,data.CentralSkagerrak))       = {'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))                               = {'NaN'};
            
            year = floor(str2num(char((data{:,1})))); % year
            mnth = (str2num(char(data{:,1}))-floor(str2num(char(data{:,1})))).*12; % month
            temp = str2num(char((data{:,2}))); % temperature
            sal  = str2num(char((data{:,3}))); % salinity
            
            % identify individual years and months present in time series ...
            
            yr_id = unique(year);
            mn_id = unique(mnth);
            
            yr_ref = [1991,2020];
            
            ind = find(year >= yr_ref(1) & year <= 2020);
            
            temp_LTM_mean = nanmean(temp(ind));
            temp_LTM_std  = nanstd(temp(ind));
            
            sal_LTM_mean = nanmean(sal(ind));
            sal_LTM_std  = nanstd(sal(ind));
            
            temp_ann_ref = nan(1,12);
            sal_ann_ref  = nan(1,12);
            
            temp_ann_ref_std = nan(1,12);
            sal_ann_ref_std  = nan(1,12);
            
            temp_ann_ref_min = nan(1,12);
            sal_ann_ref_min  = nan(1,12);
            
            temp_ann_ref_max = nan(1,12);
            sal_ann_ref_max  = nan(1,12);
            
            % get climatological annual evolution for the reference period ...
            
            for jj = 1:length(mn_id)
                
                jnd = find(mnth(ind) == mn_id(jj));
                
                temp_ann_ref(jj) = nanmean(temp(ind(jnd)));  % monthly mean temperature values for reference period
                sal_ann_ref(jj)  = nanmean(sal(ind(jnd)));   % monthly mean salinity values for reference period
                
                temp_ann_ref_std(jj) = nanstd(temp(ind(jnd)));  % monthly std temperature values for reference period
                sal_ann_ref_std(jj)  = nanstd(sal(ind(jnd)));   % monthly std salinity values for reference period
                
                temp_ann_ref_min(jj) = min(temp(ind(jnd)));  % monthly min temperature values for reference period
                sal_ann_ref_min(jj)  = min(sal(ind(jnd)));   % monthly min salinity values for reference period
                
                temp_ann_ref_max(jj) = max(temp(ind(jnd)));  % monthly max temperature values for reference period
                sal_ann_ref_max(jj)  = max(sal(ind(jnd)));   % monthly max salinity values for reference period
            end
                                    
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hp(1) = plot(mn_id,temp_ann_ref,'-k','linewidth',0.3);
            hp(2) = plot(mn_id,temp_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hp(3) = plot(mn_id,temp_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,temp_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for moszt recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hp(kk+3) = plot(mn_id,temp(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[3,12])
            xlabel('Month')
            ylabel('Temperature [°C]')
            mytitle(['Skagerrak Bottom Temperature (600m)'])
            
            [hl1,hl2] = legend(hp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_temp_Skagerrak_bottom_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];
            
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
            
            disp([' '])
            disp(['monthly means, ref period: ', num2str(temp_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(temp_LTM_mean,'%6.2f')])

            % plot salinity ...
            
            figure
            set(gcf,'color','w')
            
            hold on
            
            % plot climatological mean value and STD representing the reference period ...
            
            hpp(1) = plot(mn_id,sal_ann_ref,'-k','linewidth',0.3);
            hpp(2) = plot(mn_id,sal_ann_ref+temp_ann_ref_std,'--k','linewidth',0.1);
            hpp(3) = plot(mn_id,sal_ann_ref_min,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref_max,':k','linewidth',0.3,'color',[1,1,1].*0.5);
            plot(mn_id,sal_ann_ref-temp_ann_ref_std,'--k','linewidth',0.3,'color',[1,1,1].*0.5);
            
            % plot time series for moszt recent year(s) of interest ...
            
            for kk = 1:length(mry)
                knd = find(year == mry(kk));
                hpp(kk+3) = plot(mn_id,sal(knd),'-o','color',cmap(kk,:),'markerfacecolor',cmap(kk,:),'markeredgecolor',cmap(kk,:),'markersize',ms+3);
            end
            
            set(gca,'fontweight','bold','box','on','xtick',[0.5:11.5],'xticklabel',[1:12],'xlim',[0,12],'ylim',[33,36])
            xlabel('Month')
            ylabel('Salinity')
            mytitle(['Skagerrak Bottom Salinity (600m)'])
            
            [hll1,hll2] = legend(hpp,'mean','STD','min/max','2022','2023','2024','location','best','box','off');
            
            fname_OUT = [fname_prefx,'_sal_Skagerrak_bottom_annual_',num2str(mry(1)),'-',num2str(mry(end)),'_',datestr(now,'ddmmmyyyy')];
                        
            % export figure to png-file ...
            
            disp([' '])
            disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
            
            export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');       
            
            disp([' '])
            disp(['monthly means, ref period: ', num2str(sal_ann_ref,'%6.2f')])
            
            disp([' '])
            disp(['overall mean, ref period: ', num2str(sal_LTM_mean,'%6.2f')])
            
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