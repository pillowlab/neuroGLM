# Introduction

Often times neural recordings are accompanied with various other measurements and controlled manipulations.
For example, timing of a visual cue, auditory stimulus, behavioral measurements (button press, eye movement, EMG), time and magnitude of the reward, heart beat, on going EEG/ECoG/LFP measurements, and so on.
It is cumbersome to find a representation of these covariates for regression-style analysis, especially when they are events.
This package allows you to expand and transform your data into a design matrix such that a linear analysis could yield desired results.

# Loading your data

We assume the experimental data are observations over time, and organized into **trials**.
If your data don't have a trial structure, in this framework you have a single trial.
There are 4 types of variables that constitute data: *continuous*, *timing*, *spike train*, and *value*.
This framework uses string labels to address each variable that are registered.

## Spike train

Spike trains are sequence of timings.
The spike timings are relative to the beginning of the trial.
You can have spike trains from more than one neuron.

## Timing (events)

A typical trial based experiment may have a cue that indicates the beginning of a trial, cues that indicate waiting period, or presentation of a target at random times.
These covariates are best represented as events, and the timing is recorded.
Also, many behaviors are recorded as timing: reaction time, button press time, etc.

## Continuous

Continuous data are measured continuously over time.
For instance, eye position of the animal may be correlated with the neuron of interest, so the experimentalist carefully measured it through out the experiment.
The sampling rate should match the bin size of the analysis, otherwise up-sampling, or down-sampling (with appropriate filtering) is necessary.

## Value

Each trial can have a single value associated with it.
In many cases these are 

# Forming your feature space

# Advanced feature engineering
