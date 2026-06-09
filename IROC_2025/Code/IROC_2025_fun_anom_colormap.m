function amap = IROC_2025_fun_anom_colormap
% function IROC_2025_fun_anom_colormap
%
% Set colormap for anomalies based on cbrewer.  Results in a 20 colours
% colormap that sets from dark blue through zero to red. 
%
% USE:
%       amap = IROC_2025_fun_anom_colormap
%
% INPUT: 
%       none
%
% OUTPUT: 
%       amap       matrix of 20 rows and 3 columns containing the colormap
%
% WRITTEN FOR ICES WGOH BY:
%       Bee Berx, June-2026

amap = [     2    56    88
     4    90   141
     5   112   176
    54   144   192
   116   169   207
   144   180   214
   166   189   219
   208   209   230
   236   231   242
   255   247   251
   255   255   204
   255   237   160
   254   217   118
   254   178    76
   253   164    63
   253   141    60
   252    78    42
   227    26    28
   189     0    38
   128     0    38]./255;
end
