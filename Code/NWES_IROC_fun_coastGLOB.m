%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NWES_IROC_fun_coastGLOB(plotspec)
%
% BPLOT_COASTGLOB
%
% Plots WORLD coastline on current figure.  If no input
% arguments, the function will plot the coastline as a black line.
%
% Coastline file from m_map toolbox - https://www-old.eoas.ubc.ca/~rich/map.html

if nargin<1
   plotspec = '-k'; 
end

a = which('m_plot');
mmap_path = a(1:regexpi(a,'m_plot[.]m')-1);

load([mmap_path,'private\m_coasts.mat'])

figure(gcf)
hold on
plot(ncst(:,1),ncst(:,2),plotspec)
end
