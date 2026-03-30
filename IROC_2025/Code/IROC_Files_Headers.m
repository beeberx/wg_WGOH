clear all;close all;clc

% set path to where you store data folder - this is relative path in Bee
% file structure
IROC_datafolder = ['../../../IROC/Data/'];

% find a list of all the Annual files
flist = ls([IROC_datafolder,'*Annual*']);

AllHeaders = {};AllTypes = {};
IROC_HLines = NaN.*zeros(size(flist,1),1);
% consolidate time series (in order listed in directory)
for ff=1:size(flist,1)
    data_filename = flist(ff,:);
    NumHeadLines = 0;bline = repmat(' ',1,15);
    fid = fopen([IROC_datafolder,data_filename]);
    while isempty(regexpi(bline,'year'))
        bline = fgetl(fid);
        C = regexpi(bline,':','split');
        AllTypes = cat(1,AllTypes,C(1));
        AllHeaders = cat(1,AllHeaders,cellstr(bline));
        if length(bline)>15
            bline = bline(1:15);
        end
        NumHeadLines = NumHeadLines +1;
    end
    IROC_HLines(ff)=NumHeadLines-1;
    fid = fclose(fid);clear fid bline
end; clear ff

OutTypes = unique(AllTypes,'stable');
fid = fopen('FileHeader.txt','w');
for hh=1:size(OutTypes,1)
    fprintf(fid,'%s\n',OutTypes{hh});
end
fclose(fid)
