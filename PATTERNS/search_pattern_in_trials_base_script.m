%% Run search_pattern_in_trials base script
addpath(genpath([pwd,'/..']));
[ base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName,conds,subDirs,runID ] = set_subject_params(102,11);
baseDirName = baseDirName_input;

load(fullfile(outDirName,'all_trials_matrix.mat'));

files = dir(fullfile(outDirName,'helper_files'));
perms = randperm(size(files,1)-2);


while length(perms)>0
    cur_file_name = files(perms(1)+2).name;
    disp(['Working on file ',cur_file_name])
%     delete(fullfile(outDirName,'helper_files',cur_file_name))
    
    first_und = find(cur_file_name=='_',1);
    tmp = load(fullfile(outDirName,cur_file_name(1:first_und-1),[cur_file_name((first_und+1):(find(cur_file_name=='.',1))),'mat']));
    disp(['~~~~~~~~~~~~~~~~~LOADED ',cur_file_name,'~~~~~~~~~~~~~~~~~']);
    real_conds_repeats = nan(length(tmp.patterns.complexity),2);
    matches_trials = cell(length(tmp.patterns.complexity),1);
    for ind=1:size(real_conds_repeats,1)
        units_names = patterns1.definition(ind).unitNames-10000;
        times = floor((patterns1.definition(ind).timesInFile-min(patterns1.definition(ind).timesInFile))*samplingRate)+1;
        [matches_trials{ind},real_conds_repeats(ind,:)] = search_pattern_in_trials( units_names',times',trials_matrix,tmp.patterns.splay*2+1 );        
    end
    save_file_name = fullfile(outDirName,cur_file_name(1:first_und-1),['searches_results_',cur_file_name(find(cur_file_name=='g',1):(find(cur_file_name=='.',1)-1))]);
    save(save_file_name,'real_conds_repeats','matches_trials','-v7.3');
    dips([save_file_name,' saved'])
    
    files = dir(fullfile(outDirName,'helper_files'));
    perms = randperm(size(files,1)-2);
end




% first_ind = 9169083;
% ind=first_ind;
% first=[patterns1.definition(ind).unitNames-10000;floor((patterns1.definition(ind).timesInFile-min(patterns1.definition(ind).timesInFile))*samplingRate)+1];
% ind=first_ind+1;
% second=[patterns1.definition(ind).unitNames-10000;floor((patterns1.definition(ind).timesInFile-min(patterns1.definition(ind).timesInFile))*samplingRate)+1];
% ind=first_ind+2;
% third=[patterns1.definition(ind).unitNames-10000;floor((patterns1.definition(ind).timesInFile-min(patterns1.definition(ind).timesInFile))*samplingRate)+1];
% 
% figure
% scatter(first(2,:),first(1,:),75,'filled','b')
% hold on
% scatter(second(2,:),second(1,:),50,'filled','r')
% grid on
% grid minor
% ylim([0,1024])
% patterns1.Trial(first_ind:(first_ind+2))
% tic
% [found_matches,repeats_conds] = search_pattern_in_trials( first(1,:)',first(2,:)',trials_matrix,10 );
% [found_matches1,repeats_conds1] = search_pattern_in_trials( second(1,:)',second(2,:)',trials_matrix,10 );
% [found_matches2,repeats_conds2] = search_pattern_in_trials( third(1,:)',third(2,:)',trials_matrix,10 );
% toc