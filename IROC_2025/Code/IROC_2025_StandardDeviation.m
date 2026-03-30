clear all;close all;clc;

%set colour schemes
% red blue colourmap - requires cbrewer
tmp = cbrewer('div','PiYG',3);
rbc = cat(1,flipud(cbrewer('seq','Blues',7)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',7));
rbc(rbc > 1) = 1;
rbc(rbc < 0) = 0;
clear tmp
%light grey for bar outlines and x-axis at 0
lgrey = [.7 .7 .7];

xvals= [-3.25, -2.75, -2.25, -1.75, -1.25, -0.75, -0.25,  0.25,  0.75, 1.25, 1.75, 2.25, 2.75, 3.25];
yvals= [ 0.11,  0.49,  1.65,  4.41,  9.18, 14.99, 19.14, 19.14, 14.99, 9.18, 4.41, 1.65, 0.49, 0.11];
ytickvals= [ 0.11,  0.49,  1.65,  4.41,  9.18, 14.99, 19.14];
yticklabels = cell(size(ytickvals));
for ii=1:length(ytickvals)
    yticklabels{ii}=[sprintf('%-5.2f',ytickvals(ii)),' %'];
end


figure(1);hold on
for ii=1:length(xvals)
    p1 = patch([xvals(ii)-0.25,xvals(ii)+0.25,xvals(ii)+0.25,xvals(ii)-0.25,xvals(ii)-0.25],...
        [0,0,yvals(ii),yvals(ii),0],rbc(ii+1,:));
    set(p1,'edgecolor',lgrey);
end
set(gca,'XTick',[-4:0.5:4],'YTick',ytickvals,'YTickLabel',[yticklabels(1),{''},yticklabels(3:end)],...
    'box','on','ylim',[0 35],'FontSize',11,'TickDir','both')
text(-3.9,yvals(2),yticklabels{2},'VerticalAlignment','baseline','HorizontalAlignment','left','FontSize',11)
xlabel('Units of Standard Deviation (SD)','FontSize',14)
ylabel('Frequency of Values (%)','FontSize',14)

plot([-1, 1],[20, 20],'k-','linewidth',2)
plot([-1,-1],[ 0, 20],'-','color',lgrey)
plot([ 1, 1],[ 0, 20],'-','color',lgrey)
plot( -1 , 20,'<','MarkerFaceColor','k','MarkerEdgeColor','k')
plot(  1 , 20,'>','MarkerFaceColor','k','MarkerEdgeColor','k')
text( 0, 22,'  68% within \pm 1 SD','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14)

plot([-2, 2],[25, 25],'k-','linewidth',2)
plot([-2,-2],[ 0, 25],'-','color',lgrey)
plot([ 2, 2],[ 0, 25],'-','color',lgrey)
plot( -2 , 25,'<','MarkerFaceColor','k','MarkerEdgeColor','k')
plot(  2 , 25,'>','MarkerFaceColor','k','MarkerEdgeColor','k')
text( 0, 27,'  95% within \pm 2 SD','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14)


plot([-3, 3],[30, 30],'k-','linewidth',2)
plot([-3,-3],[ 0, 30],'-','color',lgrey)
plot([ 3, 3],[ 0, 30],'-','color',lgrey)
plot( -3 , 30,'<','MarkerFaceColor','k','MarkerEdgeColor','k')
plot(  3 , 30,'>','MarkerFaceColor','k','MarkerEdgeColor','k')
text( 0, 32,'99.7% within \pm 2 SD','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',14)

set(gcf,'paperorientation','landscape','papertype','a4','paperpositionmode','auto',...
    'paperunits','centimeters','paperposition',[0.6 0.6 28.4 19.7])
print(gcf, '-dpng', '-r300', 'StDev_Figure.png')