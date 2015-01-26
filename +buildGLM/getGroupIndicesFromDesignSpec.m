function subIdxs = getGroupIndicesFromDesignSpec(dspec)
% Cell of column indices that corresponds to each covariate in the design matrix
% subIdxs = getGroupIndicesFromDesignSpec(dspec)

subIdxs = {};
k = 0;

for kCov = 1:numel(dspec.covar)
    edim = dspec.covar(kCov).edim;
    subIdxs{kCov} = k + (1:edim);
    k = k + edim;
end
