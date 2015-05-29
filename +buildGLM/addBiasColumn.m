function dm = addBiasColumn(dm, flag)
% Add a column of ones as the first (or last) column to estimate the bias 
% (DC term)
% dm = addBiasColumn(dm);
%
% Some regression packages do not allow separate bias estimation, and
% a constant column of ones must be added to the design matrix. The weight
% that corresponds to this column will be the bias later.
%
% To put the bias column on the right of the design matrix, call:
% dm = addBiasColumn(dm, 'right')

if nargout ~= 1
    error('Must assign output back to a design matrix!');
end

if isfield(dm, 'biasCol')
    warning('This design matrix already has a bias column! Skipping...');
    return
end

if nargin < 2
    flag = 'left'; % bias column defaults to the left of the design matrix
end

switch flag
    case 'left'
        dm.X = [ones(size(dm.X, 1), 1), dm.X];
        dm.biasCol = 1; % indicating that the first column is the bias column
    case 'right'
        n = dm.dspec.edim+1;
        dm.X = [dm.X, ones(size(dm.X, 1), 1)];
        dm.biasCol = n; % indicating that the last column is the bias column
end
        
