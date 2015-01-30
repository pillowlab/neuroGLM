function [idx] = getDesignMatrixColIndices(dspec, covarLabels)
% Input
%   dpsec: design specification structure
%   covarLabels: 'str' or {'str'} - label(s) of the covariates
% Outut
%   idx: {} - column indices of the design matrix that correspond to the 
%	    specified covariates

subIdxs = buildGLM.getGroupIndicesFromDesignSpec(dspec);

if ~iscell(covarLabels)
    covarLabels = {covarLabels};
end

idx = cell(numel(covarLabels), 1);

for k = 1:numel(covarLabels)
    idx{k} = subIdxs{dspec.idxmap.(covarLabels{k})}(:);
end
