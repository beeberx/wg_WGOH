%% script to set the timeseries selection for the summary figures

BBAY_TS = {'Greenland_FB4_0-50_Annual.csv'};

NEAS_TS = {'USA_nwGeorges_Bank_Annual.csv';
'GulfStLawrence_Timeseries.csv';
'Newf_Station27_Annual.csv'};

SPNA_TS = {'LabradorSea_1000-1800_Annual.csv';%SPNA_021_CentralLabradorSea_Intermediate_Annual.csv
'Central_Irminger_SPMW_Annual.csv';%SPNA_023_CentralIrmingerSea_Intermediate_Annual.csv
'Iceland_Basin_EEL_Upper_Annual.csv'};%'SPNA_024_NorthernIcelandBasin_Upper_Annual.csv'

NSBS_TS = {'FaroeShetland_NAW_Annual.csv';
'Iceland_Lon2_6_Annual.csv';
'Norway_OWSM_2000_Annual.csv'};

NWES_TS = {'North_Sea_HelgolandRoads_Annual.csv';
'Skagerrak_0-10_Surface-water_Annual.csv';
'North_Sea_HelgolandRoads_Annual.csv'};

BALT_TS = {'Baltic_BY15_Annual.csv'};

BICC_TS = {'Biscay_Santander7_300-600_Timeseries.csv';
'Cadiz_STOCA-SP6_100_300_Timeseries.csv';
'CanaryBasinCTZ_200-800_Timeseries.csv'};

IROC_TS = cat(1,BBAY_TS,NEAS_TS,SPNA_TS,NSBS_TS,NWES_TS,BALT_TS,BICC_TS);
