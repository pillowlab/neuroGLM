function [f,df,ddf] = logexp2(x);
%  [f,df,ddf] = logexp_pow(x);
%
%  Implements the nonlinearity:  
%     f(x) = log(1+exp(x)).^pow;
%  where pow=2,
%  plus first and second derivatives

pow = 2;
f0 = log(1+exp(x));
f = f0.^pow;

if nargout > 1
    df = pow*f0.^(pow-1).*exp(x)./(1+exp(x));
end
if nargout > 2
    ddf = pow*f0.^(pow-1).*exp(x)./(1+exp(x)).^2 + ...
          pow*(pow-1)*f0.^(pow-2).*(exp(x)./(1+exp(x))).^2;
end
