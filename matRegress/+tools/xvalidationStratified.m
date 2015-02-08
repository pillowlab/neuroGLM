function xidxs = xvalidationStratified(idxs, kxValidation, isRandomized, isBalanced)
% xidxs = xvalidationStratified(idxs, kxValidation, isRandomized, isBalanced)
% Get k-fold cross-validation indices that is stratified for each class,
% so that each traing set and test set will have (approximately) equal number
% of samples from each class.
%
% Input
%   idxs: {nClass x 1} sets of indices
%   kxValidation: k for the k-cross validation (if 1, training = test)
%   isRandomized:(opt) sequencial or randomized (default) indices?
%   isBalanced:(opt) make the size of sets equal (default) or allow it to differ
%
% Output
%   xidxs: {kxValidation x 2} training, test indices
%
% Reference: (Parker et. al. 2007)
%
% $Id$
% Copyright 2011 Memming. All rights reserved.

if nargin < 3
    isRandomized = true;
end

if nargin < 4
    isBalanced = true;
end

nClass = length(idxs);
N = cellfun('length', idxs);

if isRandomized
    for k = 1:nClass
	sidx = randperm(N(k));
	idxs{k} = idxs{k}(sidx);
    end
end

if isBalanced
    N = N - rem(N, kxValidation);
end

if kxValidation == 1
    % No cross-validation. All samples are training, and all samples are test.
    xidxs{1,1} = unionIdx(idxs);
    xidxs{1,2} = xidxs{1,1};
    return
end

if any(N == 0)
    disp(N);
    error('xvalidationStratified:empty', 'Some classes are empty?');
end

% size of the test set
m = ceil(N / kxValidation);

if any(m == 0)
    disp(m);
    error('xvalidationStratified:notEnoughSamples', 'Not enough samples!');
end

for kClass = 1:nClass
    startIdx{kClass} = ceil(linspace(1, N(kClass), kxValidation+1));
end

for k = 1:kxValidation
    for kClass = 1:nClass
	testSet{kClass} = idxs{kClass}(startIdx{kClass}(k) + (1:m(kClass)) - 1);
	trainSet{kClass} = setdiff(idxs{kClass}(1:N(kClass)), testSet{kClass});
    end
    xidxs{k,1} = unionIdx(trainSet);
    xidxs{k,2} = unionIdx(testSet);
end

end

function idx = unionIdx(idxCell)
    N = cellfun('length', idxCell);
    idx = zeros(sum(N), 1);
    last = 1;
    for k = 1:length(idxCell)
	idx(last:last+N(k)-1) = idxCell{k};
	last = last + N(k);
    end
end
