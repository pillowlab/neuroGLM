neuroGLM
=========================

Supports flexible regression analyses of trial-based spike train data
using a Generalized Linear Model (GLM). This modeling framework aims
to discover how neural responses encode both external (e.g., sensory,
motor, reward variables) and internal (e.g., spike history, LFP
signals) covariates of the response.

This MATLAB code is a reference implementation for the analyses found
in [Park et al. 2014](http://pillowlab.princeton.edu/pubs/abs_ParkI_NN14.html).


Downloading the repository
------------

- **From command line:**

     ```git clone git@github.com:pillowlab/neuroGLM.git```

- **In browser:**   click to
  [Download ZIP](https://github.com/pillowlab/neuroGLM/archive/master.zip)
  and then unzip archive


Example Script
-
Open ``tutorial.m`` to see it in action using a simulated dataset


Simple Overview
-------------

Suppose we record spike responses from a single neuron during a
complex behavioral experiment, and would like to know what aspects of
the stimulus or behavior are encoded in the neural response. This code
package allows us to discover such dependencies using Poisson GLM
regression.

Consider a simple example in which a neuron encodes two experimental
variables: the time at which a visual target appears, and the motion
strength of a moving-dots stimulus. The regressors are
the time at which the targets appear, and the time,
duration, and strength ("coherence") of the moving dots on each
trial.   

[Extra documentation](docs/tutorial.md)

## Reference

- I. M. Park, M. L. R. Meister, A. C. Huk, &  J. W. Pillow
 (2014).
 [Deciphering the code for sensorimotor decision-making in parietal cortex](http://pillowlab.princeton.edu/pubs/abs_ParkI_NN14.html) Nature Neuroscience 17, 1395-1403.
