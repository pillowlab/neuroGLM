function BX = temporalBases_sparse(X, bases, indices, addDC)
% Computes the convolution of X with the selected bases functions.
% It cannot do partial time indices. Use it for trial-based computation.
%
% Each row of X marks events, and with corresponding bases selected by indices,
% it is convolved to the feature matrix.
%
% Input:
%   X: (T x dx) sparse matrix of events through time (T bins, dx events)
%   bases: (TB x M) TB bins of M bases
%   indices: (dx x M/default:true) binary index of which bases to use for each event
%   addDC: (boolean/default:false) if true, append a row of ones for DC (bias)
%
% Output:
%   BX: (T x nTotalFeatuers) full matrix of features

if nargin < 4; addDC = 0; end
if addDC; addDC = 1; end

[T, dx] = size(X);
[TB, M] = size(bases);

if nargin < 3; indices = true(dx, M); end

assert(M == size(indices, 2), '# of basis shd equal the 2nd dim of indices');
assert(dx == size(indices, 1), '# of events shd equal the 1st dim of indices');

featuresPerRow = sum(indices, 2); % (dx x 1) # of features per each event
nTotalFeatuers = sum(featuresPerRow);
featureRowIndex = [0; cumsum(featuresPerRow)];
BX = zeros(T, nTotalFeatuers + addDC);

if addDC; BX(:, end) = 1; end

for k = 1:dx
    idx = find(X(:, k));
    for kk = 1:length(idx)
        timeIdx = idx(kk):min(T,idx(kk)+TB-1);
        featureIdx = (featureRowIndex(k)+1):featureRowIndex(k+1);
        timeBasisIdx = 1:min(TB, T-idx(kk)+1);
        if X(idx(kk), k) == 1
            BX(timeIdx, featureIdx) = BX(timeIdx, featureIdx) + ...
                bases(timeBasisIdx, indices(k, :));
        else
            BX(timeIdx, featureIdx) = BX(timeIdx, featureIdx) + ...
                bases(timeBasisIdx, indices(k, :)) * X(idx(kk), k);
        end
    end
end
