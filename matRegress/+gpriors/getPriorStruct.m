function prspec = getPriorStruct(name)
% get default prior structures

import gpriors.*

if ischar(name)
	name = {name};
end

nPriors = numel(name);
% pargs = reshape(varargin, 2, [])';
% nArg = size(pargs, 1);

fields = {'label', 'desc', 'fun', 'dflthyprs', 'hyprsRnge'};
si = [fields(:) cell(numel(fields), 1)]';
prspec = repmat(struct(si{:}), nPriors, 1);

for kPrior = 1:nPriors
    prspec(kPrior) = getPriorDefaults(name{kPrior});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Get Prior Defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prspec = getPriorDefaults(namestr)

    switch namestr
        case 'AR1'
            prspec.label     = namestr;
            prspec.desc      = [];
            prspec.fun       = @gpriors.AR1;
            prspec.dflthyprs = [.1 .1];
            prspec.hyprsRnge = [0 1];
        case 'AR1_2D'
            prspec.label     = namestr;
            prspec.desc      = [];
            prspec.fun       = @gpriors.AR1_2D;
            prspec.dflthyprs = [.1 .1];
            prspec.hyprsRnge = [0 1];
        case {'ridge', 'Ridge', 'Ridge2', 'Ridge3'}
            prspec.label     = namestr;
            prspec.desc      = [];
            prspec.fun       = @gpriors.ridge;
            prspec.dflthyprs = .1;
            prspec.hyprsRnge = [0 1e3];
        case {'pairwiseDiff', 'smooth'}
            prspec.label     = namestr;
            prspec.desc      = [];
            prspec.fun       = @gpriors.pairwiseDiff;
            prspec.dflthyprs = 1;
            prspec.hyprsRnge = [0 3e3];
        case {'pairwiseDiff2D', 'smooth2D', 'pairwiseDiff_2D', 'smooth_2D'}
            prspec.label     = namestr;
            prspec.desc      = [];
            prspec.fun       = @gpriors.pairwiseDiff_2D;
            prspec.dflthyprs = 1;
            prspec.hyprsRnge = [0 3e3];
        case {'none'}
            prspec.label     = 'none';
            prspec.desc      = [];
            prspec.fun       = @gpriors.none;
            prspec.dflthyprs = 0;
            prspec.hyprsRnge = [0 0];
        otherwise
            prspec = [];
    end
