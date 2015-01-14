function dspec = addCovariateTiming(dspec, covLabel, stimLabel, desc, varargin)

if nargin < 3; stimLabel = covLabel; end
if nargin < 4; desc = covLabel; end

if isempty(stimLabel)
    stimLabel = covLabel;
end

assert(isfield(dspec.expt.trial, stimLabel));

binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, varargin{:});