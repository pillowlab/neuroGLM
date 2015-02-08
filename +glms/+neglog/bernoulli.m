function [L,dL,ddL] = bernoulli(wts,X,Y, indices)
% [L,dL,ddL] = bernoulli(wts,X,Y)
%
% Compute negative log-likelihood of data under logistic regression model,
% plus gradient and Hessian
%
% Inputs:
% wts [m x 1] - regression weights
%   X [N x m] - regressors
%   Y [N x 1] - output (binary vector of 1s and 0s).

if nargin < 4
    indices = 1:numel(Y);
end

xproj = X(indices,:)*wts;

if nargout <= 1
    L = -Y(indices)'*xproj + sum(softrect(xproj)); % neg log-likelihood

elseif nargout == 2
    [f,df] = softrect(xproj); % evaluate log-normalizer
    L = -Y(indices)'*xproj + sum(f); % neg log-likelihood
    dL = X(indices,:)'*(df-Y(indices));         % gradient

elseif nargout == 3
    [f,df,ddf] = softrect(xproj); % evaluate log-normalizer
    L = -Y(indices)'*xproj + sum(f); % neg log-likelihood
    dL = X(indices,:)'*(df-Y(indices));         % gradient
    ddL = X(indices,:)'*bsxfun(@times,X(indices,:),ddf); % Hessian
end

% -------------------------------------------------------------
% ----- SoftRect Function (log-normalizer) --------------------
% -------------------------------------------------------------

function [f,df,ddf] = softrect(x)
%  [f,df,ddf] = softrect(x);
%
%  Computes: f(x) = log(1+exp(x))
%  and first and second derivatives

f = log(1+exp(x));

if nargout > 1
    df = exp(x)./(1+exp(x));
end
if nargout > 2
    ddf = exp(x)./(1+exp(x)).^2;
end

% Check for small values
if any(x(:)<-20)
    iix = (x(:)<-20);
    f(iix) = exp(x(iix));
    df(iix) = f(iix);
    ddf(iix) = f(iix);
end

% Check for large values
if any(x(:)>500)
    iix = (x(:)>500);
    f(iix) = x(iix);
    df(iix) = 1;
    ddf(iix) = 0;
end
