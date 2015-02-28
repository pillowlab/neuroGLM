function dm = compileDenseDesignMatrix(dspec, trialIndices)
% Compile information from experiment according to given DesignSpec

expt = dspec.expt;
subIdxs = buildGLM.getGroupIndicesFromDesignSpec(dspec);

trialT = ceil([expt.trial(trialIndices).duration]/expt.binSize);
totalT = sum(trialT);
X      = zeros(totalT, dspec.edim);

trialIndices = trialIndices(:)';

for kTrial = trialIndices
    ndx = sum(trialT(1:kTrial))-(trialT(kTrial)-1):sum(trialT(1:kTrial));
        
    for kCov = 1:numel(dspec.covar) % for each covariate
        covar = dspec.covar(kCov);
        sidx = subIdxs{kCov};
        
        if isfield(covar, 'cond') && ~isempty(covar.cond) && ~covar.cond(expt.trial(kTrial))
            continue;
        end
        
        stim = covar.stim(expt.trial(kTrial), expt); % either dense or sparse
        stim = full(stim);
        
        if isfield(covar, 'basis') && ~isempty(covar.basis)
            X(ndx, sidx) = basisFactory.convBasis(stim, covar.basis, covar.offset);
        else
            X(ndx, sidx) = stim;
        end
    end
end

dm.X = X;
dm.trialIndices = trialIndices;
dm.dspec = dspec;

%% Check sanity of the design
if any(~isfinite(dm.X(:)))
    warning('Design matrix contains NaN or Inf...this is not good!');
end
