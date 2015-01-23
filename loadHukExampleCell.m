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
expt = buildGLM.addContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.addTiming(expt, 'fpon', 'Fixation Onset');
expt = buildGLM.addTiming(expt, 'dotson', 'Motion Dots Onset'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.addTiming(expt, 'dotsoff', 'Motion Dots Offset');
expt = buildGLM.addTiming(expt, 'resp', 'Saccade Timing');
expt = buildGLM.addSpikeTrain(expt, 'sptrain', neuronID); % Spike train!!!
expt = buildGLM.addValue(expt, 'coh', 'Coherence');
expt = buildGLM.addValue(expt, 'choice', 'Monkey''s Choice');

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

return

%% Make design matrix and response full matrix (not sparse)
dm.X = full(dm.X);
y = full(y);

%% z-score columns to reduce ill-conditioneding
[dm.X, z_mu, z_sigma] = zscore(dm.X);
z_constantColumns = (z_sigma == 0);
dm.X = dm.X(:, ~z_constantColumns);

%% Check sanity of the design
if any(~isfinite(dm.X(:)))
    warning('Design matrix contains NaN or Inf...this is not good!');
end

if any(~isfinite(y(:)))
    warning('Dependent variable contains NaN or Inf...this is not good!');
end

%%
fprintf('Least squares regression for initialization...'); tic;
X = [ones(size(dm.X, 1), 1), dm.X];
XX = X' * X + 1e3 * eye(size(X, 2));
XY = X' * y;
w = XX \ XY;
stats.se = sqrt(diag(inv(XX)));
fprintf(' %f sec\n', toc);

%% Visualize the design matrix
endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
X = dm.X(1:endTrialIndices(3),:);
mv = max(abs(X), [], 1); mv(isnan(mv) | isinf(mv) | mv == 0) = 1;
X = bsxfun(@times, X, 1 ./ mv);
figure(742); clf; imagesc(X);

%% Maximum likelihood estimation using glmfit
fprintf('Poisson regression (MLE) via glmfit...'); tic;
[w, dev, stats] = glmfit(dm.X, y, 'Poisson');
fprintf(' %f sec\n', toc);

%% Inverse z-score transform
w2 = zeros(dm.dspec.edim, 1);
w2(~z_constantColumns) = w(2:end); % first term is bias
w2 = (w2 .* z_sigma(:)) + z_mu(:);
w = [w(end); w2];

%%
ws = buildGLM.combineWeights(dm, w);
%wvar = buildGLM.combineWeights(dm, stats.se.^2);

fig = figure(2913); clf;
nCovar = numel(dspec.covar);
for kCov = 1:nCovar
    label = dspec.covar(kCov).label;
    subplot(nCovar, 1, kCov);
    %errorbar(ws.(label).tr, ws.(label).data, sqrt(wvar.(label).data));
    plot(ws.(label).tr, ws.(label).data);
    title(label);
end
