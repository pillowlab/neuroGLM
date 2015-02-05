function dm = removeConstantCols(dm)
% Remove columns with constant values (redandunt with the bias term)
% dm = removeConstantCols(dm);
%
% If you want to also z-score, do it after removing constant columns

if isfield(dm, 'constCols')
    warning('This design matrix has already been cleared');
end

if nargout ~= 1
    error('Must assign output back to a design matrix!');
end

if isfield(dm, 'zscore')
    error('Please zscore after removing constant columns');
end

v = var(dm.X);

dm.constCols = v == 0;
dm.X = dm.X(:, ~dm.constCols);
