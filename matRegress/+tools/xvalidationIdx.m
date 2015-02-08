function xidxs = xvalidationIdx(nTotalSamples, kxValidation, isRandomized, isPartition)
% xidxs = xvalidationIdx(nTotalSamples, kxValidation, isRandomized, isPartition)
% Get k-fold cross-validation indices.
%
% Input
%   nTotalSamples: integer number of samples or indices
%   kxValidation: k for the k-cross validation (if 1, training = test)
%   isRandomized: (opt) sequencial or randomized (default) indices?
%   isPartition: (opt) drop extra points at the end to make equal size partitions
% Output
%   xidxs: {kxValidation x 2} training, test indices
%
% Caution: test set is not guarantteed 
%          to be a partition, UNLESS mod(nTotalSamples, kxValidation) == 0
%          In such case, the test set is a partition of nTotalSamples.
%	   Use isPartition to enforce partitioning.
%
% $Id$
% Copyright 2011 Memming. All rights reserved.

if nargin < 3
    isRandomized = true;
end

if nargin < 4
    isPartition = false;
end

if isPartition
    nTotalSamples = nTotalSamples - rem(nTotalSamples, kxValidation);
end

if rem(nTotalSamples,1) ~= 0 | rem(kxValidation,1) ~= 0
    error('xvalidationIdx', 'arguments should be both integers');
end

if ~numel(nTotalSamples) == 1
    ridx = nTotalSamples;
    nTotalSamples = numel(ridx);
else
    ridx = 1:nTotalSamples;
end

% size of the test set
m = ceil(nTotalSamples / kxValidation);
if m < 1
    error('xvalidationIdx:insufficient_samples', 'Not enough samples (%d) to create %d-fold cross-validation', nTotalSamples, kxValidation);
end

if isRandomized
    sidx = randperm(nTotalSamples);
    ridx = ridx(sidx);
end

if kxValidation == 1
    % No cross-validation. All samples are training, and all samples are test.
    xidxs{1,1} = ridx;
    xidxs{1,2} = ridx;
    return
end

startIdx = ceil(linspace(1, nTotalSamples, kxValidation+1));
for k = 1:kxValidation
    testSet = startIdx(k) + (1:m) - 1;
    trainSet = setdiff(1:nTotalSamples, testSet);
    xidxs{k,1} = ridx(trainSet);
    xidxs{k,2} = ridx(testSet);
end
