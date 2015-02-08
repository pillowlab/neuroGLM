function p = logistic(x)
% p = logistic(x)
%
% Compute logistic ("inverse logit") function:
% p = exp(x)./(1+exp(x));
%
% Input: x \in Reals
% Output: p \in (0,1)

p = exp(x)./(1+exp(x));
p(isnan(p)) = 1;
p(isinf(x) & x < 0) = 0;
