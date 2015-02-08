function [wmaps model] = cvglm(mstruct, folds, gridparams, w0)
% cross-validate GLM
% model = cvglm(mstruct, folds, gridparams)
% INPUTS
%       mstruct - model structure with fields
%        .neglogli - func handle for negative log-likelihood
%        .neglogpr - func handle for negative log-prior 
%        .liargs   - cell array with args to neg log-likelihood
%        .priargs  - cell array with args to log-prior function

if nargin < 4
    w0 = (mstruct.liargs{1}'*mstruct.liargs{1})\(mstruct.liargs{1}'*mstruct.liargs{2});
end

opts = optimoptions(@fminunc,'Algorithm','trust-region',...
    'GradObj','on','Hessian','on', 'Display', 'off');

n = numel(gridparams);
switch n
    case 1
        paramgrid = gridparams{1}(:);
    case 2
        [a, b] = ndgrid(gridparams{:});
        paramgrid = [a(:) b(:)];
    case 3
        [a, b, c] = ndgrid(gridparams{:});
        paramgrid = [a(:) b(:) c(:)];
    case 4
        [a, b, c, d] = ndgrid(gridparams{:});
        paramgrid = [a(:) b(:) c(:) d(:)];
end

nFolds = size(folds, 1);
nParamGrid = size(paramgrid,1);
tnll  = nan(nFolds, nParamGrid);
wmaps = nan(size(mstruct.liargs{1},2), nParamGrid, nFolds);

fprintf('prepare for %d fold cross validation with %d hyperparameters\n', nFolds, nParamGrid)
for kFold  = 1:nFolds
    
    % get indices
    train  = folds{kFold,1};
    test   = folds{kFold,2};
    
    % this is a memory inefficient way to do it... make a whole new struct
    foldm = struct();
    foldm.neglogli = mstruct.neglogli;
    foldm.neglogpr = mstruct.neglogpr;
    ninpt = numel(mstruct.liargs);
    foldm.liargs = cell(1, ninpt);
    
    for ii = 1:ninpt
        if isa(mstruct.liargs{ii}, 'function_handle')
            foldm.liargs{ii} = mstruct.liargs{ii};
        else
            foldm.liargs{ii} = mstruct.liargs{ii}(train,:);
        end
    end
        
    for kParam = 1:nParamGrid

        params = paramgrid(kParam,:);
        Cinv = gpriors.blkdiagPrior(w0, mstruct.priors, num2cell(params, 1), mstruct.indices);
        foldm.priargs = {Cinv};
        
        lfpost = @(w)(neglogprior.posterior(w,foldm)); % posterior
        
        tic;
        [wmap,nlogpost,~,~,~,H] = fminunc(lfpost,w0*.1,opts);
        toc
        
        testNegLogLikelihood = @(w) mstruct.neglogli(wmap, mstruct.liargs{1}(test,:), mstruct.liargs{2}(test), mstruct.liargs{3});
        
        tnll(kFold, kParam) = testNegLogLikelihood(wmap);
        
        wmaps(:, kParam, kFold) = wmap;
        
    end
end

[~, id] = min(tnll,[],2);

wtsMax = [];
for ii = 1:size(folds, 1)
    wtsMax = [wtsMax wmaps(:,id(ii),ii)];
end

model.paramgrid = paramgrid;
model.tnll = tnll;
model.foldMaxParams = paramgrid(id,:);
model.foldMaxWts = wtsMax;
