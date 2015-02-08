function [p, dp, negCinv] = gaussian_zero_mean_inv(w, Cinv)
% Evaluate negative log gaussian prior with mean zero and covariance Cinv
% [p, dp, negCinv] = gaussian_zero_mean_inv(w, Cinv)
%
% Evaluate a Gaussian negative log-prior at parameter vector w.
%
% Inputs:
%   prvec [n x 1] - parameter vector (last element can be DC)
%       C [m x m] - gaussian inverse covariance
%
% Outputs:
%       p [1 x 1] - log-prior
%      dp [n x 1] - grad
% negCinv [n x n] - negative inverse covariance matrix (Hessian)
%

% check for included DC term
if numel(w) == size(Cinv,1) + 1
    w = w(1:end-1);
end

dp = Cinv*w;
p  = w'*dp/2;

if nargout > 2
    negCinv = Cinv;
end
