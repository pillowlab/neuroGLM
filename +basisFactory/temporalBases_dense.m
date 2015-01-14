function BX = temporalBases_dense(X, bases, indices, addDC)
% Computes the convolution of X with the selected bases functions.
% It cannot do partial time indices. Use it for trial-based computation.
%
% Each row of X marks events, and with corresponding bases selected by indices,
% it is convolved to the feature matrix.
%
% Input:
%   X: (T x dx) full matrix of events through time (T bins, dx events)
%   bases: (TB x M) TB bins of M bases
%   indices: (dx x M) binary index of which bases to use for each event
%   addDC: (boolean/default:false) if true, append a row of ones for DC (bias)
%
% Output:
%   BX: (T x nTotalFeatuers) full matrix of features
%
% jly 2013: not as fast as it could be, but it's faster than treating X as a sparse
% matrix

if nargin < 4; addDC = 0; end
if addDC; addDC = 1; end

[T,dx] = size(X);
[TB, M] = size(bases);

if nargin < 3; indices = true(dx, M); end

sI = sum(indices, 2); % bases per covariate

BX = zeros(T, sum(sI) + addDC);

sI = cumsum(sI); k = 1;
for kCov = 1:dx
    A = conv2(X(:,kCov), bases(:,indices(kCov,:)));
    BX(:, k:sI(kCov)) = A(1:T,:); %1:end-(nB-1));
    
    k = sI(kCov) + 1;
end

if addDC; BX(:, end) = 1; end
