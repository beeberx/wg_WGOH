
% PLOT_IROC_TEMP_TIMESERIES
%
%                This code will plot temperature time series for certain IROC time series, Greater North Sea in one
%                plot, western shelf stations in another, AW inflow transport time series (certainly no
%                temperature) in a third. In order to store output as png-file, the export_fig-toolbox is required, 
%                which can be found here: https://github.com/altmany/export_fig
%
%                Time series are plotted with long-term averages +/- STD lines added. These values are taken
%                directly ftom the input files which are the ICES-IROC-annual time series. Depending on the actual
%                time series, long-term averages refer to different averaging periods, see code. Also, some linear 
%                trend lines are added.
%
%                Users will need to pick the respective and predefined indices in order to plot the correct
%                time series. Regardless of the length of each time series, all plots cover the years 1995 to most
%                recent year of interest.
%
%                usage  : plot_IROC_Temp_timeseries
%
%                input  : define pathways, filenames and input/output directories internally
%
%                output : png plots like "IROC2025_temperature_1995-2024_GreaterNorthSea_ddmmmyyyy.png",
%                                        "IROC2025_temperature_1995-2024_WesternShelf_ddmmmyyyy.png",  
%                                        "IROC2025_AWinflow_1995-2024_GreaterNorthSea_ddmmmyyyy.png"
%
%                uses   : IROC time series as provided by ICES-WGOH and/or WGOH members, export_fig-toolbox,
%                         moveto.m (added as subfunction at the end of the code)
%
%                Version 2.0, 17.02.2025, dkieke, Matlab 9.5, R2018b@VC34648
%                Version 1.0, 04.04.2024, dkieke, Matlab 9.5, R2018b@VC34648
%

clear
close all

figure
set(gcf,'color','w')

% define markersize ...

ms = 2;

% define necessary indices for the selection of time series of interest ...

idx = [1:2,4:5]; % near-surface temperature on the western shelf
% idx = [7:10,12,13]; % (near-surface) temperature Greater North Sea
% idx = [11]; % AW transport Greater North Sea

% define most recent year of interest ...

mry = 2024;

% define output directory ...

fname_prefx = ['IROC2025']; % need for directory and filenames ...
datadir_OUT = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\figures\'];

%% 01. define and load input data ...

