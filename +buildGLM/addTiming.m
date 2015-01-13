function expt = addTiming(expt, label, vardesc)
% Indicate that the experiment has an event type observation
% expt = addTiming(expt, label, vardesc)
%
% Events can happen 0 or more times within a single trial and efficiently
% represented by a sparse vector.
%
%   label: 'string' - label for the observed variable
%   vardesc: 'string' - longer description of the variable

if ~isstruct(expt)
    error('First argument must be a structure created from buildGLM.initExperiment');
end

if isfield(expt.meta.type, label) || isfield(expt.meta.desc, label)
    error('[%s] already registered in this experiment structure');
end

expt.meta.desc.(label) = vardesc;
expt.meta.type.(label) = 'timing';

if nargout < 1
    error('Output must be assigned back to an experiment structure');
end