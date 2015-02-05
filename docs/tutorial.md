# Introduction

Neural recordings are accompanied by various other measurements, controlled manipulations, and other meta data.
For example, timing of a visual cue, time course of an auditory stimulus, behavioral measurements (button press, eye movement, EMG), time and magnitude of the reward, heart beat, on going EEG/ECoG/LFP measurements, and so on.
It is cumbersome to find a representation of these covariates for regression-style analysis, especially when they are events.
This is because events usually do not have an **instantaneous effect to the response (dependent) variable**.
This package allows you to **expand and transform your experimental variables to a feature space as a [design matrix](http://en.wikipedia.org/wiki/Design_matrix) such that a simple linear analysis could yield desired results**.

This tutorial will explain how to import your experimental data, and build appropriate features spaces to do fancy regression analysis easily.

# Loading your data

We assume the experimental variables are observations over time, and organized into **trials**.
If your data don't have a trial structure, you can put all your data in a single trial.
There are 4 types of variables that constitute data: *spike train*, *timing*, *continuous*, and *value*.
This framework uses string labels to address each variable later.

## Types of experimental variables
### Spike train

Each spike train is a sequence of spike timings from a single neuron.
The spike timings are relative to the beginning of the trial.

### Timing (events)

A typical trial based experiment may have a cue that indicates the beginning of a trial, cues that indicate waiting period, or presentation of a target at random times.
These covariates are best represented as events.
However, if two or more timings are perfectly correlated, it would be sufficient to include just one (see [Experiment Design](exptdesign.md) for ore information).
Note that many behaviors are also recorded as timing: reaction time, button press time, etc.

### Continuous

Continuous data are measured continuously over time.
For instance, eye position of the animal may be correlated with the activities of neurons of the study, so the experimentalist could carefully measure it throughout the experiment.
Note that the sampling rate should match the bin size of the analysis, otherwise up-sampling, or down-sampling (with appropriate filtering) is necessary.

### Value

Each trial can have a single value associated with it.
In many cases these are trial specific parameters such as strength of the stimulus, type of cue, or the behavioral category.
These values can be used to build a feature space, or  to include specific feature in trials only when certain conditions are met.

## Registering variables to the experiment

Each experimental variable must be registered before the data are loaded.
First, create an experiment object using `initExperiment`:
```matlab
expt = buildGLM.initExperiment(unitOfTime, binSize, uniqueID, expParam);
```
where `unitOfTime` is a string for the time unit that's going to be used consistently throughout (e.g., 's' or 'ms'), `binSize` is the duration of the time bin to discretize the timings.
`uniqueID` is a string to uniquely identify the experiment among other experiments (mostly for the organizational purpose) and automatically generated if omitted using `[]`.
`expParam` can be anything that you want to associate with the experiment structure for easy access later, since it will be carried around throughout the code.

Then, each experimental variable is registered by indicating the type, label, and user friendly name of the variable.
```matlab
expt = buildGLM.registerContinuous(expt, 'LFP', 'Local Field Potential', 1); % continuous obsevation over time
expt = buildGLM.registerContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.registerTiming(expt, 'dotson', 'Motion Dots Onset'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerTiming(expt, 'saccade', 'Monkey's Saccade Timing');
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train!!!
expt = buildGLM.registerSpikeTrain(expt, 'sptrain2', 'Neighbor Neuron');
expt = buildGLM.registerValue(expt, 'coh', 'Dots Coherence'); % information on the trial, but not associated with time
expt = buildGLM.registerValue(expt, 'choice', 'Direction of Monkey's Choice');
```

Note that one can omit the prefix `buildGLM.` by importing the name space once via
```matlab
import buildGLM.*
```

## Loading the data for each trial

For each trial, we load each of the possible covariate into the experiment structure.

For each trial, we make a temporary object `trial` to load the data:
```matlab
trial = buildGLM.newTrial(expt, duration);
```
where `duration` is the length of the current trial in `unitOfTime`.

`trial` is a structure where you can need to add each of your experimental variables you have registered for the experiment as fields. Below are examples with randomly generated dummy data.

```matlab
trial.dotson = rand() * duration; % timing variable
```

```matlab
st = sort(rand(poissrnd(0.1 * duration), 1) * duration); % homogeneous Poisson process
trial.sptrain = st; % spike train variable
```

```matlab
trial.choice = round(rand); % value variable
```

```matlab
T = expt.binfun(trial.duration); % number of bins for this trial
trial.eyepos = randn(T, 1); % continuous variable
```

Finally, we add the trial object to the experiment object with an associated trial index `kTrial`:
```matlab
expt = buildGLM.addTrial(expt, trial, kTrial);
```

Repeat this for all your trials, and your are done loading your data. See `tutorial*.m` for examples.

Once you are comfortable with the desired data structure, which is just a structure array of the trial objects, you can avoid calling the `newTrial` and `addTrial` functions, and directly plug-in your data into the structure via (see `tutorial_exampleData.m`):

```matlab
expt.trial = dataInTrialStruct; % only if you know what you are doing
```

# Forming your feature space
Once you have your data loaded as an experiment object, you are now ready to specify how your experimental variables will be represented, and hence how your design matrix will be formed.

## Design specification
We start by creating a **design specification object**.
```matlab
dspec = buildGLM.initDesignSpec(expt);
```
You can have multiple such object per experiment to analyze your experiments in different ways and compare models.
The design specification object `dspec` contains specification of how each covariate for the analysis is defined, and the information necessary for temporal embedding and/or nonlinear transformation.

For a timing variable, the following syntax adds a **delta function** at the time of the event:
```matlab
dspec = buildGLM.addCovariateTiming(dspec, 'fpon', 'fpon', 'Fixation On');
```
However, this is seldom what you want. You probably want to have temporal basis to represent delayed effects of the covariate to the response variable.
Let's make a set of 8 boxcar basis functions to cover 300 ms evenly:
```matlab
bs = basisFactory.makeSmoothTemporalBasis('boxcar', 300, 8, expt.binfun);
```
and use this to represent the effect of timing event instead:
```matlab
dspec = buildGLM.addCovariateTiming(dspec, 'fpon', 'fpon', 'Fixation On', bs);
```

If you want to use autoregressive point process modeling (often known as GLM in neuroscience) by adding the spike history filter, you can do the following:
```matlab
dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
```
This adds spike history filters with default history basis functions.
You can do the same to add the coupling filters from other neurons (causal only by default):
```matlab
dspec = buildGLM.addCovariateSpiketrain(dspec, 'coupling', 'sptrain2', 'Coupling from neuron 2');
```

You can add continuous covariates with or without basis functions as well:
```matlab
dspec = buildGLM.addCovariateRaw(dspec, 'eyepos', 'Eye position effect', bs);
```

If you have two timing variables that represent a duration, and would like to represent it as a boxcar:
```matlab
%% Stimulus starts at `dotson` and ends at `dotsoff`
dspec = buildGLM.addCovariateBoxcar(dspec, 'dots', 'dotson', 'dotsoff', 'Motion dots stim');
```

## More on temporal basis functions
The `+basisFactory` package provides functions that generate basis function structures.
Instead of a boxcar, you can use raised cosine basis functions:
```matlab
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 200, 10, expt.binfun);
```
The raised cosine functions are spaced such that they can represent linear functions as well as smoothly varying functions.

## Building the design matrix
The ultimate output is the design matrix:
```matlab
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);
```
where `trialIndices` are the trials to include in making the design matrix. This function is memory intensive, and could take a few seconds to complete.

`dm` is a structure that contains the actual design matrix as `dm.X`. You can visualize this matrix using **what**?

If your design matrix is not very sparse (less than 10% sparse, for example), it's better to conver the design matrix to a full (dense) matrix for speed.
```matlab
dm.X = full(dm.X);
```

# Advanced feature engineering
*Coming soon!*

# Regression analysis
Once you have designed your features, and obtained the design matrix, it's finally time to do some analysis!

## Get the dependent variable
You need to obtain the response variable of the same length as the number of rows in the design matrix to do regression. For **point process** regression, where we want to predict the observed spike train from covariates, this would be a finely binned spike train concatenated over the trials of interest:
```matlab
%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
```

For predicting some continuous observation, such as predicting the LFP, you can do:
```matlab
y = buildGLM.getResponseVariable(expt, 'LFP', dm.trialIndices);
```
Make sure your `y` is a column vector; `getResponseVariable` returns a matrix if the experimental variable is more than 1 dimension.

## Doing the actual regression
You can do whatever you want to do the regression.
Simple least squares can be done via:
```matlab
w = dm.X' * dm.X \ dm.X' * y;
```

Or you can use the `glmfit` in MATLAB statistics toolbox to do the Poisson regression.

```matlab
%% Maximum likelihood estimation using glmfit
[w, dev, stats] = glmfit(dm.X, y, 'poisson', 'link', 'log');
```

# Post regression weight reconstruction
Result of regression is a weight vector (and sometimes additional associated statistics in a vector or matrix) in the feature space. Hence, the weight vector is as long as the number of columns in the design matrix. In order to obtain meaningful temporal weights back corresponding to each covariate, use
```matlab
ws = buildGLM.combineWeights(dm, w);
```
It returns a structure that contains a time axis `ws.(covLabel).tr` and data `ws.(covLabel).data` for each `covLabel` in the design specification structure.
