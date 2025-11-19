function tx = fun_plot_collegend_anom(figh,colmap)

yytxt = 1.4;
figure(figh),hold on
tx = axes;hold on
set(tx,'position',[0.115 0.9 0.8 0.05])
%%set(tx,'position',[0.05 0.5 0.9 0.05])

clow = [-3:0.5:0,0:0.5:3];
cupp = [-Inf,-3:0.5:-0.5,0.5:0.5:3,Inf];

for pp=1:length(clow)
    if pp==1
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 1 1 0],colmap(pp,:),'edgecolor','none')
        text(pp,yytxt,['y \leq ' sprintf('% -3.1f',clow(pp))], ...
           'horizontalalignment','center','VerticalAlignment','bottom','interpreter','tex','FontSize',10);
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 4 4 0],colmap(pp,:),'facecolor','none','edgecolor','k')
    elseif pp==length(clow)
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 1 1 0],colmap(pp,:),'edgecolor','none')
        text(pp,yytxt,[sprintf('% -3.1f',clow(pp)) ' \leq y' ], ...
           'horizontalalignment','center','VerticalAlignment','bottom','interpreter','tex','FontSize',10);
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 4 4 0],colmap(pp,:),'facecolor','none','edgecolor','k')
    else
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 1 1 0],colmap(pp,:),'edgecolor','none')
        if sign(cupp(pp))==-1
            text(pp,yytxt,{[sprintf('% -3.1f',cupp(pp)),' < ','y',' \leq ', sprintf('% -3.1f',clow(pp))]}, ...
           'horizontalalignment','center','VerticalAlignment','bottom','interpreter','tex','FontSize',10);
        else
            text(pp,yytxt,{[sprintf('% -3.1f',clow(pp)),' \leq ','y',' < ', sprintf('% -3.1f',cupp(pp))]}, ...
           'horizontalalignment','center','VerticalAlignment','bottom','interpreter','tex','FontSize',10);
        end
%         text(pp,yytxt,{[sprintf('% -3.1f',clow(pp)),'\leq'];'y';['<', sprintf('% -3.1f',cupp(pp))]}, ...
%            'horizontalalignment','center','VerticalAlignment','bottom','interpreter','tex','FontSize',10);
        patch(tx,pp+[-0.5 0.5 0.5 -0.5 -0.5],[0 0 4 4 0],colmap(pp,:),'facecolor','none','edgecolor','k')
    end
end
set(tx,'color','none','XColor','none','ycolor','none','xlim',[0.5 size(colmap,1)+0.5],'ylim',[0 4])
