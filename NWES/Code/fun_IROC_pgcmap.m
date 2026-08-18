function pgc = fun_IROC_pgcmap(ncol)
% function to create Pink Green colormap
% uses colour brewer palette

ncol2 = round((ncol-2)/2);
% Green-Pink pgc
tmp= cbrewer('div','PiYG',3);
pgc = cat(1,flipud(cbrewer('seq','Greens',ncol2)),tmp(2,:),tmp(2,:),cbrewer('seq','RdPu',ncol2));
pgc(pgc>1)=1;pgc(pgc<0)=0;
clear tmp
