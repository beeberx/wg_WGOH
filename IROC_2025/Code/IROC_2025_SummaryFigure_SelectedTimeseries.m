%% script to set the timeseries selection for the summary figures

BBAY_TS = {'BBAY_006_Greenland_FB4-GCRC_0-50_Annual.csv'};

NEAS_TS = {'NEAS_015_USA_nwGeorges_Bank_Annual.csv';
'NEAS_001_GulfStLawrence_Timeseries.csv';
'NEAS_005_Newf_Station27_Annual.csv'};

SPNA_TS = {'SPNA_016_LabradorSea_1000-1800_Annual.csv';%SPNA_021_CentralLabradorSea_Intermediate_Annual.csv
'SPNA_002_Central_Irminger_SPMW_Annual.csv';%SPNA_023_CentralIrmingerSea_Intermediate_Annual.csv
'SPNA_008_Iceland_Basin_EEL_Upper_Annual.csv'};%'SPNA_024_NorthernIcelandBasin_Upper_Annual.csv'

NSBS_TS = {'NSBS_009_FaroeShetland_NAW_Annual.csv';
'NSBS_030_Iceland_Lon2_6_Annual.csv';
'NSBS_015_Norway_OWSM_2000_Annual.csv'};

NWES_TS = {'NWES_006_North_Sea_HelgolandRoads_Annual.csv';
'NWES_014_Skagerrak_0-10_Surface-water_Annual.csv';
'NWES_012_NSea_Utsira_B_Annual.csv'};

BALT_TS = {'BALT_001_Baltic_BY15_Annual.csv'};

BICC_TS = {'BICC_004_Biscay_Santander7_300-600_Timeseries.csv';
'BICC_007_Cadiz_STOCA-SP6_100_300_Timeseries.csv';
'BICC_012_CanaryBasinOceanicWaters_0200-0800_Timeseries.csv'};

IROC_TS = cat(1,BBAY_TS,NEAS_TS,SPNA_TS,BICC_TS,NSBS_TS,NWES_TS,BALT_TS);

clear BBAY_TS NEAS_TS SPNA_TS NSBS_TS NWES_TS BALT_TS BICC_TS

IROC_TS_Labels = {'Fyllas Bank';
    'NW Georges Bank';
    'Gulf of St Lawrence';
    'Newfoundland Shelf';
    'Central Labrador Sea';
    'Sub-polar Mode Water, Central Irminger Sea';
    'Upper Waters, Iceland Basin';
    'Outer Slope, Bay of Biscay';
    'Gulf of Cadiz' ;
    'Canary Basin Coastal Transition Zone';
    'North Atlantic Water, Faroe-Shetland Channel';
    'East Icelandic Current';
    'Ocean Weather Ship Mike, Norwegian Sea';
    'Helgoland Roads, North Sea';
    'Surface Water, Skagerrak';
    'Atlantic Water, North Sea';
    'Baltic Proper'};

IROC_TS_Codes = {'BBAY 006';
    'NEAS 015';
    'NEAS 001';
    'NEAS 005';
    '(*) SPNA 016';
    'SPNA 002';
    'SPNA 008';
    'BICC 004';
    'BICC 007';
    '(*) BICC 012';
    'NSBS 009';
    'NSBS 030';
    '(*) NSBS 015';
    'NWES 006';
    'NWES 014';
    'NWES 012';
    'BALT 001'};

% IROC_TS_Codes = {{'BBAY 006';'Upper'};
%     {'NEAS 015';'Upper'};
%     {'NEAS 001';'Upper'};
%     {'NEAS 005';'Upper'};
%     {'SPNA 016';'Deep'};
%     {'SPNA 002';'Upper'};
%     {'SPNA 008';'Upper'};
%     {'BICC 004';'Upper'};
%     {'BICC 007';'Upper'};
%     {'BICC 012';'Interm.'};
%     {'NSBS 009';'Upper'};
%     {'NSBS 030';'Upper'};
%     {'NSBS 015';'Deep'};
%     {'NWES 006';'Upper'};
%     {'NWES 014';'Upper'};
%     {'NWES 012';'Upper'};
%     {'BALT 001';'Upper'}};