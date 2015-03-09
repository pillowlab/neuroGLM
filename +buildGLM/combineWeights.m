function [wout] = combineWeights(dm, w)
% Combine the weights per column in the design matrix per covariate
%
% Input
%   dm: design matrix structure
%   w: weight on the basis functions
%
% Output
%   wout.(label).data = combined weights
%   wout.(label).tr = time axis

dspec = dm.dspec;
binSize = dspec.expt.binSize;
wout = struct();

if isfield(dm, 'biasCol') % undo z-score operation
    if isfield(dm, 'zscore') && numel(dm.zscore.mu) == numel(w) % remove bias from zscore
        zmu  = dm.zscore.sigma(dm.biasCol);
        zsig = dm.zscore.mu(dm.biasCol);
        dm.zscore.sigma(dm.biasCol) = [];
        dm.zscore.mu(dm.biasCol) = [];
    else
        zmu  = 0;
        zsig = 1;
    end
    wout.bias = w(dm.biasCol)*zsig + zmu; % un-z-transform the bias
    w(dm.biasCol) = [];
end

if isfield(dm, 'zscore') % undo z-score operation
    w = (w .* dm.zscore.sigma(:)) + dm.zscore.mu(:);
end

if isfield(dm, 'constCols') % put back the constant columns
    w2 = zeros(dm.dspec.edim, 1);
    w2(~dm.constCols) = w; % first term is bias
    w = w2;
end

if numel(w) ~= dm.dspec.edim
    error('Expecting w to be %d dimension but it''s [%d]', ...
	dspec.edim, numel(w));
end

startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];

for kCov = 1:numel(dspec.covar)
    covar = dspec.covar(kCov);
    basis = covar.basis;

    if isempty(basis)
	w_sub = w(startIdx(kCov) + (1:covar.edim) - 1);
	wout.(covar.label).tr = ((1:size(w_sub, 1))-1 + covar.offset) * binSize;
	wout.(covar.label).data = w_sub;
	continue;
    end

    assert(isstruct(basis), 'Basis structure is not a structure?');

    sdim = covar.edim / basis.edim;
    wout.(covar.label).data = zeros(size(basis.B, 1), sdim);
    for sIdx = 1:sdim
	w_sub = w(startIdx(kCov) + (1:basis.edim)-1 + basis.edim * (sIdx - 1));
	w2_sub = sum(bsxfun(@times, basis.B, w_sub(:)'), 2);
	wout.(covar.label).data(:, sIdx) = w2_sub;
    end
    wout.(covar.label).tr = ...
	((basis.tr(:, 1) + covar.offset) * binSize) * ones(1, sdim);
end
