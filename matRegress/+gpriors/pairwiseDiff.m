function Cinv = smooth(theta,nx)
% pairwise difference inverse covariance matrix prior 1D
% Cinv = smooth(theta,nx)
%
% Evaluate Gaussian AR1 log-prior at parameter vector prvec.
%
% Inputs:
%  theta [1 x 1] - (smoothness)
%     nx [1 x 1] - length of param vector to apply to prior
%
% Outputs:
%   Cinv [n x n] - inverse covariance matrix

vdiag    = [1;2*ones(nx-2,1);1];
voffdiag = -ones(nx,1);

Cinv = theta*spdiags([voffdiag,vdiag,voffdiag],-1:1,nx,nx);