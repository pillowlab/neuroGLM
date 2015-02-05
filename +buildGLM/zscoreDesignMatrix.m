function dm = zscoreDesignMatrix(dm, colIndices)
% z-scores each column of the design matrix. Helps when ill-conditioned.
% dm = zscoreDesignMatrix(dm, colIndices);
%
% z-scoring removes the mean, and divides by the standard deviation.
% CAUTION: this results in a non-sparse matrix if not used carefully!
%
% Input
%   dm: design matrix structure (see compileSparseDesignMatrix)
%   colIndices: [n x 1] optional - indicies of columns you want to z-score
%	use getDesignMatrixColIndices to get indices from covariate labels
%
% Output
%   dm: design matrix with z-scored columns
%	it has the meta data to correctly reconstruct weights later

if nargout ~= 1
    error('Must assign output back to a design matrix!');
end

if isfield(dm, 'zscore')
    warning('This design matrix is already z-scored! Skipping...');
    return
end

if nargin == 1
    [dm.X, dm.zscore.mu, dm.zscore.sigma] = zscore(dm.X);
else
    [X, zmu, zsigma] = zscore(dm.X(:, colIndices));
    dm.X(:, colIndices) = X;

    dm.zscore.mu = zeros(size(dm.X, 2), 1); % note that mean is not really zero
    dm.zscore.mu(colIndices) = zmu;
    dm.zscore.sigma = ones(size(dm.X, 2), 1); % likewise
    dm.zscore.sigma(colIndices) = zsigma;
end
