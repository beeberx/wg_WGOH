
% DOWNLOAD_CMEMS_ARMOR3D
%
%                    Grab and download a regional subset of ARMOR3D data hosted by the Copernicus 
%                    Marine Environmental Monitoring Service (CMEMS). This code requires 
%                    the installation of Python (presently version 3.9 to 3.13) and of 
%                    the Copernicus Marine Toolbox 2.0.0, which can be accessed here:
%                    https://help.marine.copernicus.eu/en/articles/7970514-copernicus-marine-toolbox-installation
%
%                    The following prerequisites need to be met (at least on NB34648):
%                    - installation of Python using 'miniforge3' (contact: Tobias Trampler, BSH)
%                    - installation of the Copernics Marine Toolbox 2.0.0
%                    - registration at CMEMS with a respective personalized account is needed
%
%                    Once this is set up properly, the following must be done initially to 
%                    make use of the Copernicus Marine Toolbox:
%                    - open miniforge3 prompt
%                    - find installation path of Python: 
%                      (base) C:\>where python
%                    - activate Copernicus Marine Toolbox:
%                      (base) C:\>conda env list
%                      (base) C:\>conda activate copernicusmarine  
%                    - find installation path of copernicusmarine: 
%                      (copernicusmarine) C:\>where copernicusmarine 
%                    - create a configuration file with personal Copernicus Marine credentials 
%                      (is needed only once in the beginning of the process; replace bmXXXX 
%                      with your personal log-in ID):
%                      (copernicusmarine) C:\Users\bmXXXX>copernicusmarine login 
%                    --> creates credentials file stored in 
%                        C:\Users\bmXXXX\.copernicusmarine\.copernicusmarine-credentials
%
%                    The following needs to be done each time ahead of using this Matlab
%                    code and accessing CMEMS data:
%                    - open miniforge3 prompt
%                    - activate Copernicus Marine Toolbox:
%                      (base) C:\>conda activate copernicusmarine  
%                    - continue in Matlab ...
%
%                    - When in Matlab, run the following code after editing that part 
%                    related to data of interest.
%
%                    Attention: Code works best outside any BSH network environment.
%                               Otherwise, proxy problems may occur. Not yet checked 
%                               within VC environment.
%
%                    Also check:
%                    https://help.marine.copernicus.eu/en/articles/9090674-how-to-automate-a-series-of-download-via-the-copernicus-marine-toolbox-in-matlab
%
%
%                    usage  : download_CMEMS_ARMOR3D
%
%                    input  : define data of interest internally
%
%                    output : subset of weekly ARMOR3D fields for the NWES region stored
%                             as netCDF files
%
%                    uses   : CMEMS data provided here: https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_TSUV_3D_MYNRT_015_012/services
%
%                    Version 1.0, 26.02.2025, dkieke, Matlab 9.5, R2018b@NB34648 
%                    The code used here is based on Download_Toolbox_MATLAB.m obtained 
%                    from CMEMS at https://atlas.mercator-ocean.fr/s/H9xEEbZWqQkEwqW
%

%% 01. define paths ...

% define local paths to Python and Copernicus Marine tools...

path_python  = 'C:\ProgramData\Miniforge3\python.exe ';
path_toolbox = 'C:\ProgramData\Miniforge3\envs\copernicusmarine\Scripts\copernicusmarine.exe';

% create a 'data' working directory ...

output_directory = fullfile(pwd, 'data');

if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end

% define product and dataset IDs for CMEMS data of interest ...

productID = 'MULTIOBS_GLO_PHY_TSUV_3D_MYNRT_015_012';
% datasetID = 'dataset-armor-3d-nrt-weekly'; % nrt data, from 2023 onwards
datasetID = 'dataset-armor-3d-rep-weekly'; % rep data, 1993-2022

% define ocean variable(s) of interest, here, six in total ...
% attention: If the NUMBER of wanted variables is changed, edit the command line for 
%            'copernicusmarine' accordingly. Each individual variable needs to be handed
%            over by a respective '-v %' entry associated with each variable. I.e, six
%            wanted variables require six such entries. 
%            

variables = ["mlotst","to","so","ugo","vgo","zo"];%#ok<*NBRAK>

% define the geographic area of interest, here subset for the NWES region ...

longitude = [-14.8750,14.8750]; % lon_min, lon_max
latitude  = [45.1250,62.8750];  % lat_min, lat_max

% define depth range ...

depth = [0,5500]; % depth range [min,max], here: grab all

% define time range of interest:
% --> given dates refer to dates listed in the original CMEMS filenames ...

% startDate = datetime('2024-01-03 12:00:00');
% endDate   = datetime('2024-12-25 12:00:00');
% startDate = datetime('2022-01-05 12:00:00');
% endDate   = datetime('2022-12-28 12:00:00');
% startDate = datetime('2025-01-01 12:00:00');
% endDate   = datetime('2025-02-19 12:00:00');
% startDate = datetime('1993-01-06 12:00:00');
startDate = datetime('2013-04-10 12:00:00');
endDate   = datetime('2022-12-28 12:00:00');

delta_t   = days(7); % time interval in days, here weekly

%% 02. get data of interest ...

while startDate <= endDate
    
    % format output name ...
    
    output_name = sprintf([productID,'_%s_ssNWES.nc'],datestr(startDate, 'yyyymmdd'));

    % create the command to be executed on the Python level ...
    % attention: the input '-v %s' must be repeated as many times as there are variables of interest ...
    
    command = sprintf('%s subset -i %s -v %s -v %s -v %s -v %s -v %s -v %s -x %f -X %f -y %f -Y %f -t "%s 12:00:00" -T "%s 12:00:00" -z %f -Z %f -o %s -f %s', ...
        path_toolbox, datasetID, variables, ...
        longitude(1), longitude(2), latitude(1), latitude(2), ...
        datestr(startDate, 'yyyy-mm-dd'), datestr(startDate + delta_t, 'yyyy-mm-dd'), ...
        depth(1), depth(2), output_directory, output_name);

    % display command ...
    
    disp(command);
    
    % execute the command on the Python level ...
    
    system(command);
    
    % update startDate ...
    
    startDate = startDate + delta_t;
end

disp('======== Download completed! All files are in your data directory ========');
