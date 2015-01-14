function stim = rawStim(label)

stim = @(trial, nT) trial.(label);