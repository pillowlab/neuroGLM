function dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, varargin)
% add spike train as covariate
% dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, varargin)

if nargin < 4; desc = covLabel; end

if nargin < 5
    basisStruct = basisFactory.makeNonlinearRaisedCos(10, dspec.expt.binSize, [0 100], 2);
end

assert(ischar(desc), 'Description must be a string');

offset = 1; % Make sure to be causal. No instantaneous interaction allowed.

binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, varargin{:});