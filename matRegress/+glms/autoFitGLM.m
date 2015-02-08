function model = autoFitGLM(X,Y, prspec, varargin)
% fit generalized linear model to inputs X,Y
% model = autoFitGLM(X,Y, prspec, varargin)
% This function should act as the "glmfit" of matRegress
%
% model = autoFitGLM(X,Y, prspec, 'dist', 'poisson', 'CV', 10, 'PriorInds', {1:10, 11:21}, 'PriorGroup', {'ridge', 'ridge', 'AR1'})
% prspec is a prior "object".. it's really a struct
% varargin
% 'dist'
% 		Likelihood distribution: 'poisson' or 'bernoulli'
% 'CV'
% 		Number of folds: 10 (default) 
% 'link'



dcTerm = range(X)==0;
nwts   = size(X,2);

if any(dcTerm)
	DCflag = true;
end

if numel(prspec)==1

	buildPriorCovariance(prspec, {inds}, {prgrp})