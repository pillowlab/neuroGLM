function S = hyperparameterGridSearch(X,Y,distr, prspec, prior_inds, prior_grp, nGrid, gridType)
% SomeOutput = learnHyperParametersActiveLearning(X,Y,prspec, prior_inds, prior_grp)


domain = reshape([prspec(:).hyprsRnge], 2, [])';
d = size(domain,1);

f = @(h) fitAndPredict(X, Y,distr, prspec, prior_inds, prior_grp, h);

if ~exist('nGrid', 'var')
    nGrid = 10 * d;
end

if ~exist('gridType', 'var')
    gridType = 'lhs';
end

obsX = glms.makeHyperParameterGrid(domain, nGrid, gridType);

obsY = zeros(size(obsX, 1), 1);
for k = 1:size(obsX, 1)
    obsY(k) = f(obsX(k, :));
    fprintf('Function Evaluation: \t%d;  Value %d\n', k, obsY(k))
end

%% report what has been found
[mv, mloc] = min(obsY);
fprintf('Minimum value: %f found at:\n', mv);
disp(obsX(mloc, :));

S.hyprBin = obsX(mloc, :);
S.obsX = obsX;
S.obsY = obsY;


function nll = fitAndPredict(X,Y,distr, prspec,prior_inds, prior_grp, hyperParameters)

    Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

    [~, ~, S] = glms.getPosteriorWeights(X,Y,Cinv, distr, 'CV', 10, 'bulk', true);
    
    nll = mean(S.testLikelihood);
    
