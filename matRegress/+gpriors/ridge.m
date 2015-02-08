function Cinv = ridge(rho, nx)
% ridge inverse covariance matrix
% Cinv = ridge(rho, nx)

Cinv = speye(nx)*rho;