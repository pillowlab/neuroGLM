function inds = count2inds(cnt)
    dims = cumsum(cnt);
    dcnt = num2cell([0 dims(1:end-1)]);
    inds = cellfun(@(x,y) y+(1:x), num2cell(cnt), dcnt, 'uniformoutput', false);