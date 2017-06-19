function [f,df,ddf] = logexp3(x);
%  [f,df,ddf] = logexp3(x);
%
%  Implements the nonlinearity:  
%     f(x) = log(1+exp(x)).^3;
%  plus first and second derivatives


f0 = log(1+exp(x));
f = f0.^3;

if nargout > 1
    df = 3*f0.^2.*exp(x)./(1+exp(x));
end
if nargout > 2
    ddf = 6*f0.*(exp(x)./(1+exp(x))).^2 + ...
    3*f0.^2.*exp(x)./(1+exp(x)).^2;
end
