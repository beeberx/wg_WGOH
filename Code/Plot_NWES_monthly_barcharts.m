%%% for plotting NWES monthly timeseries
%%% as climatological barchart (including climatological SD) with last three 
%%% years 2022 - 2024 overlaid as line plot and 
%%%
%%% ED, 04/04/2025

% first manually import monthly timeseries from ..\GitHub\wgoh-nwes\IROC_Timeseries
% and save as Monthly4plotting.mat file to ..\GitHub\wgoh-nwes\Code

load('Monthly4plotting.mat')

CM(1,:) = [108 184 255]/255; % Temperature bars -1 SD
    CM(2,:) = [129 250 190]/255; % Salinity bars -1 SD
    CM(3,:) = [117 117 117]/255; % Grey SD lines
    CM(4,:) = [0.2,0.8,1]; % 2022
    CM(5,:) = [0.2,0.8,0.6]; % 2023
    CM(6,:) = [1,0.6,0.6]; % 2024
    CM(7,:) = [0,0,1].*0.9; % 2022 marker color
    CM(8,:) = [0,1,0].*0.8; % 2023 marker color
    CM(9,:) = [1,0,0].*0.9; % 2024 marker color
    CM(10,:) = [204 153 255]/255; % Temperature bars +1 SD
    CM(11,:) = [255 188 230]/255; % Salinity bars +1 SD
    CM(12,:) = [220 252 255]/255; % Temperature bars
    CM(13,:) = [225 255 250]/255; % Salinity bars
    CM(14,:) = [250 250 250]/255; % light Grey bars
    CM(15,:) = [150 150 150]/255; % dark Grey lines
    
%define colormaps
    % Blue-Red rbc
    tmp= cbrewer('div','PiYG',3);
    rbc = cat(1,flipud(cbrewer('seq','Blues',6)),tmp(2,:),tmp(2,:),cbrewer('seq','Reds',6));
    rbc(rbc>1)=1;rbc(rbc<0)=0;
    clear tmp

    % Green-Pink pgc
    tmp= cbrewer('div','PiYG',3);
    pgc = cat(1,flipud(cbrewer('seq','Greens',6)),tmp(2,:),tmp(2,:),cbrewer('seq','RdPu',6));
    pgc(pgc>1)=1;pgc(pgc<0)=0;
    clear tmp

x = 1:12;
    
%%%%%   Temperature bar plots   %%%%% 
Fig1 = figure(1);
    set(Fig1,'units','normalized','outerposition',[0 0 1 1]); % make it full screen size
    set(gcf,'color','w'); % background colour
    set(gcf,'defaultaxeslinewidth',1) % line thickness around plot
    set(gcf,'defaultaxesfontsize',18) % axis label sizes
    propertyeditor(Fig1);
    
    
%%% Malin
subplot(3,2,1)
%     subplot('position',[0.093 0.67 0.367 0.24]); %original
    subplot('position',[0.107 0.67 0.367 0.24]); % for unified y-axis
    
