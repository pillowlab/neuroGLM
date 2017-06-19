function [f, df, ddf] = threshLinear(x)
% Threshold linear, nonlinearity
% For numerical stability, the smallest value it returns is eps, not zero.
%
%                 /
%               /
%             /
% -----------'
%
% Consider using scaledNlfun with logexp1 instead (it's smoother)

f = zeros(size(x));
f(x > 0) = x(x > 0);
f(x <= 0) = eps;

if nargout > 1
    df = zeros(size(x));
    df(x > 0) = 1;
    df(x == 0) = 0.2; % subgradient
end

if nargout > 2
    ddf = zeros(size(x));
end
