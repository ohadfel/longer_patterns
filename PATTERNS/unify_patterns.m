function [ defenitions,defenitions_last_ind ] = unify_patterns( defenitions,defenitions_last_ind,cur_units,cur_times,base_time,trial_ind,splay,all_codes)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% all_codes = primes(1225);
trial_code = all_codes(trial_ind);
all_possible_codes = all_codes(all_codes<trial_code);
found_match = 0;
cur_complexity = length(cur_units);

[sorted_units,I] = sort(cur_units);
sorted_times = cur_times(I);



if defenitions_last_ind>0
    for ii=1:defenitions_last_ind
        if found_match
            break;
        end
        defenitions_trans = defenitions(ii).PP';
        all_possible_codes = defenitions(ii).map_trial_times(defenitions(ii).map_trial_times(:,2)~=0,1);
        for codes = 1:length(all_possible_codes)
            cur_code =all_possible_codes(codes);
            if found_match
                break;
            end
            [tmp_times,tmp_units] = find(mod(defenitions_trans,cur_code)==0);
            if isempty(tmp_times)
                continue;
            end
            my_legends{1}=['New pattern ',num2str(base_time)];
            my_legends{2}=['Orig pattern ',num2str(defenitions(ii).map_trial_times(defenitions(ii).map_trial_times(:,1)==cur_code,2))];
            %             figure
            scatter(cur_times,cur_units,100,'r','filled');
            hold on
            scatter(tmp_times,tmp_units,50,'b','filled');
            ylim([0,1025])
            all_times = sort([defenitions(ii).map_trial_times(defenitions(ii).map_trial_times(:,2)~=0,2),base_time]);
            title(['pattern of ',num2str(length(tmp_units)),' found in times ',num2str(all_times)])
            legend(my_legends)
            grid on
            grid minor
            hold off
            drawnow
            length_equal = length(tmp_units) == sum(sorted_units==tmp_units');
            if length_equal
                all_splays = abs(diff([tmp_times,sorted_times'],1,2));
                max_splay = max(all_splays)<= splay;
                
                if max_splay
                    linear_ind=sub2ind(size(defenitions(ii).PP),cur_units,cur_times);
                    if length(linear_ind)>cur_complexity
                        error('BUG')
                    end
                    defenitions(ii).PP(linear_ind)=defenitions(ii).PP(linear_ind)*all_codes(trial_ind);
                    %                     for event_ind = 1:length(tmp_units)
                    %                         defenitions(ii).PP(cur_units(event_ind),cur_times(event_ind))=defenitions(ii).PP(cur_units(event_ind),cur_times(event_ind))*trial_code;
                    %                     end
                    defenitions(ii).map_trial_times(defenitions(ii).map_trial_times(:,1)==all_codes(trial_ind)+1,2) = base_time;
                    found_match=1;
                else
                    hold on
                    scatter(tmp_times(all_splays>splay),tmp_units(all_splays>splay),75,'pg','filled');
                    hold off
                    drawnow
                end
            end
        end
    end
end
if defenitions_last_ind*found_match==0
    defenitions_last_ind=defenitions_last_ind+1;
    linear_ind=sub2ind(size(defenitions(1).PP),cur_units,cur_times);
    if length(linear_ind)>cur_complexity
        error('BUG')
    end
    defenitions(defenitions_last_ind).PP(linear_ind)=defenitions(defenitions_last_ind).PP(linear_ind)*all_codes(trial_ind);
    defenitions(defenitions_last_ind).map_trial_times(defenitions(defenitions_last_ind).map_trial_times(:,1)==all_codes(trial_ind),2) = base_time;% TODO somthing is not good
    %     for ii=1:length(cur_times)
    %         defenitions(defenitions_last_ind).PP(cur_units(ii),cur_times(ii))=defenitions(defenitions_last_ind).PP(cur_units(ii),cur_times(ii))*trial_code;
    %     end
end

end

