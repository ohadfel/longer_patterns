function [ ] = create_baus_trains_base_script(sub_num,range_of_snrs)
% sub_num = 102;
%
% range_of_snrs = 1.5:0.1:3.5;
helpr_folder = ['/cortex/data/MEG/Baus/CCdata/',num2str(sub_num),'/creat_baus_helper_dir'];
dbstop if error
if exist(helpr_folder)==0
    mkdir(helpr_folder);
end

for ii=1:length(range_of_snrs)
    [cur_param, status,~] = find_next_run( helpr_folder,'helperFile_',range_of_snrs);
    if status==0
        break
    else
        disp(['######################## Working on param = ',num2str(cur_param),' #########################'])
        valid_inds = [cur_param];
        create_baus_trains
    end
end

[base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName ] = set_subject_params(sub_num,11);
% WF2Baus_trains
best_snr = 2.2;
best_snr_str = num2str(best_snr);
best_snr_str(best_snr_str=='.')='p';
load(fullfile(outDirName, ['getPCs4AllOPnew_SNR_',best_snr_str,'.mat']));
load(fullfile(outDirName,'CCD8to60.mat'))

[WF1_positive,WF1_negative,BAUrate,BAUratePerChn,CCDpp] = split_wf_to_polarity(CCD,WF1,samplingRate);
save(fullfile(outDirName,['CCDppBySNR_',best_snr_str,'.mat']),'CCDpp','samplingRate','-v7.3');
disp(['file Saved at ',fullfile(outDirName,['CCDppBySNR_',best_snr_str,'.mat'])]);

fullMatrix = createFullMatrix( fullfile(baseDirName_input,'MarkerFile.mrk'),samplingRate,0);
relevantMatrix = fullMatrix(fullMatrix(:,3)==36 | fullMatrix(:,3)==37,:);
CCDpp36 = nan(size(CCDpp,1),relevantMatrix(1,2)-relevantMatrix(1,1),sum(relevantMatrix(:,3)==36));
CCDpp37 = nan(size(CCDpp,1),relevantMatrix(1,2)-relevantMatrix(1,1),sum(relevantMatrix(:,3)==37));
for ii=1:length(relevantMatrix)
    if relevantMatrix(ii,3)==36
        CCDpp36(:,:,relevantMatrix(ii,4)) = CCDpp(:,relevantMatrix(ii,1):(relevantMatrix(ii,2)-1));
    else
        CCDpp37(:,:,relevantMatrix(ii,4)) = CCDpp(:,relevantMatrix(ii,1):(relevantMatrix(ii,2)-1));
    end
end
[ decimated_mat ] = my_decimate( CCDpp36(:,:,1),5);
end
