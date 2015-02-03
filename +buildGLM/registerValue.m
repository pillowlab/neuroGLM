function expt = registerValue(expt, label, vardesc, associatedTiming)
% Indicate that the experiment has a value associated  observation
% expt = registerValue(expt, label, vardesc)
%
% A non-timing value
%
%   label: 'string' - label for the spike train
%   vardesc: 'string' - longer description of where the spike train
%   associatedTiming: 'string' optional - label of the timing variable 
%	associated with this value variable if there is one.

if ~isstruct(expt)
    error('First argument must be a structure created from buildGLM.initExperiment');
end

if isfield(expt.type, label) || isfield(expt.desc, label)
    error('[%s] already registered in this experiment structure');
end

expt.desc.(label) = vardesc;
expt.type.(label) = 'value';

if nargin > 3
    if ~isfield(expt.meta.type, associatedTiming)
        error('Please register the associated timing variable first');
    end
    
    if ~strcmp(expt.meta.type.(associatedTiming), 'timing')
        error('The associated variable must be of timing-type');
    end
    
    expt.valueMap.(associatedTiming) = label;
    expt.valueTimingMap.(label) = associatedTiming;
else
    expt.valueTimingMap.(label) = [];
end

if nargout < 1
    error('Output must be assigned back to an experiment structure');
end
