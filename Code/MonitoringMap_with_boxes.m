close all
[h,LEGE,LEGT] = fun_monitoringmap(-3,12,48,61,{'JONSIS','ORK-UTS','AECO','FEI-SHE','GNS_BSH'})
[~,~,RAW]=xlsread('BoxDefs_NSea_2024-08-21.xlsx');

for rr=1:size(RAW,1)-1
p1 = m_patch([RAW{rr+1,2} RAW{rr+1,4} RAW{rr+1,6} RAW{rr+1,8} RAW{rr+1,2}],...
    [RAW{rr+1,3} RAW{rr+1,5} RAW{rr+1,7} RAW{rr+1,9} RAW{rr+1,3}],'r');
set(p1,'facecolor','none','edgecolor','m','linewidth',3)
m_text(RAW{rr+1,4}+0.1,RAW{rr+1,5},num2str(RAW{rr+1,1}),'color','m')
end

saveas(gcf,'BoxMap_NSea.png')