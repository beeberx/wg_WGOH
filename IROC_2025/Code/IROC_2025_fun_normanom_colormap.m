function amap = IROC_2025_fun_normanom_colormap
% function IROC_2025_fun_normanom_colormap
%
% Set colormap for normalised anomalies based on cbrewer.  Results in a 14
% colours colormap that sets from dark blue through zero to red. 
%
% USE:
%       amap = IROC_2025_fun_anom_colormap
%
% INPUT: 
%       none
%
% OUTPUT: 
%       amap       matrix of 14 rows and 3 columns containing the colormap
%
% WRITTEN FOR ICES WGOH BY:
%       Bee Berx, June-2026

amap = [     8    81   156
    49   130   189
   107   174   214
   158   202   225
   198   219   239
   239   243   255
   247   247   247
   247   247   247
   254   229   217
   252   187   161
   252   146   114
   251   106    74
   222    45    38
   165    15    21]./255;

end