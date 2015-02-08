function [f,df,ddf] = expfun(x)
%  [f,df,ddf] = expfun(x)
%
%  replacement for 'exp' that returns 3 arguments (value, 1st & 2nd deriv)

f = exp(x);
df = f;
ddf = df;
