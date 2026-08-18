function rbc = fun_IROC_rbcmap(ncol)
% function to create Red Blue colormap
% uses colour brewer palette

ncol2 = round((ncol-2)/2);
% Blue-Red rbc
tmp= cbrewer('div','PiYG',3);
rbc = cat(1,flipud(cbrewer('seq','Blues',ncol2)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',ncol2));
rbc(rbc>1)=1;rbc(rbc<0)=0;
clear tmp
