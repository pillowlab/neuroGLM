%% Load raw data structure
% 'pp' is the structe with all data arranged as vectors over trials
load('data/pp_p033011b.mat');

%% Setup the experiment
nTrials = pp.ntrials; % number of trials
unitOfTime = 'ms';
binSize = 1;
neuronID = 'p033011b';

%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], pp.taskParadigm);
expt = buildGLM.registerContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.registerTiming(expt, 'fpon', 'Fixation Onset');
expt = buildGLM.registerTiming(expt, 'dotson', 'Motion Dots Onset'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerTiming(expt, 'dotsoff', 'Motion Dots Offset');
expt = buildGLM.registerTiming(expt, 'resp', 'Saccade Timing');
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', neuronID); % Spike train!!!
expt = buildGLM.registerValue(expt, 'coh', 'Coherence');
expt = buildGLM.registerValue(expt, 'choice', 'Monkey''s Choice');

%% Load detailed info from the trials
timingLabels = fieldnames(pp.t);
valueLabelsFrom = {'cohabs', 'cohsigned', 'iscorrect', 'targchosen', 'dir'};
valueLabelsTo = {'cohabs', 'coh', 'iscorrect', 'choice', 'dir'};

for kTrial = 1:pp.ntrials
    duration = pp.t.end_tri(kTrial);
    
    trial = buildGLM.newTrial(expt, duration);
    
    % Events
    for kLabel = 1:numel(timingLabels)
        label = timingLabels{kLabel};
        trial.(label) = pp.t.(label)(kTrial);
    end
    
    % Continuous
    trial.eyepos = [pp.eyeposx{kTrial}, pp.eyeposy{kTrial}];
    T = expt.binfun(trial.duration);
    trial.eyepos = trial.eyepos(1:T, :); % Trim extra recording

    % Values
    for kLabel = 1:numel(valueLabelsFrom)
        toLabel = valueLabelsTo{kLabel};
        if isempty(toLabel); toLabel = valueLabelsFrom{kLabel}; end
        trial.(toLabel) = pp.(valueLabelsFrom{kLabel})(kTrial);
    end
    
    % Spike train
    trial.sptrain = pp.Mtsp{kTrial};
    trial.sptrain(trial.sptrain <= 0) = []; % remove spikes before trial
    trial.sptrain(trial.sptrain > trial.duration) = []; % remove spikes after trial ends
    
    expt = buildGLM.addTrial(expt, trial, kTrial);
end

%% Specify design matrix parameters
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 300, 6, binfun);

dspec = buildGLM.addCovariateTiming(dspec, 'fpon', 'fpon', 'Fixation On', bs);

dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');

bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 200, 10, binfun);
stimHandle = @(trial, expt) sign(trial.coh) * log(1e-3 + abs(trial.coh)) * basisFactory.boxcarStim(binfun(trial.dotson), binfun(trial.dotsoff), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, 'cohKer', 'coh-dep dots stimulus', stimHandle, bs);

bs = basisFactory.makeSmoothTemporalBasis('boxcar', 2000, 40, binfun);
offset = -1000; % acausal
dspec = buildGLM.addCovariateTiming(dspec, 'resp1', 'resp', [], bs, offset, @(trial) (trial.choice == 1));
dspec = buildGLM.addCovariateTiming(dspec, 'resp2', 'resp', [], bs, offset, @(trial) (trial.choice == 2));

%% Compile the data into 'DesignMatrix' structure
trialIndices = 1:min(300, nTrials);
fprintf('Building the design matrix...'); tic;
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);
fprintf(' %f sec\n', toc);

%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', trialIndices);

%% Make design matrix and response full matrix (not sparse)
dm.X = full(dm.X);
y = full(y);

%% z-score and remove constant cols
dm = buildGLM.removeConstantCols(dm);
dm = buildGLM.zscoreDesignMatrix(dm);