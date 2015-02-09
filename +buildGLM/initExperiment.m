function expt = initExperiment(unitOfTime, binSize, uniqueID, param)
% Initialize the Experiment structure that holds raw data
% expt = initExperiment(unitOfTime, binSize, uniqueID)
%
%   unitOfTime: 'string' - 's' or 'ms' indicating a global unit of time
%   binSize: [1] - duration of each time bin in units of unitOfTime
%   uniqueID: 'string' optional - Unique identifier for this experiment
%       a compact string for easy future reference
%   param: (any) optional - any potentially useful extra information
%       associated with the entire experiment record (experimental
%       parameters)

assert(binSize > 0);
assert(ischar(unitOfTime), 'Put a string for unit');

expt = struct('unitOfTime', unitOfTime, 'binSize', binSize);
expt.binfun = @(t) (t == 0) + ceil(t/expt.binSize);
expt.type = struct();
expt.desc = struct();
expt.dim = struct();

if nargin > 2 && ~isempty(uniqueID)
    expt.id = uniqueID;
else
    [ret, hostname] = system('hostname');
    
    if ret ~= 0
        if ispc
            hostname = getenv('COMPUTERNAME');
        else
            hostname = getenv('HOSTNAME');
        end
    end
    hostname = strtrim(lower(hostname));

    expt.id = [datestr(now, 30) '@' hostname];
end

if nargin > 3
    expt.param = param;
else
    expt.param = struct();
end
