function colanom = fun_lookup_anom_colour(anom,colmap,colrange)
%colmap = rbc;
%colrange = [-3.5 3.5];

colanom = NaN.*anom;

colbounds = linspace(colrange(1),colrange(2),size(colmap,1)+1);

colbounds_lower = [-Inf,colbounds(1:end)];
colbounds_upper = [colbounds(1:end),Inf];

for rr=1:size(anom,1)
    for cc=1:size(anom,2)
        if isnan(anom(rr,cc));continue;end
        absanom = anom(rr,cc);
        if sign(absanom)==-1
            idx = intersect(find(absanom>colbounds_lower),find(absanom<=colbounds_upper))-1;
        else
            idx = intersect(find(absanom>=colbounds_lower),find(absanom<colbounds_upper))-1;
        end
        idx(idx>size(colmap,1))=size(colmap,1);
        idx(idx==0)=1;
        colanom(rr,cc)=idx;
        clear idx absanom
    end
end

return
