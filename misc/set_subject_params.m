function [ base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName,conds,subDirs,runID ] = set_subject_params( sub_num,runID )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % Generate INDATA (OUTDATA) markers
    addpath(genpath('/cortex/users/ohad/pairs_analysis/Idans_code/'))
    addpath(genpath('/home/lab/ohadfel/Code/fieldtrip-20140630'))
    addpath(genpath('/home/lab/ohadfel/Code/ft_BIU'))
    addpath(genpath('/media/FC7016037015C4F4/CCdata/matlab/IT'))
    addpath(genpath('/media/FC7016037015C4F4/CCdata/matlab/MEGanalysis'));
    addpath(genpath('/cortex/users/ohad/Longer_patterns'))

    %% ============== Initialize ============================================
    % baseDirName = '/media/565821CF5821AEA5/Users/idan/Desktop/CCdata/1'; %'E:\MEGdata\2013_03_13';
    base_path = '/cortex/data/MEG/Baus/CCdata';
    baseDirName_input = fullfile(base_path,num2str(sub_num)); %'E:\MEGdata\2013_03_13';
    baseDirName_output= fullfile(base_path,num2str(sub_num)); %'E:\MEGdata\2013_03_13';
    baseDirName= fullfile(base_path,num2str(sub_num));

    wtsOutDirName = sprintf('%s/SAM/wtsIT', baseDirName_output);
    outDirName =sprintf('%s/matlabData', baseDirName_output);
    conds = {'CHANGE', 'LAST'};
    subDirs = {fullfile(outDirName,sprintf('CHANGE%d',runID)), fullfile(outDirName,sprintf('LAST%d',runID))};

end
