function [f,df,ddf] = logexp5(x);
%  [f,df,ddf] = logexp4(x);
%
%  Implements the nonlinearity:  
%     f(x) = log(1+exp(x)).^4;
%  plus first and second derivatives
%
%  General formulas:
%  f(x) = log(1+exp(x))^k
%  f'(x) = k log(1+e^x)^(k-1) * e^x/(1+e^x);
%  f"(x) = k(k-1) log(1+e^x)^(k-2) * (e^x/(1+e^x))^2
%             + k log(1+e^x)^(k-1) * e^x/(1+e^x)^2

f0 = log(1+exp(x));
f = f0.^5;

if nargout > 1
    df = 5*f0.^4.*exp(x)./(1+exp(x));
end
if nargout > 2
    ddf = 20*f0.^3.*(exp(x)./(1+exp(x))).^2 + ...
    5*f0.^4.*exp(x)./(1+exp(x)).^2;
end
