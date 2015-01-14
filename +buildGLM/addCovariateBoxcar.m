function dspec = addCovariateBoxcar(dspec, covLabel, startLabel, endLabel, desc, varargin)

if nargin < 5; desc = covLabel; end

assert(ischar(desc), 'Description must be a string');

binfun = dspec.expt.binfun;
stimHandle = @(trial, nT) basisFactory.boxcarStim(binfun(trial.(startLabel)), binfun(trial.(endLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, varargin{:});