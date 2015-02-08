function [L,dL,H] = poisson(wts,x,y,fnlin, inds)
% negative log-likelihood of data under Poisson model
% [L,dL,ddL] = neglogli.poisson(wts,X,Y)
%
% Compute negative log-likelihood of data under Poisson regression model,
% plus gradient and Hessian
%
% INPUT:
% wts [m x 1] - regression weights
%   X [N x m] - regressors
%   Y [N x 1] - output (binary vector of 1s and 0s).
%       fnlin - func handle for nonlinearity (must return f, df and ddf)
%
% OUTPUT:
%   L [1 x 1] - negative log-likelihood
%  dL [m x 1] - gradient
% ddL [m x m] - Hessian
if nargin < 5
    inds = 1:numel(y);
end

xproj = x(inds,:)*wts;

switch nargout
    case 1
        f = fnlin(xproj);
        L = -y(inds)'*log(f) + sum(f); % neg log-likelihood
        L = full(L);
    case 2
        [f,df] = fnlin(xproj); % evaluate nonlinearity
        
        L = -y(inds)'*log(f) + sum(f); % neg log-likelihood
        L = full(L);
        dL = x(inds,:)'*((1 - y(inds)./f) .* df);
        dL = full(dL);
    case 3
        [f,df,ddf] = fnlin(xproj); % evaluate nonlinearity
        
        L = -y(inds)'*log(f) + sum(f); % neg log-likelihood
        yf = y(inds)./f;
        dL = x(inds,:)'*((1 - yf) .* df);
        H = bsxfun(@times,ddf.*(1-yf)+df.*(y(inds)./f.^2.*df) ,x(inds,:))'*x(inds,:);
        L = full(L);
        dL = full(dL);
        H = full(H);
end