function [LONT,LATT] = IROC_2025_mplot_wkt(POI_wkt)

LONT=[];LATT=[];
for kk=1:size(POI_wkt,1)
    tokIdx = regexp(POI_wkt{kk},'(','once');
    POI_typ = POI_wkt{kk}(1:tokIdx-1);
    switch POI_typ
        case 'POINT'
            eval(['POI_pos=[',POI_wkt{kk}(tokIdx+1:end-1),'];'])
            m_plot(POI_pos(1),POI_pos(2),'ro','markerfacecolor','r')
            LONT = cat(1,LONT,POI_pos(1));
            LATT = cat(1,LATT,POI_pos(2));
        case 'LINESTRING'
            tmp_str = POI_wkt{kk}(tokIdx+1:end-1);
            tmp_str = strrep(tmp_str,',',';');
            tmp_str = strrep(tmp_str,'(','');
            tmp_str = strrep(tmp_str,')','');
            eval(['POI_pos=[',tmp_str,'];'])
            m_plot(POI_pos(:,1),POI_pos(:,2),'r-','linewidth',2.5)
            LONT = cat(1,LONT,mean(POI_pos(:,1)));
            LATT = cat(1,LATT,mean(POI_pos(:,2)));
        case 'MULTILINESTRING'
            tmp_str = POI_wkt{kk}(tokIdx+1:end-1);
            tmp_str = strrep(tmp_str,',',';');
            tmp_str = strrep(tmp_str,'(','[');
            tmp_str = strrep(tmp_str,')',']');
            eval(['POI_pos={',tmp_str,'};'])
            for ii=1:length(POI_pos)
                m_plot(POI_pos{ii}(:,1),POI_pos{ii}(:,2),'r-','linewidth',2.5)
                if ii==1;
                    LONT = cat(1,LONT,mean(POI_pos{ii}(:,1)));
                    LATT = cat(1,LATT,mean(POI_pos{ii}(:,2)));
                end
            end
        case 'POLYGON'
            tmp_str = POI_wkt{kk}(tokIdx+1:end-1);
            tmp_str = strrep(tmp_str,',',';');
            tmp_str = strrep(tmp_str,' ',',');
            tmp_str = strrep(tmp_str,'(','');
            tmp_str = strrep(tmp_str,')','');
            eval(['POI_pos=[',tmp_str,'];'])
            m_patch(POI_pos(:,1),POI_pos(:,2),'k','facecolor','none','edgecolor','r','linewidth',2)
            clear tmp_str
%             LONT = cat(1,LONT,mean(POI_pos(:,1)));
%             LATT = cat(1,LATT,mean(POI_pos(:,2)));
            LONT = cat(1,LONT,POI_pos(1,1));
            LATT = cat(1,LATT,POI_pos(1,2));
        otherwise
            LONT = cat(1,LONT,NaN);
            LATT = cat(1,LATT,NaN);
    end
end