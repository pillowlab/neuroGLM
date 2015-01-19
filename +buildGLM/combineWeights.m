function wout = combineWeights(dm, w)
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

if numel(w) == dm.dspec.edim + 1
    DC = w(end);
elseif numel(w) ~= dm.dspec.edim
    error('Expecting w to be %d or %d dimension', dspec.edim, dspec.edim + 1);
end

startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
wout = struct();

for kCov = 1:numel(dspec.covar)
    covar = dspec.covar(kCov);
    basis = covar.basis;

    if isempty(basis)
	w_sub = w(startIdx(kCov) + (1:covar.edim) - 1);
	wout.(covar.label).tr = ((1:size(w_sub, 1)) - 1 + covar.offset) * binSize;
	wout.(covar.label).data = w_sub;
	continue;
    end

    assert(isstruct(basis), 'Basis structure is not a structure?');

    sdim = covar.edim / basis.edim;
    wout.(covar.label).data = zeros(size(basis.B, 1), sdim);
    for sIdx = 1:sdim
	w_sub = w(startIdx(kCov) + (1:basis.edim) - 1 + basis.edim * (sIdx - 1));
	w2_sub = sum(bsxfun(@times, basis.B, w_sub(:)'), 2);
	wout.(covar.label).data(:, sIdx) = w2_sub;
    end
    wout.(covar.label).tr = ((basis.tr(:, 1) + covar.offset) * binSize) * ones(1, sdim);
end
