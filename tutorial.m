%% Load the raw data
rawData = load('exampleData.mat'); % run tutorial_exampleData to generate this
nTrials = rawData.nTrials; % number of trials
unitOfTime = 'ms';
binSize = 1; % TODO some continuous observations might need up/down-sampling if binSize is not 1!?

%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], rawData.param);
expt = buildGLM.addContinuous(expt, 'LFP', 'Local Field Potential', 1); % continuous obsevation over time
expt = buildGLM.addContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.addTiming(expt, 'dotson', 'Motion Dots Onset'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.addTiming(expt, 'dotsoff', 'Motion Dots Offset');
expt = buildGLM.addTiming(expt, 'saccade', 'Saccade Timing');
expt = buildGLM.addSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train!!!
expt = buildGLM.addSpikeTrain(expt, 'sptrain2', 'Neighbor Neuron');
expt = buildGLM.addValue(expt, 'coh', 'Coherence'); % information on the trial, but not associated with time
expt = buildGLM.addValue(expt, 'choice', 'Direction of Choice');

%% Convert the raw data into the experiment structure

expt.trial = rawData.trial;
%verifyTrials(expt); % checks if the formats are correct

%% Build 'designSpec' which specifies how to generate the design matrix
% Each covariate to include in the model and analysis is specified.
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;
bs = basisFactory.makeSmoothTemporalBasis('boxcar', 100, 10, binfun);
bs.B = 0.1 * bs.B;

%% Instantaneous Raw Signal without basis
dspec = buildGLM.addCovariateRaw(dspec, 'LFP', [], bs);

%% Spike history
dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');

%% Coupling filter
dspec = buildGLM.addCovariateSpiketrain(dspec, 'coupling', 'sptrain2', 'Coupling from neuron 2');

%% Duration boxcar
dspec = buildGLM.addCovariateBoxcar(dspec, 'dots', 'dotson', 'dotsoff', 'Motion dots stim');

%% Acausal Timing Event
bs = basisFactory.makeSmoothTemporalBasis('boxcar', 300, 8, binfun);
offset = -200;
dspec = buildGLM.addCovariateTiming(dspec, 'saccade', [], [], bs, offset);

%% Coherence
% a box car that depends on the coh value
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 200, 10, binfun);
stimHandle = @(trial, expt) trial.coh * basisFactory.boxcarStim(binfun(trial.dotson), binfun(trial.dotsoff), binfun(trial.duration));

dspec = buildGLM.addCovariate(dspec, 'cohKer', 'coh-dep dots stimulus', stimHandle, bs);

%% 2-D eye position
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 40, 4, binfun);
dspec = buildGLM.addCovariateRaw(dspec, 'eyepos', [], bs);

%buildGLM.summarizeDesignSpec(dspec); % print out the current configuration

%% Compile the data into 'DesignMatrix' structure
trialIndices = 1:10; %(nTrials-1); % use all trials except the last one
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Visualize the design matrix
endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
X = dm.X(1:endTrialIndices(3),:);
mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
X = bsxfun(@times, X, 1 ./ mv);
figure(742); clf; imagesc(X);
%buildGLM.visualizeDesignMatrix(dm, 1); % optionally plot the first trial

%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', trialIndices);

%% Maximum likelihood estimation using glmfit
[w, dev, stats] = glmfit(dm.X, y, 'poisson', 'link', 'log');

%% Visualize
ws = buildGLM.combineWeights(dm, w);
wvar = buildGLM.combineWeights(dm, stats.se.^2);

fig = figure(2913); clf;
nCovar = numel(dspec.covar);
for kCov = 1:nCovar
    label = dspec.covar(kCov).label;
    subplot(nCovar, 1, kCov);
    errorbar(ws.(label).tr, ws.(label).data, sqrt(wvar.(label).data));
    title(label);
end

return

%{
%% Specify the model
hasBias = true;
model = buildGLM.buildModel(dspec, 'Poisson', 'exp', hasBias);

%% Do regression
[w, stats] = fitGLM(model, dm, y);
%}

%% Visualize fit
visualizeFit(w, model, dspec, vparam(1)); % ???

%% Simulate from model for test data
testTrialIndices = nTrial; % test it on the last trial
dmTest = compileSparseDesignMatrix(expt, dspec, testTrialIndices);

yPred = generatePrediction(w, model, dmTest);
ySamp = simulateModel(w, model, dmTest);

%% Validate model
gof = goodnessOfFit(w, stats, model, dmTest);
visualizeGoodnessOfFit(gof);
