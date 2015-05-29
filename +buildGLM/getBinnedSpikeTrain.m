function y = getBinnedSpikeTrain(expt, spLabel, trialIdx)
% y: a sparse column vector representing the concatenated spike trains

sts = cell(numel(trialIdx), 1);
binfun = expt.binfun;
endTrialIndices = [0 cumsum(binfun([expt.trial(trialIdx).duration])) + 1];
nT = endTrialIndices(end) - 1; % how many bins total?

for k = 1:numel(trialIdx)
    kTrial = trialIdx(k);
    bst = endTrialIndices(k) + binfun(expt.trial(kTrial).(spLabel));
    sts{k} = bst(:);
end

sts = cell2mat(sts);
sts(sts>nT) = [];
y = sparse(sts, 1, 1, nT, 1);
