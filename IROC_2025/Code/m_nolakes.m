function m_nolakes(lakeColor,lakeEdge)
% delete the water bodies patches in figures created by m_map
%        default lakeColor is white ([1 1 1]), default lakeEdge is white ([1 1 1])
% usage:
%        m_nolakes(lakeColor,lakeEdge)
%        http://scriptdemo.blogspot.com
%  xianmin@ualberta.ca 
%
%  $Log$
%  Matlab 8.3, R2014a@pequod, dkieke, added edgecolor option
%  05.06.2020, dkieke,  Matlab 8.3, R2014a@pequod: needed to optimize line 24 to work properly in m_map1.4k and higher

if nargin==0
    lakeColor = [1 1 1];
    lakeEdge  = [1 1 1];
elseif nargin ~= 1 & nargin ~= 2
    help m_nolakes
    return
end

gshhstypes={'c','l','i','h','f'};

for nt = 1:numel(gshhstypes)
    eval(['hw=findobj(gcf,''type'',''patch'',''tag'',''m_gshhs_',gshhstypes{nt},'_lake'');'])%,''facecolor'',lakeColor,''edgecolor'',lakeEdge);']);
    
    if ~isempty(hw)
        delete(hw);
    end

end

hw=findobj(gcf,'type','patch','tag','m_coast_lake');
if ~isempty(hw)
    delete(hw);
end


hw = findobj(gcf,'type','patch','tag','m_coast','facecolor',lakeColor,'edgecolor',lakeEdge);

if ~isempty(hw)
    delete(hw);
end