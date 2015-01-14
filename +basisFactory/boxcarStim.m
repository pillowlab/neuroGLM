function stim = boxcarStim(startBinnedTime, endBinnedTime, nT)
% Returns a boxcar duration stimulus design

idx = startBinnedTime:endBinnedTime;
o = ones(numel(idx), 1);

stim = sparse(idx, o, o, nT, 1);