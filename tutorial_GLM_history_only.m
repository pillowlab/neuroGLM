%% Simulate a simple GLM with history filter (no other covariates)
unitOfTime = 'ms';
binSize = 1; % 1 ms
T = 100000; % number of time bins
rateBias = log(22/1000); % 22 Hz

% make some history filter
w = fliplr([0.01 0.03 0.1 0.2 0.35 0.3 0.1 0 -0.05 -0.1 -0.2 -0.3 -0.5 -0.6 -1 -3 -3.5 -4 -4 -4 -6]);
nHistBins = numel(w);
y = zeros(T + nHistBins, 1);

for t = (nHistBins+1):(T+nHistBins)
    yy = poissrnd(exp(w * y(t - (1:nHistBins)) + rateBias));
    if yy ~= 0
	y(t) = 1;
    end
end

y = y(nHistBins+1:end);
st = find(y);

fprintf('Mean rate: %f Hz\n', mean(y) * 1e3);
figure(933); clf
hist(diff(st), 0:201); xlim([0 200]);
title('Interspike-interval (ISI) distribution');

%% Fit a model
expt = buildGLM.initExperiment(unitOfTime, binSize);
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'simulated neuron');

%% There's just onen trial
expt.trial(1).sptrain = st;
expt.trial(1).duration = T;

dspec = buildGLM.initDesignSpec(expt);
%dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
bs = basisFactory.makeSmoothTemporalBasis('boxcar', 24, 12, expt.binfun);
dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter', bs);

dm = buildGLM.compileSparseDesignMatrix(dspec, 1);
dm = buildGLM.addBiasColumn(dm);

%% Do the regression
addpath('matRegress')

wInit = dm.X \ y;
fnlin = @nlfuns.exp; % inverse link function (a.k.a. nonlinearity)
lfunc = @(w)(glms.neglog.poisson(w, dm.X, y, fnlin)); % cost/loss function

opts = optimoptions(@fminunc, 'Algorithm', 'trust-region', ...
    'GradObj', 'on', 'Hessian','on');

[wML, nlogli, exitflag, ostruct, grad, hessian] = fminunc(lfunc, wInit, opts);
wvar = diag(inv(hessian));

ws = buildGLM.combineWeights(dm, wML);

%% Plot results
figure(140242); clf; hold all;
plot(w);
plot(ws.hist.data)
title('History filter');
legend('true', 'estimated', 'Location', 'SouthEast');
xlabel(['Time (' unitOfTime ')']);
