function dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, varargin)
%
% Input
%   offset: [1] optional/default: 1 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent anti-causal (causal)
%	effects.

if nargin < 4 || isempty(desc); desc = covLabel; end

if nargin < 5
    basisStruct = basisFactory.makeNonlinearRaisedCos(10, dspec.expt.binSize, [0 100], 1);
end

assert(ischar(desc), 'Description must be a string');

offset = basisStruct.param.nlOffset; % Make sure to be causal. No instantaneous interaction allowed.

assert(offset>0, 'Offset must be >0');

binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, varargin{:});