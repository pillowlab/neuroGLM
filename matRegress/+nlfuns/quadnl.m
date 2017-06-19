function [f,df,ddf] = quadnl(x);
%  [f,df,ddf] = quadnl(x);
%
%  Implements the nonlinearity:  
%     f(x) = 1+x.^2;
%  Where pow = 1;
%  plus first and second derivatives

f = 1+x.^2;
df = 2.*x;
ddf = 2;
