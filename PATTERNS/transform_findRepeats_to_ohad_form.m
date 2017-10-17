function [  ] = transform_findRepeats_to_ohad_form( patternsAll,params,samplingRate,segmentTable_cond,cond)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
all_codes = primes(1225)';
splay=6;
base_struct_4_patterns = struct('PP',ones(sum(patternsAll.listId>10000),params{4,2}+splay),'map_trial_times',[all_codes,zeros(size(all_codes))]);
all_complexities = unique(patternsAll.complexity);
all_complexities = sort(all_complexities,'descend');
tmp_primes = [3,5,7,11];

trial_offset=0;
if cond==37
    trial_offset = 100;
end


% allMarkers = uniteAllOKtimes(fullfile(baseDirName_input,'MarkerFile.mrk'));
% change_ind = find(strcmp({allMarkers.Name},'CHANGE'));
% last_ind = find(strcmp({allMarkers.Name},'LAST'));
% trials_start_times = nan(2,max(length(allMarkers(change_ind).Times),length(allMarkers(last_ind).Times)));
% trials_start_times(1,1:length(allMarkers(change_ind).Times))=allMarkers(change_ind).Times;
% trials_start_times(2,1:length(allMarkers(last_ind).Times))=allMarkers(last_ind).Times;



debug_counter = 0;
for ii=1:length(all_complexities)
    cur_complexity_defenitions = patternsAll.definition(patternsAll.complexity==all_complexities(ii));
    cur_complexity = cur_complexity_defenitions.unitNames;
    disp(['~~~~~~~~~~~~~~~~~~~~~~~~~~~~LOOKING AT COMPLEXITY ',num2str(length(cur_complexity)),'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'])
    defenitions = repmat(base_struct_4_patterns,ceil(size(cur_complexity_defenitions,2)/2),1);
    defenitions_last_ind=0;
    for jj=1:size(cur_complexity_defenitions,2)
        debug_counter = debug_counter+1
        cur_units = int16(cur_complexity_defenitions(jj).unitNames-10000);
        base_time = min(cur_complexity_defenitions(jj).timesInFile)
        trial_ind = find(sum([base_time>=segmentTable_cond(:,1),base_time<=segmentTable_cond(:,2)],2)==2)+trial_offset
        cur_times = int16((cur_complexity_defenitions(jj).timesInFile - base_time)*samplingRate+1);
        [defenitions,defenitions_last_ind] = unify_patterns(defenitions,defenitions_last_ind,cur_units,cur_times,base_time,trial_ind,splay,all_codes);
%         for kk=1:length(tmp_primes)
%             for ll=1:length(cur_times)
%                 cur_complexity_ohad_form_defenitions(1).PP(cur_units(ll),cur_times(ll))=cur_complexity_ohad_form_defenitions(1).PP(cur_units(ll),cur_times(ll))*tmp_primes(jj);
%             end
%         end
    end
end

end
% 
% tmp_colors='brgm';
% sizes = [100,75,50,25];
% for tmp=1:length(tmp_primes)
%     [col,row] = find(mod(cur_complexity_ohad_form_defenitions(1).PP,tmp_primes(tmp))==0);
%     scatter(row,col,sizes(tmp),tmp_colors(tmp),'filled');
%     hold on
% end
% q3 = zeros(size(cur_complexity_ohad_form_defenitions(1).PP));
% for tmp=1:length(row)
%   q3(row(tmp),col(tmp))=1;  
% end



 

