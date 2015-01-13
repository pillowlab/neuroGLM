function expt = addContinuous(expt, label, vardesc, dim)
% Indicate that the experiment has a continuous observation
% expt = addContinuous(expt, varname, vardesc, dim)
%
%   label: 'string' - label for the observed variable
%   vardesc: 'string' - longer description of the variable
%   dim: [1] optional/1 - dimensionality of the observd variable

if ~isstruct(expt)
    error('First argument must be a structure created from buildGLM.initExperiment');
end

if isfield(expt.type, label) || isfield(expt.desc, label)
    error('[%s] already registered in this experiment structure');
end

if nargin < 4
    dim = 1;
end

assert(rem(dim,1) == 0);

expt.desc.(label) = vardesc;
expt.type.(label) = 'continuous';
expt.dim.(label) = dim;

if nargout < 1
    error('Output must be assigned back to an experiment structure');
end