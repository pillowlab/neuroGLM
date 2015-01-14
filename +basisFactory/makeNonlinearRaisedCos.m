function bases = makeNonlinearRaisedCos(nBases, binSize, endPoints, nlOffset)
% Make nonlinearly stretched basis consisting of raised cosines.
% Nonlinear stretching allows faster changes near the event.
%
% 	nBases: [1] - # of basis vectors
%	binSize: time bin size (separation for representing basis
%   endPoints: [2 x 1] = 2-vector containg [1st_peak  last_peak], the peak
%          (i.e. center) of the last raised cosine basis vectors
%   nlOffset: [1] offset for nonlinear stretching of x axis:  y = log(t+nlOffset)
%         (larger nlOffset -> more nearly linear stretching)
%
%  Outputs:  iht = time lattice on which basis is defined
%            ihbasis = basis itself
%            ihctrs  = centers of each basis function
%
%  Example call
%  bases = basisFactory.makeNonlinearRaisedCos(10, 1, [0 500], 2);

% nonlinearity for stretching x axis (and its inverse)
nlin = @(x)(log(x + 1e-20));
invnl = @(x)(exp(x) - 1e-20);

if nlOffset <= 0
    error('nlOffset must be greater than 0');
end

yrnge = nlin(endPoints + nlOffset);
db = diff(yrnge) / (nBases-1); % spacing between raised cosine peaks
ctrs = yrnge(1):db:yrnge(2); % centers for basis vectors
mxt = invnl(yrnge(2)+2*db) - nlOffset; % maximum time bin
iht = (0:binSize:mxt)';
ff = @(x,c,dc) (cos(max(-pi, min(pi, (x-c)*pi/dc/2))) + 1)/2;
ihbasis = ff(repmat(nlin(iht + nlOffset), 1, nBases), repmat(ctrs, numel(iht), 1), db);
ihctrs = invnl(ctrs);

bases.type = mfilename;
bases.param.nBases = nBases;
bases.param.binSize = binSize;
bases.param.endPoints = endPoints;
bases.param.nlOffset = nlOffset;
bases.B = ihbasis;
bases.edim = size(bases.B, 2);
bases.tr = iht;
bases.centers = ihctrs;