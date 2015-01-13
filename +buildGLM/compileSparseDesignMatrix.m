function dm = compileSparseDesignMatrix(dspec, trialIndices)
% Compile information from experiment according to given DesignSpec

expt = dspec.expt;

nCov = numel(dspec.covar);

subIdxs = buildGLM.getGroupIndicesFromDesignSpec(dspec);

totalT = sum(ceil([expt.trial(trialIndices).duration]/expt.binSize));

growingX = sparse([], [], [], 0, dspec.edim, round(totalT * dspec.edim * 0.001)); % preallocate

trialIndices = trialIndices(:)';

for kTrial = trialIndices
    nT = ceil(expt.trial(kTrial).duration / expt.binSize); % TODO move?
    
    miniX = zeros(nT, dspec.edim); % pre-allocate a dense matrix for each trial
    
    for kCov = 1:nCov % for each covariate
        covar = dspec.covar(kCov);
        sidx = subIdxs{kCov};
        
        % Continuous-type data
        if covar.isContinuous
            miniX(:, sidx) = covar.value(expt.trial(kTrial));
            continue;
        end
        
        % Timing-type or spike-train-type data
        if ~isfield(covar, 'cond') || covar.cond(kTrial)
            miniX(:, sidx) = covar.basisHandle(expt.trial(kTrial), nT);
            if ~isfield(covar, 'value')
                miniX(:, sidx) = ...
                    bsxfun(@times, miniX(:, sidx), covar.value(kTrial));
            end
        end
    end
    growingX = [growingX; sparse(miniX)];
end

dm.X = growingX;
dm.trialIndices = trialIndices;
dm.dspec = dspec;
dm.type = 'sparse';