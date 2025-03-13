%% Steering File Script to help understand the order in which scripts needs
% to be done

%% make nice maps
plot_Basemap_NWES.m
MonitoringMap_with_boxes.m                          
MonitoringMap_with_sections.m                       
MonitoringMap_with_sections_and_boxes.m             

%% OISST 
OISST_load_plot_NWES.m                              
SGMD_extract_OISST_temperature_in_NWES_boxes.m      
plot_OISSTtemp_colourboxes.m 

%% AMM7 reanalysis model
SGMD_extract_AMM7_salinity_in_NWES_boxes.m          
SGMD_extract_AMM7_monthlyTS_in_NWES_boxes.m         
SGMD_extract_AMM7_monthlyUV_map.m                   
plot_AMM7salinity_colourboxes.m                     
plot_AMM7tempsal_colourboxes.m                      

%% ARMOR 3D dataset
download_CMEMS_ARMOR3D.m                            

%% BSH Blended SST data product
BSH_extract_blendedSST.m                            
plot_BSHblendedSST_colourboxes.m                    

%% IROC timeseries
load_and_plot_IROC_annualTimeseries_colourboxes.m   
plot_IROC_Skagerrak_annual.m                        
plot_IROC_Skagerrak_time.m                          
plot_IROC_Temp_timeseries.m                         

%% supporting functions
fun_plot_colourboxes.m                              
fun_plot_colourboxes_with_value.m                   

%% old code - not in use
LegacyCode_NorthSeaEcosystemOverview_colourtable.m  
NSea_WS_LoadData_Boxes_Nov24.m                      
