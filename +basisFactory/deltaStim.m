function stim = deltaStim(bt, nT, v)
% Returns a sparse vector with events at binned timings

bidx = bt <= nT;
bt = bt(bidx); % ignore the events after nT bins

o = ones(numel(bt), 1);

if nargin < 3
    v = o;
else
    v = v(bidx);
end

assert(numel(o) == numel(v));

stim = sparse(bt, o, v, nT, 1);