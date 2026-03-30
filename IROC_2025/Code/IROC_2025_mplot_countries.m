function IROC_2025_mplot_countries(edge_W,edge_E,edge_S,edge_N,fname)
% reads in shape file, and plots those boundaries that are within the map
% edges

M = m_shaperead(fname);

for ii=1:size(M.ncst,1)
    % plot if any part of boundary is inside
    idx = intersect(intersect(find(M.ncst{ii}(:,1)>=edge_W),find(M.ncst{ii}(:,1)<=edge_E)),...
       intersect(find(M.ncst{ii}(:,2)>=edge_S),find(M.ncst{ii}(:,2)<=edge_N)));
    if ~isempty(idx)
        m_plot(M.ncst{ii}(:,1),M.ncst{ii}(:,2),'-','color',[.1 .1 .1],'linewidth',1)
        if M.LABELRANK{ii}<=3
            %m_text(M.LABEL_X{ii},M.LABEL_Y{ii},M.SOVEREIGNT{ii},'color',[.1 .1 .1])
            m_text(M.LABEL_X{ii},M.LABEL_Y{ii},M.ADM0_A3{ii},'color',[.1 .1 .1])
        end
    end
end