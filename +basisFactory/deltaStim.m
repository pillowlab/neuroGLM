function stim = deltaStim(bt, nT, v)
% Returns a sparse vector with events at binned timings

o = ones(numel(bt), 1);

if nargin < 3
    v = o;
end

assert(numel(o) == numel(v));

stim = sparse(bt, o, v, nT, 1);