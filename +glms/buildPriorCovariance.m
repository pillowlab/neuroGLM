function Cinv = buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters)
% Use prior spec to build a covariance matrix
%
% Cinv = buildPriorCovariance(prSpec, prInds, prGrp)
% prSpec is a prior "object" (it's a struct array)
% prSpec
% 		.label     - name of this prior (eg. 'Ridge1')
%		.fun   	   - function to generate the prior covariance (eg. @ridge)
% 		.dflthyprs - default hyperparameters (eg. .1)
% 		.nhyprs    - number of hyperparameters required
% 		.isInv     - boolean 
% prInds - cell-array
% prGrp  - which prior to use for each of prInds		

if nargin > 4
    hyperParameters = [prspec(:).dflthyprs];
end

import gpriors.*
import tools.*
% number of hyperparameters per prior
nhyprsper = cellfun(@(x) numel(x), {prspec(:).dflthyprs});

prior_grp = grp2idx(prior_grp);

assert(numel(hyperParameters) == sum(nhyprsper), 'number of hyperparameters must equal the number required')
hyprprinds = tools.count2inds(nhyprsper);

C = cell(numel(prior_grp),1);
for kParam = 1:numel(prior_grp)
    C{kParam} = prspec(prior_grp(kParam)).fun(hyperParameters(hyprprinds{prior_grp(kParam)}), numel(prior_inds{kParam}));
end

Cinv = blkdiag(C{:});