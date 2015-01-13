function expt = initExperiment(unitOfTime, binSize, uniqueID)
% Initialize the Experiment structure that holds raw data
% expt = initExperiment(unitOfTime, binSize, uniqueID)
%
%   unitOfTime: 'string' - 's' or 'ms' indicating a global unit of time
%   binSize: [1] - duration of each time bin in units of unitOfTime
%   uniqueID: 'string' optional - Unique identifier for this experiment
%       a compact string for easy future reference

assert(binSize > 0);
assert(ischar(unitOfTime), 'Put a string for unit');

expt = struct('unitOfTime', unitOfTime, 'binSize', binSize);
expt.meta.type = struct();
expt.meta.desc = struct();
expt.meta.dim = struct();

if nargin > 2
    expt.id = uniqueID;
end