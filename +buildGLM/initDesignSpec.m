function dspec = initDesignSpec(expt)
% Initialize the designSpec structure
%
% DesignSpec tells us how to compile the experiment data into a
% specfic design matrix. Each analysis you do could have different
% design -- different covariates to include, different parameterization,
% or some nonlinear transformation/feature.

dspec = struct('expt', expt);
dspec.covar = struct();
dspec.idxmap = struct(); % reverse positional indexing