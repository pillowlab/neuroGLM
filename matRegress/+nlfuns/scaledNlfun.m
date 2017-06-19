function [f, df, ddf] = scaledNlfun(x, fhandle, scale)
% [f, df, ddf] = scaledNlfun(x, fhandle, scale)
% Scale a nonlinear function so that its operating point is shifted.
%
% Evaluates: fhandle(x*scale) / scale
%
% For example, to make log(1+exp(x)) more linear, use scale of 1e3

if nargout > 2
    [f, df, ddf] = fhandle(x * scale);
    f = f / scale;
    df = df;
    ddf = ddf * scale;
elseif nargout > 1
    [f, df] = fhandle(x * scale);
    f = f / scale;
    df = df;
else
    [f] = fhandle(x * scale);
    f = f / scale;
end
