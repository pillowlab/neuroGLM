function y = getResponseVariable(expt, label, trialIdx)
% y: a column vector or matrix representing the concatenated continuous variable

if ~isstruct(expt)
    error('First argument must be an experiment structure');
end

if ~isfield(expt.type, label)
    error('Label [%s] is not registered in the experiment structure', label);
end

%% Check that the label corresponds to a continuous variable
if ~strcmp(expt.type.(label), 'continuous')
    error('Type of label [%s] is not continuous', label);
end

%% put everything in a cell
ycell = cell(numel(trialIdx), 1);

for kTrial = trialIdx(:)'
    ycell{kTrial} = expt.trial(kTrial).(label);
end

y = cell2mat(ycell);
