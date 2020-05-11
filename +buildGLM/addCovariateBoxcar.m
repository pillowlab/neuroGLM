function dspec = addCovariateBoxcar(dspec, covLabel, startLabel, endLabel, desc, varargin)
%
% Input
%   offset: [1] optional/default: 0 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent anti-causal (causal)
%	effects.

if nargin < 5; desc = covLabel; end

assert(ischar(desc), 'Description must be a string');

binfun = dspec.expt.binfun;
stimHandle = @(trial, nT) basisFactory.boxcarStim(binfun(trial.(startLabel)), binfun(trial.(endLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, varargin{:});