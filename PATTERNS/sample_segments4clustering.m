function [ segments,trial_inds,start_inds,stop_inds ] = sample_segments4clustering( trials_matrix,segments_length,sub_num,hyperfold_num,test_fold,segments_overlap,cond_ind )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
sub_data_path = fullfile('/cortex/users/ohad/pairs_analysis',num2str(sub_num-(100*(sub_num>100))));
sub_path = fullfile(sub_data_path,['hyperFoldNum',num2str(hyperfold_num)]);

if segments_overlap==0
    segments_overlap = segments_length;
end

starts_times = 1:segments_overlap:(size(trials_matrix,2)-segments_length);


load(fullfile(sub_path,'folds_splits.mat'));
if cond_ind==1
    valid_trials = cond36(cond36(:,2)~=test_fold,1);
else
    valid_trials = cond37(cond37(:,2)~=test_fold,1);
end



flat_single_segment = segments_length*size(trials_matrix,1);
num_segments = length(starts_times)*length(valid_trials);
segments = nan(num_segments,flat_single_segment);

trial_inds=nan(num_segments,1);
start_inds=nan(num_segments,1);
stop_inds=nan(num_segments,1);


last_ind=1;
for trial_ind=1:length(valid_trials)
    for start_ind=1:length(starts_times)
        cur_range = starts_times(start_ind):(starts_times(start_ind)+segments_length-1);
        
        trial_inds(last_ind) = valid_trials(trial_ind);
        start_inds(last_ind) = starts_times(start_ind);
        stop_inds(last_ind) = starts_times(start_ind)+segments_length;
        
        segments(last_ind,:)=reshape(squeeze(trials_matrix(:,cur_range,valid_trials(trial_ind),cond_ind)),1,[]);
        last_ind = last_ind+1;
    end   
end


end

