function expt = initExperiment(unitOfTime, binSize)
% Initialize the Experiment structure that holds raw data
% expt = initExperiment(unitOfTime, binSize)

assert(binSize > 0);
assert(ischar(unitOfTime), 'Put a string for unit');

expt = struct('unitOfTime', unitOfTime, 'binSize', binSize);