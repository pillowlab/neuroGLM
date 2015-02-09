% matRegress will fit GLMS with different regularization for parameter
% groups

% There are two forms this can take
%
% 1. is the same regularization across multiple covariates, but with a
% separation between them. This is important for smoothing. We might expect
% weights to be smooth across for the response to the targets and the
% choices, but we don't want to smooth between the targets and choices.
%
% 2. regularization is different for the different covariates. For example,
% we might want different amounds of smoothness for the stimulus and the
% spike history. The stimulus is probably very smooth, but the spike
% history is not. Some of this can be imposed by the selection of basis
% funcitons, but it would be nice to have the option to learn different
% hyperparameters for the different types of covariate.

% This sample code will learn the hyper parameters for logistic regression
% weights for different inputs. The covariates are based on the gabor-pulse
% experiment, but the number of stimulus covariates can be 

% build covariates
nTrials = 700;
nStim   = 70;
nStep   = 3;

kParam = 1;
% Stimulus Covariates -- this mimics the stimulus for the gabor pulse
% experiment. Smooth across these weights..
covariates(kParam).label = 'pulses';
covariates(kParam).desc  = 'Motion Pulses';
covariates(kParam).X     = round(randn(nTrials, nStim));
covariates(kParam).edim  = size(covariates(kParam).X, 2);
covariates(kParam).prior = 'pairwiseDiff';

kParam = kParam + 1;
% History terms - choice and stimulus. Use a ridge prior for these weights
covariates(kParam).label = 'choiceHistory';
covariates(kParam).desc  = 'Previous Trial Choices';
covariates(kParam).X     = sign(randn(nTrials, nStep));
covariates(kParam).edim  = size(covariates(kParam).X, 2);
covariates(kParam).prior = 'pairwiseDiff';
% History terms - choice and stimulus. Use a ridge prior for these weights
kParam = kParam + 1;
covariates(kParam).label = 'stimHistory';
covariates(kParam).desc  = 'Previous Trial Directions';
covariates(kParam).X     = sign(randn(nTrials, nStep));
covariates(kParam).edim  = size(covariates(kParam).X, 2);
covariates(kParam).prior = 'pairwiseDiff';


% set up filter - this is bull shit right now. Just makes a gaussian over
% all the weights. TODO: make this more plausible
nw = sum([covariates(:).edim]); % number of coeffs in filter
wts = 3*normpdf(1:nw,nw/2,sqrt(nw)/2)';  % linear filter
b = -1; % constant (DC term)

% Make stimuli & simulate response
Xdesign = [covariates(:).X];
xproj = Xdesign*wts+b;
pp = tools.logistic(xproj);
Y = rand(nTrials,1)<pp;

% -- make plot ---
tt = 1:nw;
figure(1); clf
subplot(212);
plot(tt,wts,'k');
title('true filter');
subplot(211);
xpl = min(xproj):.1:max(xproj);
plot(xproj,yy,'.',xpl,tools.logistic(xpl), 'k');
xlabel('input'); ylabel('response');
fprintf('mean rate = %.1f (%d ones)\n', sum(yy)/nTrials, sum(yy));

errfun = @(w)(norm(w-wts).^2);
%% setup prior specs
% prior specs is a struct array of the different types of regularization
% that will be used
clear prspec

prspec = gpriors.getPriorStruct(unique({covariates(:).prior}));
% name the priors
prspec(1).desc = 'pairwise Difference';
prspec(2).desc = 'Ridge gaussian prior';

%% Get regular old maximum likelihood by passing in 0 as the covariance matrix
[wml, wmlerr] = glms.getPosteriorWeights(Xdesign,Y,0, 'bernoulli');

normweights = @(w) norm(wts)*(w/norm(w));
%% get posterior weights for fixed hyperparameters
% get indices for each covariate
prior_inds = tools.count2inds([covariates(:).edim]);
prior_grp  = grp2idx({covariates(:).prior}); % TODO: match to label

hyperParameters = [500];
Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

tic
[wmap, SDebars] = glms.getPosteriorWeights(Xdesign,Y,Cinv, 'bernoulli');
toc

figure(1); clf
plot(1:nw, [wts wml wmap]);
legend({'true', 'ml', 'map'})   
% errorbar(1:numel(wml), norm(wts)*(wml/norm(wml)), norm(wts)*(SDebars/norm(wml)))

% normweights = @(w) norm(wts)*(w/norm(w))



%% build options for fitting
options.ngridpoints = 10;
options.distr  = 'bernoulli';
options.bulk   = false;
options.kfolds = 10; 
options.gridding = 'lhs'; %'uniform'


% get indices for each covariate
prior_inds = tools.count2inds([covariates(:).edim]);
prior_grp  = grp2idx({covariates(:).prior}); % TODO: match to label

hyprange = reshape([prspec(:).hyprsRnge], 2, [])';
hgrid = glms.makeHyperParameterGrid(hyprange, options.ngridpoints, options.gridding);

%% 
% TODO: make these packages relative path
addpath(genpath('~/Dropbox/MatlabCode/download/gpml-matlab-v3.5-2014-12-08/'))
addpath ~/code/gpao/
S = glms.learnHyperParametersActiveLearning(Xdesign,Y,options.distr, prspec, prior_inds, prior_grp, 'maxIter', 10);


%% grid to get best hyperparameters

Sg = glms.hyperparameterGridSearch(Xdesign,Y, options.distr, prspec, prior_inds, prior_grp, 100);

%%
hyperParameters = S.hyprBin;
Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

tic
[wmap, SDebars] = glms.getPosteriorWeights(Xdesign,Y,Cinv, options.distr);
toc

hyperParameters = Sg.hyprBin;
Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

tic
[wmap2, SDebars2] = glms.getPosteriorWeights(Xdesign,Y,Cinv, options.distr);
toc


figure(1); clf
plot(1:numel(wts), [wts wml wmap wmap2]);
legend({'true', 'ml', 'gp', 'grid'})
% errorbar(1:numel(wmap), norm(wts)*(wml/norm(wml)), norm(wts)*(SDebars/norm(wml)));
% errorbar(1:numel(wmap), norm(wts)*(wmap/norm(wmap)), norm(wts)*(SDebars/norm(wmap)));
% errorbar(1:numel(wmap), norm(wts)*(wmap2/norm(wmap2)), norm(wts)*(SDebars/norm(wmap2)));


[errfun(wml) errfun(wmap) errfun(wmap2)]
