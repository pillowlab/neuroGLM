function expt = addTrial(expt, trial, kTrial)

expt.trial(kTrial).duration = trial.duration;

varnames = fieldnames(expt.type);
for kVar = 1:numel(varnames)
    vname = varnames{kVar};
    if ~isfield(trial, vname)
        error('Variable [%s] is missing', vname);
    end
    
    switch expt.type.(vname)
        case 'continuous'
            if size(trial.(vname), 1) ~= expt.binfun(trial.duration)
                error('Duration of the trial must match continuous var');
            end
        case 'timing'
            if max(size(trial.(vname))) ~= numel(trial.(vname))
                error('Timing must be 1 dimensional')
            end
            
            if min(trial.(vname)) < 0 || max(trial.(vname)) > trial.duration
                error('Timing out of bound 0 <= [%f, %f] <= %f',min(trial.(vname)), max(trial.(vname)), trial.duration);
            end
        case 'value'
            % no restrictions on what values can be!
        case 'spike train'
            if min(trial.(vname)) < 0 || max(trial.(vname)) > trial.duration
                error('Spike timing out of bound 0 <= [%f, %f] <= %f',min(trial.(vname)), max(trial.(vname)), trial.duration);
            end
        otherwise
            error('Unknown variable type! Bug?!');
    end
    
    expt.trial(kTrial).(vname) = trial.(vname);
end