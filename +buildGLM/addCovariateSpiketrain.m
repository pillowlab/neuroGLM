function dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, varargin)
% add spike train as covariate
% dspec = addCovariateSpiketrain(dspec, covLabel, stimLabel, desc, basisStruct, cond)
%
% Input
%   dspec: struct - design specification object (see initDesignSpec)
%   covLabel: string - name to refer to the covariate
%   stimLabel: string - label from trial struct-array
%   desc: string  - human readable description of the covariate
%   stimHandle: @(trial, expt) -> [T x m] the raw stimulus design before 
%	applying the basis functions.
%   basisStruct: struct - temporal basis functions that will be convolved with
%	the output of the stimHandle. See +basisFactory functions (e.g. 
%	+basisFactory.makeSmoothTemporalBasis)
%   offset: [1] optional/default:0 - number of **time bins** to shift the
%	regressors. Negative (positive) integers represent acausal (causal)
%	effects.
%   cond: @(trial) -> boolean optional: condition for which the covariate will
%	be included. For example, if only trials where 'choice' is 1 to include
%	the current covariate, use @(trial) (trial.choice == 1)
%
% Output
%   dspec: updated design specification object
%
% See also: addCovariateTiming, addCovariateRaw, addCovariateBoxcar, addCovariateSpiketrain

if nargin < 4; desc = covLabel; end

if nargin < 5
    basisStruct = basisFactory.makeNonlinearRaisedCos(10, dspec.expt.binSize, [0 100], 2);
end

assert(ischar(desc), 'Description must be a string');

offset = 1; % Make sure to be causal. No instantaneous interaction allowed.
binfun = dspec.expt.binfun;
stimHandle = @(trial, expt) basisFactory.deltaStim(binfun(trial.(stimLabel)+expt.binSize), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, covLabel, desc, stimHandle, basisStruct, offset, varargin{:});