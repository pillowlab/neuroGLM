function Cinv = AR1_2D(theta,nyx)
% Gaussian 2D AR1 inverse covariance matrix
% Cinv = AR1_2D(theta,nyx)
%
% Evaluate Gaussian AR1 log-prior at parameter vector prvec, which has the
% shape of a matrix of size nyx. 
%
% Inputs:
%  theta [2 x 1] - hyperparams: [rho; (precision); alpha (smoothness)]
%    nyx [2 x 1] - size of image: [ny, nx]
%
% Outputs:
%   Cinv [n x n] - inverse covariance matrix
%
% Inverse prior covariance matrix given by:
%  C^-1 = rho/(1-a^2) [ 1 -a
%                      -a 1+a^2 -a                       
%                        .   .   .
%                          -a 1+a^2 -a

MINVAL = 1e-6;

nim = prod(nyx);

rho = max(theta(1),MINVAL);
aa = min(theta(2),1-MINVAL);

% Column AR1 covariance 
vdiag = [1;ones(nyx(1)-2,1)+aa^2;1];
voffdiag = -ones(nyx(1),1)*aa;
Cinv1 = -spdiags([voffdiag,vdiag,voffdiag],-1:1,nyx(1),nyx(1));

% Row AR1 covariance
vdiag = [1;ones(nyx(2)-2,1)+aa^2;1];
voffdiag = -ones(nyx(2),1)*aa;
Cinv2 = -spdiags([voffdiag,vdiag,voffdiag],-1:1,nyx(2),nyx(2));

% Full inverse covariance matrix on linear weights
Cinv = -kron(Cinv2,Cinv1)*(rho/(1-aa^2)^2);