trialIndices = 2:10;

totalT = sum(ceil(expt.binfun([expt.trial(trialIndices).duration])));

dspec = struct();
dspec.expt = expt;

dspec.covar(1).isContinuous = false;
dspec.covar(1).basisHandle = @(trial, nT) rand(nT, 2);
dspec.covar(1).edim = 2;

dspec.covar(2).isContinuous = true;
dspec.covar(2).value = @(trial) trial.LFP;
dspec.covar(2).edim = 1;

dspec.covar(3).isContinuous = false;
dspec.covar(3).basisHandle = @(trial, nT) [zeros(expt.binfun(trial.dotson), 2); [1 1]; zeros(nT - expt.binfun(trial.dotson) - 1,2)];
dspec.covar(3).edim = 2;


dspec.edim = sum([dspec.covar(:).edim]);

dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

imagesc(dm.X);