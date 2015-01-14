function X = convBasis(stim, bases, offset)
% Convolve basis functions to the covariate matrix
%
%   stim: [T x dx] - covariates over time
%   bases: Basis structure
%   offset: [1] optional - shift in time

if nargin < 3
    offset = 0;
end

[~, dx] = size(stim);

% zero pad stim to account for the offset
if offset < 0 % anti-causal
    stim = [stim; zeros(-offset, dx)];
elseif offset > 0; % push to future
    stim = [zeros(offset, dx); stim];
end

if issparse(stim) || nnz(stim) < 20;
    X = basisFactory.temporalBases_sparse(stim, bases.B);
else
    X = basisFactory.temporalBases_dense(stim, bases.B);
end

if offset < 0 % anti-causal
    X = X(-offset+1:end, :);
elseif offset > 0
    X = X(1:end-offset, :);
end