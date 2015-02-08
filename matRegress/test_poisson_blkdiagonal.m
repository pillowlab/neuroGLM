% set up filter
nw = 400;
wts = 2*normpdf(1:nw,nw/2,3)';
fnlin = @nlfuns.exp;
tt = 1:nw;
clf;
plot(tt,wts,'k');
errfun = @(w)(norm(w-wts).^2);  % error function handle

% Make stimuli & simulate response
nstim = 1400;
stim = 1*(randn(nstim,nw));
xproj = stim*wts;
pp = fnlin(xproj);
y = poissrnd(pp);
fprintf('mean rate = %.1f (%d spikes)\n', sum(y)/nstim, sum(y));

% Compute linear regression solution
wls = stim\y;
wls = wls/norm(wls)*norm(wts); % normalize so vector norm is correct
figure(1); clf
plot(tt,wts,'k',tt,wls);

%% Find ML estimate using fminunc compare to glmfit

lfunc = @(w)(glms.neglog.poisson(w,stim,y,fnlin)); % neglogli function handle

opts = optimoptions(@fminunc,'Algorithm','trust-region',...
    'GradObj','on','Hessian','on');

tic;
[wml,nlogli] = fminunc(lfunc,wls,opts);
toc;

tic;
b = glmfit(stim, y, 'poisson');
toc

plot(tt,wts,'k',tt,[wls,wml, b(2:end)]);
legend({'true', 'wls', 'wml', 'b'})

%% 
% TODO: something is wrong with AR1 prior
prspec = gpriors.getPriorStruct('pairwiseDiff');

prior_inds = {1:nw};
prior_grp  = 1;


hyperParameters = [1000];
Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, hyperParameters);

tic
[wmap, SDebars] = glms.getPosteriorWeights(stim,y,Cinv, 'poisson');
toc


plot(1:nw, [wts wls wml wmap]);
legend({'true','wls', 'ml', 'map'})   


%% gridsearch hyperparameters

S = glms.hyperparameterGridSearch(stim,y, 'poisson', prspec, prior_inds, prior_grp, 100);


Cinv = glms.buildPriorCovariance(prspec, prior_inds, prior_grp, S.hyprBin);

tic
[wmap2, SDebars] = glms.getPosteriorWeights(stim,y,Cinv, 'poisson');
toc


plot(1:nw, [wts wls wml wmap wmap2]);
legend({'true','wls', 'ml', 'map', 'maph'})   

[errfun(wls) errfun(wml) errfun(wmap2)]