bdata = [MalinT(:,4)-MalinT(:,5),MalinT(:,5),MalinT(:,5)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

p(1) = plot(x,MalinT(:,1),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
p(2) = plot(x,MalinT(:,2),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
p(3) = plot(x,MalinT(:,3),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
annotation('textbox', [0.1099, 0.869, 0.24, 0.04], 'String', "Malin Head", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original position: [0.0959, 0.869, 0.24, 0.04]
annotation('textbox', [0.1099, 0.8428, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original position: [0.0959, 0.8428, 0.126, 0.03]
ylabel('Temperature (\circC)')
set(gca,'xticklabel',[])

%%% North Sea
subplot(3,2,2) 
    subplot('position',[0.492 0.67 0.367 0.24]);
    
bdata = [NS(:,4)-NS(:,5),NS(:,5),NS(:,5)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,NS(:,1),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,NS(:,2),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,NS(:,3),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
annotation('textbox', [0.4949, 0.869, 0.24, 0.04], 'String', "North Sea SST", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.4949, 0.8428, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);            

%%% M3 buoy
subplot(3,2,3) 
    subplot('position',[0.107 0.39 0.367 0.24]); %original: [0.093,...
    
bdata = [M3T(:,4)-M3T(:,5),M3T(:,5),M3T(:,5)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,M3T(:,1),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,M3T(:,2),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,M3T(:,3),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024    
    

set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
ylabel('Temperature (\circC)')
set(gca,'xticklabel',[])
annotation('textbox', [0.1099, 0.5876, 0.24, 0.04], 'String', "M3 Buoy", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original: [0.0959,...
annotation('textbox', [0.1099, 0.5618, 0.126, 0.03], 'String', "Climatology: 2003 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original: [0.0959,...           
            
%%% Skagerrak surface
subplot(3,2,4) 
    subplot('position',[0.492 0.39 0.367 0.24]);

bdata = [SK(:,7)-SK(:,8),SK(:,8),SK(:,8)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,SK(:,1),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,SK(:,3),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,SK(:,5),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024    
    

set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
annotation('textbox', [0.4949, 0.5876, 0.24, 0.04], 'String', "Central Skagerrak", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.4949, 0.5618, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);            

%%% Western channel
subplot(3,2,5) 
    subplot('position',[0.107 0.11 0.367 0.24]); %original: [0.093,...
    
bdata = [WCclim(:,1)-WCclim(:,2),WCclim(:,2),WCclim(:,2)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end


plot(WC22mts(:,1)+0.5,WC22mts(:,2),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(WC23mts(:,1)+0.5,WC23mts(:,2),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(WC24mts(:,1)+0.5,WC24mts(:,2),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
    

set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
xlabel('Month');
ylabel('Temperature (\circC)')
annotation('textbox', [0.1099, 0.307, 0.24, 0.04], 'String', "Western Channel", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original: [0.0959,...
annotation('textbox', [0.1099, 0.2818, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]); % original: [0.0959,...

%%% Helgoland roads
subplot(3,2,6) 
    subplot('position',[0.492 0.11 0.367 0.24]);
    
bdata = [HR(:,7)-HR(:,8),HR(:,8),HR(:,8)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = rbc(6,:);
B(3).CData = rbc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,HR(:,1),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,HR(:,3),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,HR(:,5),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024    
    
set(gca,'Ylim',[3 20]);
yticks(0:4:20);
set(gca,'Xlim',[0 12.7]);
set(gca,'yticklabel',[])
xlabel('Month');
annotation('textbox', [0.4949, 0.307, 0.24, 0.04], 'String', "Helgoland Roads", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.4949, 0.2818, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
%     lgd = legend([B(2) B(3) B(1) p(1) p(2) p(3)],"Monthly" + newline  +  "climatology","+1 standard" + newline  +  "deviation","-1 standard" + newline  +  "deviation",'2022','2023','2024');
    lgd = legend([p(1) p(2) p(3)],'2022','2023','2024');
    lgd.FontSize = 16;
    lgd.Position = [0.8694,0.1115,0.0692,0.1136];
    lgd.Box = 'off';

%%
%%%%%   Salinity bar plots   %%%%% 
Fig2 = figure(2);
    set(Fig2,'units','normalized','outerposition',[0 0 1 1]); % make it full screen size
    set(gcf,'color','w'); % background colour
    set(gcf,'defaultaxeslinewidth',1) % line thickness around plot
    set(gcf,'defaultaxesfontsize',18) % axis label sizes
    propertyeditor(Fig2);
    
    
%%% Helgoland roads
subplot(3,2,1)
    subplot('position',[0.093 0.67 0.367 0.24]);

bdata = [HR(:,9)-HR(:,10),HR(:,10),HR(:,10)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = pgc(6,:);
B(3).CData = pgc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,HR(:,2),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,HR(:,4),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,HR(:,6),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
set(gca,'Ylim',[30.4 34.5]);
set(gca,'Xlim',[0 12.7]);
annotation('textbox', [0.0959, 0.869, 0.24, 0.04], 'String', "Helgoland Roads", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.2261, 0.872, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
ylabel('Salinity')
set(gca,'xticklabel',[])

%%% Central Skagerrak
subplot(3,2,2) 
    subplot('position',[0.492 0.67 0.367 0.24]);

bdata = [SK(:,9)-SK(:,10),SK(:,10),SK(:,10)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = pgc(6,:);
B(3).CData = pgc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

plot(x,SK(:,2),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
plot(x,SK(:,4),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
plot(x,SK(:,6),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
set(gca,'Ylim',[26.8 36.3]);
set(gca,'Xlim',[0 12.7]);    

xlabel('Month');
annotation('textbox', [0.4949, 0.869, 0.24, 0.04], 'String', "Central Skagerrak", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.629, 0.872, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);


%%% Western channel
subplot(3,2,3) 
    subplot('position',[0.093 0.39 0.367 0.24]);
    
bdata = [WCclim(:,3)-WCclim(:,4),WCclim(:,4),WCclim(:,4)];
B = bar(x,bdata,1,'stacked', 'FaceColor','flat'); %,'FaceColor',CM(1,:)); %climatology bar
B(1).CData = [1 1 1];
B(2).CData = pgc(6,:);
B(3).CData = pgc(9,:);

for i = 1:length(B)
    B(i).EdgeColor = 'none';  % Light gray edges
    B(i).LineWidth = 0.2;
end

    % Compute cumulative stack heights
y_stack = cumsum(bdata, 2);      % size = 12x3

hold on
bar_width = 0.8;

for j = 1:12
    x1 = x(j) - bar_width/1.6;
    x2 = x(j) + bar_width/1.6;
    y_top = y_stack(j,2);   % top of stack 2 for bar j

    plot([x1 x2], [y_top y_top], 'Color', CM(15,:), 'LineWidth', 1.5);  % bold black top line
end

p(1) = plot(WC22mts(:,1)+0.5,WC22mts(:,3),'o-','markerfacecolor',CM(7,:),'markeredgecolor',CM(7,:),'markersize',10,'Color', CM(4,:), 'LineWidth', 2.5); % 2022
p(2) = plot(WC23mts(:,1)+0.5,WC23mts(:,3),'o-','markerfacecolor',CM(8,:),'markeredgecolor',CM(8,:),'markersize',7,'Color', CM(5,:), 'LineWidth', 2.5); % 2023
p(3) = plot(WC24mts(:,1)+0.5,WC24mts(:,3),'o-','markerfacecolor',CM(9,:),'markeredgecolor',CM(9,:),'markersize',4,'Color', CM(6,:), 'LineWidth', 2.5); % 2024
set(gca,'Ylim',[34.95 35.52]);
set(gca,'Xlim',[0 12.7]);


annotation('textbox', [0.0959, 0.5876, 0.24, 0.04], 'String', "Western Channel", 'FontSize', 20, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);
annotation('textbox', [0.2261, 0.5886, 0.126, 0.03], 'String', "Climatology: 1991 - 2020", 'FontSize', 14, 'LineStyle',...
                'none', 'FontWeight', 'Bold', 'color', [0.64,0.08,0.18]);   

ylabel('Salinity')
xlabel('Month');
    lgd = legend([p(1) p(2) p(3)],'2022','2023','2024');
    lgd.FontSize = 16;
    lgd.Position = [0.8694,0.6703,0.0692,0.1136];
    lgd.Box = 'off';

    
