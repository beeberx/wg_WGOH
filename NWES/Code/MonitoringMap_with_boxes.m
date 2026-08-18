%close all

LEGH = [];
LEGT = {};

figure(2);clf;
m_proj('mercator','lat',[46 65],'long',[-22 10]);
m_elev('contour',[-5000,-1000,-500,-200,-100,-50,-25],'edgecolor',[240,237,233]/255)
m_gshhs_i('patch', [240,237,233]/255,'edgecolor',[0 0 0]/255);
hold on


Boxes = readtable('../BoxDefs_NWES.csv');

for rr=1:size(Boxes,1)
p1 = m_patch([Boxes{rr,'p1_lon'} Boxes{rr,'p2_lon'} Boxes{rr,'p3_lon'} Boxes{rr,'p4_lon'} Boxes{rr,'p1_lon'}],...
    [Boxes{rr,'p1_lat'} Boxes{rr,'p2_lat'} Boxes{rr,'p3_lat'} Boxes{rr,'p4_lat'} Boxes{rr,'p1_lat'}],'r');
set(p1,'facecolor','none','edgecolor','r','linewidth',2)
m_text(Boxes{rr,'p2_lon'}+0.1,Boxes{rr,'p2_lat'}-0.05,num2str(Boxes{rr,'BoxNumber'}),'color','r')
end

m_grid('xtick',[-20:5:10],'ytick',[50:5:65],...
    'box', 'fancy','gridcolor',[.8 .8 .8],'linestyle','-','fontsize',12,'fontname','Arial')


set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(gcf, '-dpng', '-r300', 'WGOH-NWES_all_boxes.png')