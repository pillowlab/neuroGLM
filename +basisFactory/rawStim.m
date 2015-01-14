function stim = rawStim(label)

stim = @(trial, expt) trial.(label);