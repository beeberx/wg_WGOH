function cmap = IROC_2025_fun_MHW_colormap
% function IROC_2025_fun_MHW_colormap
%
% Set colormap for the heatwave category plots.  Results in a 6 shade
% colormap that matches those used in other products. 
%
% USE:
%       cmap = IROC_2025_fun_MHW_colormap
%
% INPUT: 
%       none
%
% OUTPUT: 
%       cmap       matrix of 6 rows and 3 columns containing the colormap
%
% WRITTEN FOR ICES WGOH BY:
%       Bee Berx, June-2026

cmap = [   224   243   248
   254   224   144
   253   174    97
   244   109    67
   215    48    39
   165     0    38]./255;
end