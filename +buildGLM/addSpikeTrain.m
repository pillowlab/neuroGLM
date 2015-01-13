function expt = addSpikeTrain(expt, label, vardesc)
% Indicate that the experiment has a spike train observation
% expt = addSpikeTrain(expt, label, vardesc)
%
% Spike trains are treated differently for visualization, and goodness-of-fit
% evaluations.
%
%   label: 'string' - label for the spike train
%   vardesc: 'string' - longer description of where the spike train
%   originates from

if ~isstruct(expt)
    error('First argument must be a structure created from buildGLM.initExperiment');
end

if isfield(expt.meta.type, label) || isfield(expt.meta.desc, label)
    error('[%s] already registered in this experiment structure');
end

expt.meta.desc.(label) = vardesc;
expt.meta.type.(label) = 'spike train';

if nargout < 1
    error('Output must be assigned back to an experiment structure');
end