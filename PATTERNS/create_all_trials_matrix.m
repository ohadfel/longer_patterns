sub_num=102;
runID = 11;
% _CCD_8to60
% typesOfTrials2Create = {'CCD','SNR','CCDppBySNR_2p2'};
typesOfTrials2Create = {'SNR_CCD_8to60'};

% typesOfTrials2Create = {'CCD'};

addpath(genpath('/home/lab/ohadfel/Code/longer_patterns/'))
[ base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName,conds,subDirs,runID ] = set_subject_params( sub_num,runID );

for ii=1:length(typesOfTrials2Create)
    if strcmp(typesOfTrials2Create{ii},'CCD')
        [ CCD, numChans, numData,samplingRate ] = load_CCD_and_normalized( outDirName );
    else
        load(fullfile(outDirName,[typesOfTrials2Create{ii},'.mat']))
    end
    if strcmp(typesOfTrials2Create{ii},'CCDppBySNR_2p2')
        trials_matrix=nan(1024,509,100,2);
    else
        trials_matrix=nan(512,509,100,2);
    end
    for cur_cond=1:2
        load(fullfile(subDirs{cur_cond},'segmentTable.mat'));
        segmentTable_samples = floor(segmentTable*samplingRate);
        for trial_ind=1:length(segmentTable_samples)
            cur_range = segmentTable_samples(trial_ind,1):segmentTable_samples(trial_ind,2);
            if strcmp(typesOfTrials2Create{ii},'CCDppBySNR_2p2')
                trials_matrix(:,1:length(cur_range),trial_ind,cur_cond)=CCDpp(:,cur_range);
            end
            if strcmp(typesOfTrials2Create{ii},'SNR_CCD_8to60')
                trials_matrix(:,1:length(cur_range),trial_ind,cur_cond)=SNR(:,cur_range);
            end
            if strcmp(typesOfTrials2Create{ii},'CCD')
                trials_matrix(:,1:length(cur_range),trial_ind,cur_cond)=CCD(:,cur_range);
            end
        end
    end
    save(fullfile(outDirName,['all_trials_matrix_',typesOfTrials2Create{ii},'.mat']),'trials_matrix','samplingRate','-v7.3');
end