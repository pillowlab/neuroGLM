function S = learnHyperParametersActiveLearning(X,Y,distr, prspec, prior_inds, prior_grp, varargin)
% SomeOutput = learnHyperParametersActiveLearning(X,Y,prspec, prior_inds, prior_grp)
import gpao.*

argOpts  = {'link',     'CV',   'bulk',     'DC',   'maxIter'};
dfltOpts = {'canonical', false,  false,     true,   50};
si = [argOpts; dfltOpts];
options = struct(si{:});
options = parseArgs(options, varargin);

domain = reshape([prspec(:).hyprsRnge], 2, [])';
d = size(domain,1);

f = @(h) fitAndPredict(X, Y,distr, prspec, prior_inds, prior_grp, h);
%% sample a few samples from the Latin Hypercube design
nInit = 7 * d;
% obsX = lhsdesign(d, nInit)';

obsX = glms.makeHyperParameterGrid(domain, nInit, 'lhs');

obsY = zeros(size(obsX, 1), 1);
for k = 1:size(obsX, 1)
    obsY(k) = f(obsX(k, :));
end

%% initialize the prior
gps = gpao.covarianceKernelFactory(1, d);

%% do a litle active learning dance
for k = 1:options.maxIter
    % ask where to sample next (choose your favorite algorithm)
    %nextX = aoMockus(domain, obsX, obsY, gps);
    nextX = gpao.aoKushner(domain, obsX, obsY, gps);

    % evaluate at the suggested point
    nextY = f(nextX);

    % save the measurement pair
    obsX = [obsX; nextX];
    obsY = [obsY; nextY];
end

%% report what has been found
[mv, mloc] = min(obsY);
fprintf('Minimum value: %f found at:\n', mv);
disp(obsX(mloc, :));

S.hyprBin = obsX(mloc, :);
S.obsX = obsX;
S.obsY = obsY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Parse Arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function options = parseArgs(options, args)

if isempty(args) || numel(args)<2
    return
end
argPairs = reshape(args, 2, [])';
for kArg = 1:size(argPairs,1)
    if isfield(options, argPairs{kArg,1})
        options.(argPairs{kArg,1}) = argPairs{kArg,2};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Fit and Predict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nll = fitAndPredict(X,Y,distr, prspec,prior_inds, prior_grp, hyperParameters)

    Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

    [~, ~, S] = glms.getPosteriorWeights(X,Y,Cinv, distr, 'CV', 10, 'bulk', true);
    
    nll = mean(S.testLikelihood);
    
