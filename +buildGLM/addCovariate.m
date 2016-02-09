function dspec = addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, cond, plotOpts)
% Add a covariate to the design specification object.
% dspec = addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, cond, plotOpts);
%
% Input
%   dspec: struct - design specification object (see initDesignSpec)
%   covLabel: string - name to refer to the covariate
%   desc: string  - human readable description of the covariate
%   stimHandle: @(trial, expt) -> [T x m] the raw stimulus design before 
%	applying the basis functions.
%   basisStruct: struct - temporal basis functions that will be convolved with
%	the output of the stimHandle. See +basisFactory functions (e.g. 
%	+basisFactory.makeSmoothTemporalBasis)
%   offset: [1] optional/default:0 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent anti-causal (causal)
%	effects.
%   cond: @(trial) -> boolean optional: condition for which the covariate will
%	be included. For example, if only trials where 'choice' is 1 to include
%	the current covariate, use @(trial) (trial.choice == 1)
%
% Output
%   dspec: updated design specification object
%
% See also: addCovariateTiming, addCovariateRaw, addCovariateBoxcar, addCovariateSpiketrain

if nargout < 1
    error('Output must be assigned back to a design structure');
end

if ~isstruct(dspec)
    error('First argument must be a structure created from buildGLM.initDesignSpec');
end

if ~ischar(covLabel)
    error('Covariate label must be a string');
end

if nargin < 3; desc = covLabel; end
if nargin < 4; stimHandle = []; end

if isfield(dspec.idxmap, covLabel)
    error('Label already added as a covariate');
end

newIdx = numel(fieldnames(dspec.idxmap)) + 1;

dspec.covar(newIdx).label = covLabel;
dspec.covar(newIdx).desc = desc;
dspec.covar(newIdx).stim = stimHandle;
dspec.idxmap.(covLabel) = newIdx;

sdim = size(stimHandle(dspec.expt.trial(1), dspec.expt), 2);
dspec.covar(newIdx).sdim = sdim;

if nargin >= 5
    if isstruct(basisStruct)
        dspec.covar(newIdx).basis = basisStruct;
        dspec.covar(newIdx).edim = basisStruct.edim * sdim;
    else
        error('Basis structure should be a structure (use [] to have no basis)');
    end
else
    dspec.covar(newIdx).edim = sdim;
end

if nargin >= 6
    dspec.covar(newIdx).offset = offset;
else
    dspec.covar(newIdx).offset = 0;
end

if nargin >= 7
    if ~isempty(cond) && ~isa(cond, 'function_handle')
        error('Condition must be a function handle that takes trial');
    end
    dspec.covar(newIdx).cond = cond;
else
    dspec.covar(newIdx).cond = [];
end

if nargin >= 8
    dspec.covar(newIdx).plotOpts = plotOpts;
end

dspec.edim = sum([dspec.covar(:).edim]);
