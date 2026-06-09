function IROC_2025_fun_coastGLOB(plotspec)
% function IROC_2025_fun_coastGLOB
%
% Plots WORLD coastline on current figure.  If no input
% arguments, the function will plot the coastline as a black line.
%
% Coastline file from m_map toolbox - https://www-old.eoas.ubc.ca/~rich/map.html
%
% if Coastline from m_map toolbox can't be found, then script does nothing
% (no error, but does display to the command line).
%
% USE:
%       IROC_2025_fun_coastGLOB(plotspec)
%
% INPUT: 
%       plotspec   optional input of plotting specification
%
% OUTPUT: 
%       none
%
% WRITTEN FOR ICES WGOH BY:
%       Bee Berx, June-2026


if nargin<1
    plotspec = '-k';
end

a = which('m_plot');
if isempty(a)
    disp('IROC_2025_fun_coastGLOB: m_coasts.mat not found. No coastline plotted.')
    return
else
    mmap_path = a(1:regexpi(a,'m_plot[.]m')-1);

    load([mmap_path,'private\m_coasts.mat'])

    figure(gcf)
    hold on
    plot(ncst(:,1),ncst(:,2),plotspec)
end
end