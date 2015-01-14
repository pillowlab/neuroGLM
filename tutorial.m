%% Load the raw data
rawData = load('exampleData.mat'); % run tutorial_exampleData to generate this
nTrials = rawData.nTrials; % number of trials
unitOfTime = 'ms';
binSize = 1;

%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], rawData.param);
expt = buildGLM.addContinuous(expt, 'LFP', 'Local Field Potential', 1); % continuous obsevation over time
expt = buildGLM.addContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.addTiming(expt, 'dotson', 'Motion Dots Onset'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.addTiming(expt, 'dotsoff', 'Motion Dots Offset');
expt = buildGLM.addTiming(expt, 'saccade', 'Saccade Timing');
expt = buildGLM.addSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train!!!
expt = buildGLM.addValue(expt, 'coh', 'Coherence'); % information on the trial, but not associated with time
expt = buildGLM.addValue(expt, 'choice', 'Direction of Choice');

%% Convert the raw data into the experiment structure

expt.trial = trial;
%{
for kTrial = 1:nTrials
    trial = newTrial(rawData.trial(kTrial).meta, rawData.trial(kTrial).duration);
    trial = extractDataFromStruct(trial, expt, rawData.trial(kTrial)); % assumes this special structure % TODO rename
    expt = addTrial(expt, trial, kTrial);
end
%}

%% Build 'designSpec' which specifies how to generate the design matrix
% Each covariate to include in the model and analysis is specified.

dspec = buildGLM.initDesignSpec(expt);
dspec = buildGLM.addCovariate(dspec, 'LFP'); % include LFP as a covariate

% 5 ms wide raised cosine basis functions tiling 100 ms
bases = basisFactory.makeNonlinearRaisedCos(10, expt.binSize, [0 500], 2);
offset = 0;
dspec = buildGLM.addCovariate(dspec, 'dotson', [], bases, offset);

% 5 ms wide raised cosine basis functions tiling 300 ms length, and with a 20 ms anti-causal offset
% See tutorials in basisFactory for more examples
dspec = buildGLM.addCovariate(dspec, 'saccade', [], basisFactory.raisedCosine(300, 5, -20));

% spike history, make sure it's is strictly causal
dspec = buildGLM.addCovariate(dspec, 'hist', 'sptrain', basisFactory.raisedCosine(300, 5, binSize, 'log'));

% Duration-type that starts at dotson and ends at dotsoff
dspec = buildGLM.addCovariate(dspec, 'dotsDuration', [], basisFactory.boxcarDuration(@(x,k) [x.trial(k).dotson, x.trial(k).dotsoff]));

% Duration-type that starts at dotson and ends at dotsoff and has height
% proportional to the logarithm of coherence
for kCoh = 1:5
    dspec = buildGLM.addCovariate(dspec, expt, ['coh' num2str(kCoh)], basisFactory.boxcarDuration(@(x,k) [x.dotson(k), x.dotsoff(k)]), @(x) log(x.coh(k)));
end

buildGLM.summarizeDesignSpec(dspec); % print out the current configuration

%% Compile the data into 'DesignMatrix' structure
trialIndices = 1:(nTrial-1); % use all trials except the last one
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

buildGLM.visualizeDesignMatrix(dm, 1); % optionally plot the first trial

%% Get the spike trains back to regress against
y = getDataField(expt, 'sptrain', trialIndices);

%% Specify the model
hasBias = true;
model = buildModel(dspec, 'Poisson', 'exp', hasBias);

%% Do regression
[w, stats] = fitGLM(model, dm, y);

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