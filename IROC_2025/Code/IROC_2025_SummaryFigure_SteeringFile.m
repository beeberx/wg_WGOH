% IROC_2025_SummaryFigure_SteeringFile.m  
% Makes all the maps and scorecards for the summary figures

% supporting functions
%     IROC_2025_SummaryFigure_SelectedTimeseries.m

% Summary map to show where timeseries are measured
run IROC_2025_SummaryFigure_map.m
run IROC_2025_SummaryFigure_map_closeup.m   

% Summary map of the annual indicators - run three times (once for each
% year)
IROC_2025_SummaryFigure_map_TAnom_SelYear(2022)
IROC_2025_SummaryFigure_map_TAnom_SelYear(2023)
IROC_2025_SummaryFigure_map_TAnom_SelYear(2024)

IROC_2025_SummaryFigure_map_SAnom_SelYear(2022)
IROC_2025_SummaryFigure_map_SAnom_SelYear(2023)
IROC_2025_SummaryFigure_map_SAnom_SelYear(2024)

% Scorecard of temperature and salinity at selected sites
run IROC_2025_SummaryFigure_scorecard_temp.m 
run IROC_2025_SummaryFigure_scorecard_salt.m 