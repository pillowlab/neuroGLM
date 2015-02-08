function Cinv = AR1(theta,nx)
% AR1 prior inverse covariance
% Cinv = AR1(theta,nx)
%
% Evaluate Gaussian AR1 log-prior at parameter vector prvec.
%
% Inputs:
%  theta [2 x 1] - [rho; (precision)
%                   alpha (smoothness) ]
%     nx [1 x 1] - length of param vector to apply to prior (last element
%                  of prvec can be all-ones for dc term
%
% Outputs:
%   Cinv [n x n] - inverse covariance matrix
%
% Inverse prior covariance matrix given by:
%  C^-1 = rho/(1-a^2) [ 1 -a
%                      -a 1+a^2 -a                       
%                        .   .   .
%                          -a 1+a^2 -a
%                                -a  1 ]
%

MINVAL = 1e-6;

rho = max(theta(1),MINVAL);
aa = min(theta(2),1-MINVAL);
const = rho/(1-aa.^2);

vdiag = [1;ones(nx-2,1)+aa^2;1]*const;
voffdiag = -ones(nx,1)*aa*const;
Cinv = -spdiags([voffdiag,vdiag,voffdiag],-1:1,nx,nx);
