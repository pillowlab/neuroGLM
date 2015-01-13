%% Generate example (raw) dataset for the tutorial

% REQUIRES stat toolbox for poissnrnd

nTrials = 100; % total number of trials

% preallocate structure in memory
trial = struct();
trial(nTrials).duration = 0; % preallocate

lambda = 0.1; % firing rate per bin

for kTrial = 1:nTrials
    duration = 150 + ceil(rand * 200);
    trial(kTrial).duration = duration;
    trial(kTrial).LFP = cumsum(randn(duration, 1));
    trial(kTrial).eyepos = cumsum(randn(duration, 2));
    trial(kTrial).dotson = ceil(rand * (duration - 100));
    trial(kTrial).dotsoff = trial(kTrial).dotson + ceil(rand * 10);
    trial(kTrial).saccade = 100 + ceil(rand * (duration - 100));
    trial(kTrial).coh = sign(rand - 0.5) * 2^ceil(rand*8);
    trial(kTrial).choice = round(rand);
    trial(kTrial).sptrain = sort(rand(poissrnd(lambda * duration), 1) * duration);
    trial(kTrial).meta = rand;
end

param.samplingFreq = 12000; % Hz
param.monkey = 'F99';

save('exampleData.mat', 'nTrials', 'trial', 'param')