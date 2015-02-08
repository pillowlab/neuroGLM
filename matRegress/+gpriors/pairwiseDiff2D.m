function Cinv = smooth2D(theta, nyx)
% create Matrix for sum of squared differences operations 2D
% Cinv = smooth2D(theta, nyx)
% create Matrix for sum of squared differences operations
% L is a vector of hyper parameters
% L is [smooth_time smooth_space sparsity];
% can be repeated for full analysis 

ny = nyx(1); nx = nyx(2);

% for rows
firstrow = [-1 1, zeros(1,ny-2)];
firstcol = [-1; zeros(ny-2,1)];

D = toeplitz(firstcol, firstrow);
M = D'*D;
M = sparse(M);

Mcell = repmat({M},nx,1);
M2    = blkdiag(Mcell{:});

% for columns
firstrow = [-1 1, zeros(1,nx-2)];
firstcol = [-1; zeros(nx-2,1)];

D = toeplitz(firstcol,firstrow);
N = D'*D;  % pairwise diffs for one column
N = sparse(N);

Ncell = repmat({N},ny,1);
N2 = blkdiag(Ncell{:}); 

% reshape columns 
I = reshape(1:nx*ny, ny,nx);
Ire = I';

N3 = zeros(nx*ny);
N3(Ire,Ire) = N2;

Cinv = theta(1).*M2 + theta(2).*N3;