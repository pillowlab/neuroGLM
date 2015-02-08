function [wts, SDebars, S, funval, H] = getPosteriorWeights(X,Y,Cinv, distr, varargin)
% get posterior weights for generlized linear model with gaussian prior
% [wts, SDebars, funval, H] = getPosteriorWeights(X,Y,Cinv, distr, varargin)


if ~exist('distr', 'var')
    distr = 'poisson';
end


opts = optimoptions(@fminunc, 'Display', 'off', 'Algorithm','trust-region',...
    'GradObj','on','Hessian','on');

argOpts  = {'link', 'CV', 'bulk', 'opts', 'DC'};
dfltOpts = {'canonical', false, false, opts, true};
si = [argOpts; dfltOpts];
options = struct(si{:});
options = parseArgs(options, varargin);

if options.CV > 0
    cvfolds = cvpartition(numel(Y), 'KFold', options.CV);
end

S = struct();

% get posterior function
lfunc = getPosteriorFunctionHandle(distr, options);

if exist('cvfolds', 'var')
    % initialize with least-squares
    w0 = initializeLeastSquares(X,Y,Cinv,cvfolds);
    
    if options.bulk
        fmfunc = @(w) bulkPosterior(w, lfunc, X, Y, Cinv, cvfolds);
        
        % do minimization
        [wts, funval, ~,~,~,H] = fminunc(fmfunc, w0, options.opts);
        SDebars = zeros(size(wts));
        cinds = count2inds(repmat(size(wts,1), cvfolds.NumTestSets,1)');
        testfun = getLikelihoodFunctionHandle(distr, options);
        nll = nan(cvfolds.NumTestSets, 1);
        for kFold = 1:cvfolds.NumTestSets
            SDebars(:,kFold) = sqrt(diag(inv(H(cinds{kFold}, cinds{kFold}))));
            nll(kFold) = testfun(wts(:,kFold), X, Y, cvfolds.test(kFold));
        end
    else
        wts = zeros(size(X,2), cvfolds.NumTestSets);
        SDebars = zeros(size(wts));
        funval = zeros(cvfolds.NumTestSets, 1);
        testfun = getLikelihoodFunctionHandle(distr, options);
        nll = nan(cvfolds.NumTestSets, 1);
        for kFold = 1:cvfolds.NumTestSets
            fmfunc = @(w) lfunc(w, X,Y,Cinv, cvfolds.training(kFold));
            [wts(:,kFold), funval(kFold), ~, ~, ~, H] = fminunc(fmfunc, w0(:,kFold), options.opts);
            SDebars(:,kFold) = sqrt(diag(inv(H)));
            nll(kFold) = testfun(wts(:,kFold), X, Y, cvfolds.test(kFold));
        end
        
        
    end
    
    
else
    fmfunc = @(w) lfunc(w, X,Y,Cinv, 1:numel(Y));
    
    w0 = initializeLeastSquares(X,Y,Cinv);
    % do minimization
    tic
    [wts, funval, ~,~,~,H] = fminunc(fmfunc, w0, options.opts);
    toc
    SDebars = sqrt(diag(inv(H)));
    
    
end

S.funval = funval;
S.H = H;
if exist('nll', 'var')
    S.testLikelihood = nll;
end



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
%       Bulk Neg-Log Posterior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g,h] = bulkPosterior(wts,lfunc,X,Y,Cinv,cvfolds)
f = 0;
g = zeros(size(wts));
h = cell(cvfolds.NumTestSets,1);
for kFold = 1:cvfolds.NumTestSets
    [tf,tg,th] = lfunc(wts(:,kFold), X, Y, Cinv, cvfolds.training(kFold));
    f = f + tf;
    g(:,kFold) = tg;
    h{kFold} = th;
end
h = blkdiag(h{:});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Bernoulli Neg-Log Posterior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g,h] = bernoulliPosterior(wts,X,Y,Cinv,inds)

switch nargout
    case 1
        f = glms.neglog.bernoulli(wts,X,Y,inds);
        fp = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
    case 2
        [f,g] = glms.neglog.bernoulli(wts,X,Y,inds);
        [fp,gp] = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
        g = g + gp;
    case 3
        [f,g, h] = glms.neglog.bernoulli(wts,X,Y,inds);
        [fp,gp, hp] = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
        g = g + gp;
        h = h + hp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Poisson Neg-Log Posterior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g,h] = poissonPosterior(wts,X,Y,Cinv, nlfun, inds)

switch nargout
    case 1
        f = glms.neglog.poisson(wts,X,Y,nlfun, inds);
        fp = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
    case 2
        [f,g] = glms.neglog.poisson(wts,X,Y,nlfun, inds);
        [fp,gp] = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
        g = g + gp;
    case 3
        [f,g, h] = glms.neglog.poisson(wts,X,Y,nlfun, inds);
        [fp,gp, hp] = gpriors.gaussian_zero_mean_inv(wts, Cinv);
        f = f + fp;
        g = g + gp;
        h = h + hp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Posterior Function Handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fun = getPosteriorFunctionHandle(distr, options)
switch distr
    case 'poisson'
        switch options.link
            case {'canonical', 'log', 'exp'}
                nlfun = @nlfuns.exp;
        end
        fun = @(w,X,Y,Cinv,inds) poissonPosterior(w,X,Y,Cinv, nlfun, inds);
        
    case 'bernoulli'
        fun = @(w,X,Y,Cinv,inds) bernoulliPosterior(w,X,Y, Cinv, inds);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Likelihood Function Handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fun = getLikelihoodFunctionHandle(distr, options)
switch distr
    case 'poisson'
        switch options.link
            case {'canonical', 'log', 'exp'}
                nlfun = @nlfuns.exp;
        end
        fun = @(w,X,Y,inds) glms.neglog.poisson(w,X,Y,nlfun, inds);
        
    case 'bernoulli'
        fun = @(w,X,Y,inds) glms.neglog.bernoulli(w,X,Y, inds);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Intialize with Least-squares
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w0 = initializeLeastSquares(X,Y,Cinv,cvfolds)

if ~exist('cvfolds', 'var')
    w0 = (X'*X + Cinv)\(X'*Y);
else
    w0 = zeros(size(X,2),cvfolds.NumTestSets);
    for kk = 1:cvfolds.NumTestSets
        w0(:,kk) = (X(cvfolds.training(kk),:)'*X(cvfolds.training(kk),:) + Cinv)\(X(cvfolds.training(kk),:)'*Y(cvfolds.training(kk)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Counts to indices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inds = count2inds(cnt)
dims = cumsum(cnt);
dcnt = num2cell([0 dims(1:end-1)]);
inds = cellfun(@(x,y) y+(1:x), num2cell(cnt), dcnt, 'uniformoutput', false);