condition2load = 'LAST11';
base_path = '/cortex/data/MEG/Baus/CCdata/102/matlabData';

if ~exist('patternsAll','var')
    load(fullfile(base_path,condition2load,'patternsAll.mat'))
end
if ~exist('segmentTable','var')
    load(fullfile(base_path,condition2load,'segmentTable.mat'))
end
% figure
% for ii=1:2:20
%     sorted_pattern_times = (patternsAll.definition(ii).timesInFile - min(patternsAll.definition(ii).timesInFile))*samplingRate+1;
%     sorted_pattern_units = patternsAll.definition(ii).unitNames-10000;
%     sorted_test_times = (patternsAll.definition(ii+1).timesInFile - min(patternsAll.definition(ii+1).timesInFile))*samplingRate+1;
%     sorted_test_units = patternsAll.definition(ii).unitNames-10000;
%     scatter(sorted_test_times,sorted_test_units,100,'r','filled');hold on
%     scatter(sorted_pattern_times,sorted_pattern_units,75,'b','filled')
%     grid on
%     grid minor
%     ylim([0,1025])
% %     hold off
%     pause;
% end

% figure
samplingRate=1/params{2,2};
curCount=0;
all_counts=ones(length(patternsAll.complexity),1);
patterns_locked = zeros(length(patternsAll.complexity),1);
patterns_no_repeats = zeros(length(patternsAll.complexity),1);
last_ind_of_count = 1;
tic
for ii=1:length(patternsAll.complexity)-1
    sorted_pattern_times = (patternsAll.definition(ii).timesInFile - min(patternsAll.definition(ii).timesInFile))*samplingRate+1;
    sorted_pattern_units = patternsAll.definition(ii).unitNames-10000;
    
    units_times_pattern_mat = [sorted_pattern_units',sorted_pattern_times'];
    [sorted_units_times_pattern_mat] = sortrows(units_times_pattern_mat);
    
    sorted_test_times = (patternsAll.definition(ii+1).timesInFile - min(patternsAll.definition(ii+1).timesInFile))*samplingRate+1;
    sorted_test_units = patternsAll.definition(ii+1).unitNames-10000;
    
    units_times_test_mat = [sorted_test_units',sorted_test_times'];
    [sorted_units_times_test_mat] = sortrows(units_times_test_mat);
    
    if patternsAll.complexity(ii)== patternsAll.complexity(ii+1)
        if any(sorted_units_times_pattern_mat(:,1)<0)
%             disp(['found pattern locked to trigger ii=',num2str(ii)])
            patterns_locked(ii)=1;
        end
        if all(sorted_units_times_pattern_mat(:,1)== sorted_units_times_test_mat(:,1))
            if round(max(abs(diff([sorted_units_times_pattern_mat(:,2),sorted_units_times_test_mat(:,2)],1,2))))<=10
%                 disp(['Patterns #',num2str(ii), ' And #',num2str(ii+1), ' match'])
                all_counts(last_ind_of_count)= all_counts(last_ind_of_count)+1;
            end
        else
            if all_counts(last_ind_of_count)<2
%                 disp(['this is weird, try to plot this ii=',num2str(ii)])
                patterns_no_repeats(ii)=1;
            end
            last_ind_of_count = last_ind_of_count+1;
        end
    else
        disp(['Starting new complexity (',num2str(patternsAll.complexity(ii+1)),') in ind #',num2str(ii+1),',Max # of repeatitions is ',num2str(max(all_counts(1:last_ind_of_count)))])
%         disp(['Max # of repeatitions is ',num2str(max(all_counts(1:last_ind_of_count)))])
        last_ind_of_count = last_ind_of_count+1;
    end
end
toc

all_counts=all_counts(1:last_ind_of_count);
patterns_locked_bool = logical(patterns_locked);
patterns_no_repeats_bool = logical(patterns_no_repeats);

trials = nan(length(patternsAll.complexity),1);
for ii=1:length(patternsAll.complexity)
    if mod(ii,50000)==0
        disp(ii)
    end
    cur_ind = mean(patternsAll.definition(ii).timesInFile);
    cur_trial = find(segmentTable(:,1)<=cur_ind & segmentTable(:,2)>=cur_ind);
    if length(cur_trial)>1
        disp('BUG')
        db stop
    end
    if cur_trial<1
        disp('BUG')
        db stop
    end
%     disp(ii)
    trials(ii) = cur_trial;
end
trials_int = uint16(trials);
all_counts_int = uint16(all_counts);

save(fullfile(base_path,condition2load,'patterns_props.mat'),'samplingRate','patterns_locked_bool','patterns_no_repeats_bool','all_counts_int','trials_int','-v7.3')


grouping_size = 10000;
mkdir(fullfile(base_path,condition2load),'patterns_input_files');
save_str_template = fullfile(base_path,condition2load,'patterns_input_files','patterns_seg');



for ii=1:grouping_size:length(patternsAll.complexity)
    
end




