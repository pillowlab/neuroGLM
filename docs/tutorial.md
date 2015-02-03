# Introduction

Neural recordings are accompanied by various other measurements, controlled manipulations, and other meta data.
For example, timing of a visual cue, time course of an auditory stimulus, behavioral measurements (button press, eye movement, EMG), time and magnitude of the reward, heart beat, on going EEG/ECoG/LFP measurements, and so on.
It is cumbersome to find a representation of these covariates for regression-style analysis, especially when they are events.
This is because events usually do not have an **instantaneous effect to the response (dependent) variable**.
This package allows you to **expand and transform your experimental variables to a feature space as a [design matrix](http://en.wikipedia.org/wiki/Design_matrix) such that a simple linear analysis could yield desired results**.

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
expt = buildGLM.registerTiming(expt, 'dotsoff', 'Motion Dots Offset');
expt = buildGLM.registerTiming(expt, 'saccade', 'Saccade Timing');
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train!!!
expt = buildGLM.registerSpikeTrain(expt, 'sptrain2', 'Neighbor Neuron');
expt = buildGLM.registerValue(expt, 'coh', 'Coherence'); % information on the trial, but not associated with time
expt = buildGLM.registerValue(expt, 'choice', 'Direction of Choice');
```

Note that one can omit the prefix `buildGLM.` by importing the name space via
```matlab
import buildGLM.*
```
once.

## Loading the data for each trial

# Forming your feature space

# Advanced feature engineering
