function [ found_matches,repeats_conds ] = search_pattern_in_trials( pattern_units,pattern_times,trials_mat,splay )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% if size(pattern_units,1) < size(pattern_units,2)
%     pattern_units = pattern_units';
% end
% if size(pattern_times,1) < size(pattern_times,2)
%     pattern_times = pattern_times';
% end
%% TODO change all the sorts lines with sortrows(A,[1,2]) style.
pattern_length = length(pattern_units);
max_length_of_pattern = max(pattern_times)+splay;
first_unit = pattern_units(pattern_times==min(pattern_times));
if length(first_unit)>1
    first_unit = first_unit(1);
end
first_unit_matrix = [squeeze(trials_mat(first_unit,:,:,1))';squeeze(trials_mat(first_unit,:,:,2))'];
% trials_mat_relevant = trials_mat(pattern_units,:,:,:);
units_times_mat = [pattern_units,pattern_times];
[sorted_units_times_mat] = sortrows(units_times_mat);
sorted_pattern_units = sorted_units_times_mat(:,1);
sorted_pattern_times = sorted_units_times_mat(:,2);

[pattern_hist_counts,pattern_hist_units]=hist(sorted_pattern_units,unique(sorted_pattern_units));

% [sorted_pattern_units,sorting_indexes] = sort(pattern_units);
% sorted_pattern_times = pattern_times((sorting_indexes));
% sorted_pattern_units = sorted_pattern_units';
% sorted_pattern_times = sorted_pattern_times';

repeats_conds=[0,0];

trials_mat(setdiff(1:1024,pattern_units),:)=nan;

[candidate_trials,candidate_times]=find(first_unit_matrix==1);
found_matches=nan(200,2);%trial_number,match_index
number_of_matches_found = 0;
for ind=1:length(candidate_trials)
    cond_ind = (candidate_trials(ind)>100)*1 +1;
    trial_ind = candidate_trials(ind) -100*(cond_ind-1);
    time_range = max(1,(candidate_times(ind)-splay)):min(size(trials_mat,2),(candidate_times(ind)+max_length_of_pattern));
    [test_units,test_times]=find(squeeze(trials_mat(:,time_range,trial_ind,cond_ind))==1);
    if length(test_units)>=pattern_length
        
        units_times_test_mat = [test_units,test_times];
        [sorted_units_times_test_mat] = sortrows(units_times_test_mat);
        sorted_test_units = sorted_units_times_test_mat(:,1);
        sorted_test_times = sorted_units_times_test_mat(:,2);
        
        
        %         [sorted_test_units,sort_indexes] = sort(test_units);
        %         sorted_test_times = test_times(sort_indexes);
        optional_base_time = time_range(1)+1-min(sorted_test_times);
        sorted_test_times = sorted_test_times+1-min(sorted_test_times);
        if length(test_units)==pattern_length
            if sorted_test_units==sorted_pattern_units
                all_splays = abs(diff([sorted_test_times,sorted_pattern_times],1,2));
                if(max(all_splays)<= splay)
                    number_of_matches_found = number_of_matches_found +1;
                    found_matches(number_of_matches_found,1)=candidate_trials(ind);
                    found_matches(number_of_matches_found,2)=optional_base_time;
                    repeats_conds(double(candidate_trials(ind)>=100)+1) = repeats_conds(double(candidate_trials(ind)>=100)+1)+1;
                end
            end
        else
            [test_hist_counts,test_hist_units]=hist(sorted_test_units,unique(sorted_test_units));
            if length(test_hist_units)~=length(pattern_hist_units)
                continue
            end
            if all(test_hist_units==prepeats_condsattern_hist_units) && sum(test_hist_counts>=pattern_hist_counts)==pattern_length
                %% take care of  lois that repeats only once
                test_unit_names = test_hist_units(test_hist_counts-pattern_hist_counts==0);
%                 temp_test_matrix = units_times_test_mat;
                
                temp_test_matrix_1rep = sortrows(units_times_test_mat(ismember(units_times_test_mat(:,1),test_unit_names),:));
                temp_pattern_matrix_1rep = sortrows(units_times_mat(ismember(units_times_mat(:,1),test_unit_names),:));
                all_splays = abs(diff([temp_test_matrix_1rep(:,2),temp_pattern_matrix_1rep(:,2)],1,2));
                if (max(all_splays)> splay)
                    continue
                end
                %% take care of the units with repeatitions
                temp_test_matrix_reps= sortrows(units_times_test_mat(~ismember(units_times_test_mat(:,1),test_unit_names),:));
                temp_pattern_matrix_reps= sortrows(units_times_mat(~ismember(units_times_mat(:,1),test_unit_names),:));
                match_found = 0;
                for ii=1:size(temp_pattern_matrix_reps,1)
                    match_found = 0;
                    cur_pattern_unit = temp_pattern_matrix_reps(ii,1);
                    cur_pattern_time = temp_pattern_matrix_reps(ii,2);
                    
                    for jj=1:size(temp_test_matrix_reps,1)
                        if temp_test_matrix_reps(jj,1)== cur_pattern_unit && abs(temp_test_matrix_reps(jj,2)-cur_pattern_time)<=splay
                            match_found = 1;
                            break;
                        end
                    end
                    if ~match_found
                        break
                    end
                end
                if ~match_found
                    continue
                end
                
            end
            %             if unique(sorted_test_units)==sorted_pattern_units ismember(sorted_pattern_units,sorted_test_units)
            %                 [repeatition,unit]=hist(sorted_test_units,sorted_test_units);
            %                 no_repeatiotions_inds = repeatition==1;
            %                 final_splays = abs(diff([sorted_test_times(no_repeatiotions_inds),sorted_pattern_times],1,2));
            %                 if max(final_splays)<=splay
            %
            %                 end
            %
            %                 disp('bug');
            %             end
            
        end
    end
end

found_matches = found_matches(1:number_of_matches_found,:);


end



















