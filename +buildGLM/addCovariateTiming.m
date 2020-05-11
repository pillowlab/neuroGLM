function dspec = addCovariateTiming(dspec, covLabel, stimLabel, desc, varargin)
% Add a timing covariate based on the stimLabel.
% dspec = addCovariateTiming(dspec, covLabel, stimLabel, desc, basisStruct, offset, cond, plotOpts);
%
% Input
%   offset: [1] optional/default: 0 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent anti-causal (causal)
%	effects.

if ~isstruct(dspec)
    error('First argument must be a design specification structure');
end

if nargin < 3; stimLabel = covLabel; end
if nargin < 4; desc = covLabel; end

if nargout < 1
    error('Output must be assigned back to a design structure');
end

if isempty(stimLabel)
    stimLabel = covLabel;
end

%% Check that the stimLabel corresponds to a timing variable
if ~isfield(dspec, 'expt')
    error('Invalid design spec structure.');
else
    expt = dspec.expt;
end

if ~isfield(expt.type, stimLabel)
    error('Label [%s] is not registered in experiment structure', stimLabel);
end

%% Check that the stimLabel corresponds to a continuous variable
if ~strcmp(expt.type.(stimLabel), 'timing')
    error('Type of label [%s] is not timing', stimLabel);
else
    assert(isfield(dspec.expt.trial, stimLabel));
end

binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, varargin{:});
dspec.stimLabel = stimLabel;
