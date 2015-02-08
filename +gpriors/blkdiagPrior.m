function Cinv = blkdiagPrior(prvec, priors, thetas, inds, rhoDC)
% make block diagonal prior inverse covariance matrix
% Cinv = blkdiagPrior(prvec, priors, thetas, inds, rhoDC)
%
% Make a block diagonal prior inverse covariance matrix to regularize
% different sets of parameters separately
%
% Inputs:
%   prvec  = [m x 1] weight vector
%   priors = [k x 1] cell array of priors (eg. {@gpriors.AR1, @gpriors.ridge})
%   thetas = [k x 1] cell array of hyper parameters (eg. {[10 .99], 10})
%   inds   = [k x 1] cell array of parameter indices for each prior (eg. {1:10, 15:20})
%   rhoDC  = [1 x 1] prior precision for the DC term (eg. .1)
%
% Outputs:
%   Cinv [m x m] - inverse covariance matrix
%
% example: 
% Cinv = gpriors.blkdiagPrior(wts, {@gpriors.ridge, @gpriors.ridge}, {10, 10}, {1:floor(numel(wts)/2), ceil(numel(wts)/2):numel(wts)-1}, 0)


if nargin < 5
    DCflag = false;
else
    DCflag = true;
end

nprs = length(prvec);

if ~iscell(inds)
    inds = {inds};
end

%% make block diagonal prior inverse covariance

blkCtr = 1;
C = cell(1);
ni  = numel(inds);


if inds{1}(1) ~= 1
        blkCtr = blkCtr + 1;
        C{blkCtr} = zeros(inds{1}(1)-1);
end


for ii = 1:ni
    
    nim = numel(inds{ii});
    
    C{blkCtr} = priors{ii}(thetas{ii}, nim);
    
    
    if ii < ni && ( (inds{ii+1}(1) - inds{ii}(end)) > 1)
        blkCtr = blkCtr + 1;
        C{blkCtr} = zeros(inds{ii+1}(1)-inds{ii}(end));
    end
    
    if ii == ni
        blkCtr = blkCtr + 1;
        C{blkCtr} = zeros(nprs-inds{ii}(end));
    end
    
    blkCtr = blkCtr + 1;
end

Cinv = blkdiag(C{:});

if DCflag
    Cinv(nprs,nprs) = rhoDC;
end

Cinv = Cinv(1:nprs, 1:nprs);