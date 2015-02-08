function dm = addBiasColumn(dm)
% Add a column of ones as the first column to estimate the bias (DC term)
% dm = addBiasColumn(dm);
%
% Some regression packages do not allow separate bias estimation, and
% a constant column of ones must be added to the design matrix. The weight
% that corresponds to this column will be the bias later.

if nargout ~= 1
    error('Must assign output back to a design matrix!');
end

if isfield(dm, 'biasCol')
    warning('This design matrix already has a bias column! Skipping...');
    return
end

dm.X = [ones(size(dm.X, 1), 1), dm.X];
dm.biasCol = 1; % indicating that the first column is the bias column
