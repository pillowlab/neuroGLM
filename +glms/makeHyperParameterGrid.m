function hgrid = makeHyperParameterGrid(domain, ngridpoints, gridType)
% hgrid = makeHyperParameterGrid(domain, nGridPoints, gridType)
% 
% domain - [lb1 ub1; lb2 ub2; ...] - lower and upper bounds for hyprs

nhyp = size(domain,1);
switch gridType
    case 'lhs'
        hgrid = lhsdesign(ngridpoints,nhyp);
    case 'uniform'
        tm = ones(nhyp,1);
        rngs = mat2cell(tm*linspace(0, 1, ngridpoints), tm');
        hgrid = cartesianProduct(rngs);
end

for khp = 1:nhyp
    hgrid(:,khp) = hgrid(:,khp)*diff(domain(khp,:)) + domain(khp,1);
end

function hgrid = cartesianProduct(rngs)
% hgrid = cartesianProduct(rngs)
% 
% rngs - cell array of possible values, e.g. {[1 2], [4.2 5.2 6], [10 19]}
% 
% returns n-by-N grid of all combinations, where N = numel(rngs)

    N = numel(rngs);
    v = cell(N,1);
    [v{:}] = ndgrid(rngs{:});
    hgrid = reshape(cat(N+1,v{:}),[],N);