datadir_IN = ['h:\Documents\work\Wissenschaftliche_Organisationen\ICES_WGOH\',fname_prefx,'\data_download\'];
fname_IN   = {    
'Ireland_Malin_Annual.csv'                             % LTAP (long-term averaging period): 1991-2020
'IrishSea_AFBI_38a_Temperature_Surface_Annual.csv'     % LTAP: 1996-2020
'IrishSea_AFBI_38a_Temperature_Seabed_Annual.csv'      % LTAP: 1996-2020
'Ireland_M3_Annual.csv'                                % LTAP: 2003-2020
'Plymouth_WCO_E1_Annual.csv'                           % LTAP: 1991-2020
'Ifremer_Astan_Annual.csv'                             % LTAP: 1998-2010, only until 2016, older reference period
% 'NSea_FairIsle_Annual.csv'  % old, on IROC page
'NSea_FairIsle_Annual-TMP-2024-04-04.csv'              % LTAP: 1991-2020, does not follow official ICES-IROC format
'NSea_CooledAtlantic_Annual-TMP-2024-04-04.csv'        % LTAP: 1991-2020, does not follow official ICES-IROC format
'NSea_Utsira_A_Annual.csv'                             % LTAP: 1991-2020
'NSea_Utsira_B_Annual.csv'                             % LTAP: 1991-2020
'NSea_Inflow_Annual.csv'                               % LTAP: 1991-2020
'North_Sea_SST_Annual.csv'                             % LTAP: 1991-2020
'North_Sea_HelgolandRoads_Annual-TMP-2024-04-04.csv'   % LTAP: 1991-2020
'Skagerrak_0-10_Surface-water_Timeseries.csv'          % LTAP: not given 
'Skagerrak_100-200_Deep-water_Timeseries.csv'          % LTAP: not given
'Skagerrak_600_Bottom-water_Timeseries.csv'            % LTAP: not given
};

% define colormap of interest ...

%  cmap = (brewermap(15,'Spectral'));
%  cmap = prism(15);
%  cmap = turb(15);
%  r = randperm(15);
%  cmap = cmap(r,:);

 cmap = [
    0.9714    0.3563    0.0118
    0.7059         0    0.4118
         0    0.6078    0.6947
    1.0000    0.8683         0
    0.9877    0.5529         0
         0    0.4650    0.7703
         0    0.5742    0.8291
    0.0784    0.2521    0.5798
    0.9412         0    0.0824
    0.9966    0.7289         0
    0.3361         0    0.4118
    0.9384    0.9132         0
    0.6762    0.8375    0.0185
    0.0275    0.6863    0.1294
    0.0039    0.6190    0.4218];

% loop over time series of interest identified via pre-selected indices stored in 'idx' ...

for ii = idx 
    
    if exist([datadir_IN,char(fname_IN(ii))],'file')
        
        disp([' '])
        disp(['--> load input data: ',[datadir_IN,char(fname_IN(ii))]])
        
        X = readtable([datadir_IN,char(fname_IN(ii))]);
        
        if ii == 1 % 'Ireland_Malin_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.Var2(cellfun(@isempty,data.Var2))={'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))={'NaN'};
            data.Var4(cellfun(@isempty,data.Var4))={'NaN'};
            
            year = str2num(char((data{:,1}))); % year
            temp = str2num(char((data{:,2}))); % temperature
            
            temp_anom = str2num(char((data{:,3})));       % temperature anomaly
            temp_anom_norm = str2num(char((data{:,4})));  % normalised temperature anomaly
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{8,2})),str2num(char(X{8,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{8,2}))+str2num(char(X{9,2})),str2num(char(X{8,2}))+str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{8,2}))-str2num(char(X{9,2})),str2num(char(X{8,2}))-str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 20+ years ...
            
            ind = find(year>= 2004 & year <= mry);
            
            jnd = find(~isnan(temp(ind)));
            p = polyfit(year(ind(jnd)),temp(ind(jnd)),1);
            
            temp_tr = polyval(p,year(ind(jnd)));
                        
            plot(year(ind(jnd)),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 2 % 'IrishSea_AFBI_38a_Temperature_Surface_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
           % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);            
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 2004 & year <= mry);
            
            jnd = find(~isnan(temp(ind)));
            p = polyfit(year(ind(jnd)),temp(ind(jnd)),1);
            
            temp_tr = polyval(p,year(ind(jnd)));
                        
            plot(year(ind(jnd)),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 3 % 'IrishSea_AFBI_38a_Temperature_Seabed_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);     
                 
            % get linear trend over past 20+ years ...
            
            ind = find(year >= 2004 & year <= mry);
            jnd = find(~isnan(temp(ind)));
            p = polyfit(year(ind(jnd)),temp(ind(jnd)),1);
            
            temp_tr = polyval(p,year(ind(jnd)));
                        
            plot(year(ind(jnd)),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 4 % 'Ireland_M3_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.Var2(cellfun(@isempty,data.Var2))={'NaN'};
            data.Var3(cellfun(@isempty,data.Var3))={'NaN'};
            data.Var4(cellfun(@isempty,data.Var4))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{8,2})),str2num(char(X{8,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{8,2}))+str2num(char(X{9,2})),str2num(char(X{8,2}))+str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{8,2}))-str2num(char(X{9,2})),str2num(char(X{8,2}))-str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);            
            
            % get linear trend over past 25 years ...
            
            ind = find(year >= 2004 & year <= mry);
            jnd = find(~isnan(temp(ind)));
            p = polyfit(year(ind(jnd)),temp(ind(jnd)),1);
            
            temp_tr = polyval(p,year(ind(jnd)));
                        
            plot(year(ind(jnd)),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 5 % 'Plymouth_WCO_E1_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{8,2})),str2num(char(X{8,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{8,2}))+str2num(char(X{9,2})),str2num(char(X{8,2}))+str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{8,2}))-str2num(char(X{9,2})),str2num(char(X{8,2}))-str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);            
            
            % get linear trend over past 20+ years ...
            
            ind = find(year >= 2004 & year <= mry);
            jnd = find(~isnan(temp(ind)));
            p = polyfit(year(ind(jnd)),temp(ind(jnd)),1);
            
            temp_tr = polyval(p,year(ind(jnd)));
                        
            plot(year(ind(jnd)),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 6 % 'Ifremer_Astan_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{8,2})),str2num(char(X{8,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{8,2}))+str2num(char(X{9,2})),str2num(char(X{8,2}))+str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{8,2}))-str2num(char(X{9,2})),str2num(char(X{8,2}))-str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...            
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 20 years ...
            
            ind = find(year >= 2004 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 7 % 'NSea_FairIsle_Annual-TMP-2024-04-04.csv'  updated on 04.04.2024, B. Berx
            
            data = X(23:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            
            plot([1995,mry],[10.148,10.148],'-.','color',cmap(ii,:))
            plot([1995,mry],[10.148+0.57,10.148+0.57],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[10.148-0.57,10.148-0.57],':','color',cmap(ii,:),'linewidth',0.25)                   
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))

        elseif ii == 8 % 'NSea_CooledAtlantic_Annual-TMP-2024-04-04'  updated on 04.04.2024, B. Berx
            
            data = X(23:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            plot([1995,mry],[8.44,8.44],'-.','color',cmap(ii,:))
            plot([1995,mry],[8.44+0.48,8.44+0.48],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[8.44-0.48,8.44-0.48],':','color',cmap(ii,:),'linewidth',0.25)
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 9 % 'NSea_Utsira_A_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...            
                        
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 10 % 'NSea_Utsira_B_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...            
                        
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 11 % 'NSea_Inflow_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'}; % inflow
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'}; % outflow
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'}; % netflow
            
            year    = str2num(char((data{:,1})));
            inflow  = str2num(char((data{:,2})));
            outflow = str2num(char((data{:,3})));
            netflow = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,inflow,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
%             plot(year,outflow,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii+1,:),'markersize',ms);
%             plot(year,netflow,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii+2,:),'markersize',ms);
            
            % highlight most recent year ...
                                
            plot(year(end),inflow(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
%             plot(year(end),outflow(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii+1,:),'markersize',ms+2);
%             plot(year(end),netflow(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii+2,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),inflow(ind),1);
            
            inflow_tr = polyval(p,year(ind));
                        
            plot(year(ind),inflow_tr,'--','color',cmap(ii,:))
            
        elseif ii == 12 % 'North_Sea_SST_Annual.csv'
            
            data = X(22:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
                        
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{6,2})),str2num(char(X{6,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{6,2}))+str2num(char(X{7,2})),str2num(char(X{6,2}))+str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{6,2}))-str2num(char(X{7,2})),str2num(char(X{6,2}))-str2num(char(X{7,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...       
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        elseif ii == 13 % 'North_Sea_HelgolandRoads_Annual.csv'
            
            data = X(17:end,:);
            
            % replace empty entries with NaN ...
            
            data.(2)(cellfun(@isempty,data.(2)))={'NaN'};
            data.(3)(cellfun(@isempty,data.(3)))={'NaN'};
            data.(4)(cellfun(@isempty,data.(4)))={'NaN'};
            
            year = str2num(char((data{:,1})));
            temp = str2num(char((data{:,2})));
            temp_anom = str2num(char((data{:,3})));
            temp_anom_norm = str2num(char((data{:,4})));
            
            hold on
            
            % plot mean value and STD ...
            
            plot([1995,mry],[str2num(char(X{8,2})),str2num(char(X{8,2}))],'-.','color',cmap(ii,:))
            plot([1995,mry],[str2num(char(X{8,2}))+str2num(char(X{9,2})),str2num(char(X{8,2}))+str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            plot([1995,mry],[str2num(char(X{8,2}))-str2num(char(X{9,2})),str2num(char(X{8,2}))-str2num(char(X{9,2}))],':','color',cmap(ii,:),'linewidth',0.25)
            
            % plot time series ...
            
            hp(ii) = plot(year,temp,'-o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms);
            
            % highlight most recent year ...       
            
            plot(year(end),temp(end),'o','color',cmap(ii,:),'markerfacecolor',cmap(ii,:),'markeredgecolor',cmap(ii,:),'markersize',ms+2);
            
            % get linear trend over past 25+ years ...
            
            ind = find(year >= 1999 & year <= mry);
            
            p = polyfit(year(ind),temp(ind),1);
            
            temp_tr = polyval(p,year(ind));
                        
            plot(year(ind),temp_tr,'--','color',cmap(ii,:))
            
        end
    end
end

if length(idx) == 4 & idx == [1:2,4:5]  % western shelf 
    
    axis([1995,2025,9,15])
    set(gca,'fontweight','bold','box','on')
    xlabel('Year')
    ylabel('Temperature [°C]')
    
    hp(3) = [];
%     [hl1,hl2] = legend(hp,'Malin Head','Irish Sea','M3 off Ireland','Western Channel','Point 33 off Brittany','location','southeast','box','off');
    [hl1,hl2] = legend(hp,'Malin Head','Irish Sea','M3 off Ireland','Western Channel','location','southeastoutside','box','off');
    
    for jj = 1995:2025
        plot([jj,jj],[9,9.1],'-k')
        plot([jj,jj],[14.9,15],'-k')
    end
    
    for jj = 1995:5:2025
        plot([jj,jj],[9,9.2],'-k')
        plot([jj,jj],[14.8,15],'-k')
    end
    
    for kk = 9:0.25:15
        plot([1995,1995.2],[kk,kk],'-k')
        plot([mry+0.8,2025],[kk,kk],'-k')
    end
    
    for ll = 9:0.5:15
        plot([1995,1995.5],[ll,ll],'-k')
        plot([mry+0.5,2025],[ll,ll],'-k')
    end
    
    moveto('s',0.1)
    
    fname_OUT = [fname_prefx,'_temperature_1995-',num2str(mry),'_WesternShelf_',datestr(now,'ddmmmyyyy')];
    
    % export figure to png-file ...
    
    disp([' '])
    disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
    
    export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
    
    
elseif length(idx) == 6 &  idx == [7:10,12,13] % Greater North Sea
    
    axis([1995,2025,5,13])
    set(gca,'fontweight','bold','box','on','layer','top')
    xlabel('Year')
    ylabel('Temperature [°C]')
    
    hp([1:6,11]) = [];
    [hl1,hl2] = legend(hp,'Fair Isle Current (mean 0-100 m)','Cooled Atlantic Water (50-100 m)','Utsira A (near-bed T-min)','Utsira B (high saline AW core)','North Sea area-averaged SST','Helgoland Roads (surface)','location','southeastoutside','box','off');
    
    for jj = 1995:2025
        plot([jj,jj],[5,5.1],'-k')
        plot([jj,jj],[12.9,13],'-k')
    end
    
    for jj = 1995:5:2025
        plot([jj,jj],[5,5.2],'-k')
        plot([jj,jj],[12.8,13],'-k')
    end
    
    for kk = 5:0.25:13
        plot([1995,1995.2],[kk,kk],'-k')
        plot([mry+0.8,2025],[kk,kk],'-k')
    end
    
    for ll = 5:0.5:13
        plot([1995,1995.4],[ll,ll],'-k')
        plot([mry+0.6,2025],[ll,ll],'-k')
    end
    
    moveto('s',0.1)
    
    fname_OUT = [fname_prefx,'_temperature_1995-',num2str(mry),'_GreaterNorthSea_',datestr(now,'ddmmmyyyy')];
    
    % export figure to png-file ...
    
    disp([' '])
    disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
    
    export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
    
elseif idx == [11] % Greater North Sea AW transport
    
    axis([1995,2025,-2,0])
    set(gca,'fontweight','bold','box','on','layer','top')
    xlabel('Year')
    ylabel('Volume transport [Sv]')
    
    hp([1:10]) = [];
    [hl1,hl2] = legend(hp,'Modeled AW inflow, 59°N','location','southeast','box','off');
    
    for jj = 1995:2025
        plot([jj,jj],[-2,-1.98],'-k')
        plot([jj,jj],[-0.02,0],'-k')
    end
    
    for jj = 1995:5:2025
        plot([jj,jj],[-2,-1.95],'-k')
        plot([jj,jj],[-0.05,0],'-k')
    end
    
    for kk = -2:0.25:0
        plot([1995,1995.2],[kk,kk],'-k')
        plot([mry+0.8,2025],[kk,kk],'-k')
    end
    
    for ll = -2:0.5:0
        plot([1995,1995.5],[ll,ll],'-k')
        plot([mry+0.5,2025],[ll,ll],'-k')
    end
    
    moveto('s',0.4)
    
    fname_OUT = [fname_prefx,'_AWinflow_1995-',num2str(mry),'_GreaterNorthSea_',datestr(now,'ddmmmyyyy')];
    
    % export figure to png-file ...
    
    disp([' '])
    disp(['--> save output in file ',[datadir_OUT,fname_OUT],'.png ...'])
    
    export_fig([datadir_OUT,fname_OUT],'-r600','-p0.02');
    
end

%%
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