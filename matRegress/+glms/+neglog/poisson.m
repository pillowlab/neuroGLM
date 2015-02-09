function [L,dL,H] = poisson(wts,x,y,fnlin,inds)
% negative log-likelihood of data under Poisson model
% [L,dL,ddL] = neglogli.poisson(wts,X,Y,fnlin,inds)
%
% Compute negative log-likelihood of data under Poisson regression model,
% plus gradient and Hessian
%
% INPUT:
% wts [m x 1] - regression weights
%   X [N x m] - regressors
%   Y [N x 1] - output (binary vector of 1s and 0s).
%       fnlin - func handle for nonlinearity (must return f, df and ddf)
%	 inds - (optional) indices to evaluate on subst of X and Y
%
% OUTPUT:
%   L [1 x 1] - negative log-likelihood
%  dL [m x 1] - gradient
% ddL [m x m] - Hessian

if nargin > 4
    x = x(inds, :);
    y = y(inds);
end

xproj = x*wts;
dL = 0;
H = 0;

switch nargout
    case 1
        f = fnlin(xproj);

	nzidx = f ~= 0;
	if any(y(~nzidx) ~= 0)
	    L = Inf; % if rate is 0, nothing else can happen
	else
	    L = -y(nzidx)'*log(f(nzidx)) + sum(f); % neg log-likelihood
	end
    case 2
        [f,df] = fnlin(xproj); % evaluate nonlinearity

	nzidx = f ~= 0;
	if any(y(~nzidx) ~= 0)
	    L = Inf; % if rate is 0, nothing else can happen
	else
	    L = -y(nzidx)'*log(f(nzidx)) + sum(f); % neg log-likelihood
	end
        
        dL = x(nzidx, :)' * ((1 - y(nzidx)./f(nzidx)) .* df(nzidx));
    case 3
        [f,df,ddf] = fnlin(xproj); % evaluate nonlinearity

	nzidx = f ~= 0;
	if any(y(~nzidx) ~= 0)
	    L = Inf; % if rate is 0, nothing else can happen
	else
	    L = -y(nzidx)'*log(f(nzidx)) + sum(f); % neg log-likelihood
	end

        yf = y(nzidx) ./ f(nzidx);
        dL = x(nzidx, :)' * ((1 - yf) .* df(nzidx));
        %H = bsxfun(@times,ddf.*(1-yf)+df.*(y./f.^2.*df) ,x)'*x;
        H = bsxfun(@times, ddf(nzidx) .* (1-yf) ...
	    + (y(nzidx).*(df(nzidx)./f(nzidx)).^2), x(nzidx, :))' * x(nzidx,:);
end

if isnan(L) || any(isnan(dL)) || any(isnan(H(:)))
    warning('glms:neglog:poisson:nan', 'NaN in negative log-likelihood');
end

L = full(L); dL = full(dL); H = full(H);
