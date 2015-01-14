function dspec = addCovariateRaw(dspec, covLabel, desc, varargin)

if nargin < 3; desc = covLabel; end

% assert(ischar(desc), 'Description must be a string');

dspec = buildGLM.addCovariate(dspec, covLabel, desc, basisFactory.rawStim(covLabel), varargin{:});