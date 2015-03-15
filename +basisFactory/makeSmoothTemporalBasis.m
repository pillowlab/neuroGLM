function bases = makeSmoothTemporalBasis(shape, duration, nBases, binfun, varargin)
% bases = makeSmoothTemporalBasis(shape, duration, nBases, binfun, varargin)
%
% Input
%   shape: 'raised cosine' or 'boxcar'
%   duration: the time that needs to be covered
%   nBases: number of basis vectors to fill the duration
%   binfun:
%
%   Optional Arguments (entered as argument pairs)
%       'Normalize' (default = false) normalizes basis vectors to sum to 1
%       'Orthogonalize' (default = false) orthogonalizes the basis so B'*B=1
%
% Output
%   bases: bases structure

p = inputParser();
p.addOptional('Normalize', false);
p.addOptional('Orthogonalize', false);
p.parse(varargin{:});

nkbins = binfun(duration); % number of bins for the basis functions

ttb = repmat((1:nkbins)', 1, nBases); % time indices for basis

switch shape
    case 'raised cosine'
        %   ^
        %  / \
        % /   \______
        %      ^
        %     / \
        % ___/   \___
        %         ^
        %        / \
        % ______/   \
        % For raised cosine, the spacing between the centers must be 1/4 of the
        % width of the cosine
        dbcenter = nkbins / (3 + nBases); % spacing between bumps
        width = 4 * dbcenter; % width of each bump
        bcenters = 2 * dbcenter + dbcenter*(0:nBases-1);
        % location of each bump centers
        bfun = @(x,period)((abs(x/period)<0.5).*(cos(x*2*pi/period)*.5+.5));
        BBstm = bfun(ttb-repmat(bcenters,nkbins,1), width);
    case 'boxcar'
        width = nkbins / nBases;
        BBstm = zeros(size(ttb));
        bcenters = width * (1:nBases) - width/2;
        for k = 1:nBases
            idx = ttb(:, k) > ceil(width * (k-1)) & ttb(:, k) <= ceil(width * k);
            BBstm(idx, k) = 1 / sum(idx);
        end
    otherwise
        error('Unknown basis shape');
end

if p.Results.Normalize
    BBstm = bsxfun(@rdivide, BBstm, sum(BBstm));
end

if p.Results.Orthogonalize
    BBstm = orth(BBstm);
end

bases.type = [shape '@' mfilename];
bases.param.varargin = varargin;
bases.param.shape = shape;
bases.param.duration = duration;
bases.param.nBases = nBases;
bases.param.binfun = binfun;
bases.B = BBstm;
bases.edim = size(bases.B, 2);
bases.tr = ttb - 1;
bases.centers = bcenters;
