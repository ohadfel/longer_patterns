addpath(genpath([pwd,'/..']));
[ base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName,conds,subDirs,runID ] = set_subject_params(102,11);
baseDirName = baseDirName_input;
snr_str = '2p2';
%% ################# Start here after finding events in CCDs #######################
% Convert the point processes to evnt_tbl.
load(fullfile(outDirName,sprintf('CCDppBySNR_%s', snr_str)));  %  will load CCDpp and samplingRate

numPOI = size(CCDpp,1);

markerFile = fullfile(baseDirName_input,'MarkerFile.mrk');
evnt_tbl = pp2evnt_tbl(CCDpp, samplingRate, markerFile);
evnt_tbl = sortEvnt(evnt_tbl);
evnt_tbl = addFileNo(evnt_tbl);


save(fullfile(outDirName,sprintf('evnt_tbl_BySNR_%s.mat', snr_str)), 'evnt_tbl')

load(fullfile(outDirName,sprintf('evnt_tbl_BySNR_%s.mat', snr_str)))

% Split among behavioral events
deadTime = 1;

% create sub directories for each condition
for condI = 1 : length(conds)
    if ~exist(fullfile(outDirName,sprintf('%s%s', conds{condI}, num2str(runID))),'dir');
        mkdir(fullfile(outDirName,sprintf('%s%s', conds{condI}, num2str(runID))));
    end
    subDirs{condI} = fullfile(outDirName,sprintf('%s%s', conds{condI}, num2str(runID)));
end

% create segmentTable
cd(baseDirName)
Tpnts = IT_createSegmentTable(conds);
for condI = 1 : length(conds)
%     cd(subDirs{condI})
    segmentTable = Tpnts(:,condI);
    segmentTable(segmentTable == 0) = [];
    segmentTable(:,2) = segmentTable(:,1)+0.5;
    save(fullfile(subDirs{condI},'segmentTable'),segmentTable);
%     save segmentTable segmentTable
    clear segmentTable
end

cd(outDirName)

splitPPbySegments([], CCDpp, samplingRate, subDirs, deadTime);

dbstop if error



load(fullfile(base_path,'params.mat'));
params = setTmatParams(params, 'MinUnitsInBin',3);

% listId = indSelectedBalls+10000; %(1:700) + 10000;
% listId = (1:numPOI)+10000;
% listId2 = 10001:11024;
global listOfLists
load('/cortex/data/MEG/Baus/CCdata/listOfLists.mat')
for ii = 1:length(subDirs)
%     cd(outDirName)
    global listOfLists
    load('/cortex/data/MEG/Baus/CCdata/listOfLists.mat')
    load(fullfile(outDirName,sprintf('evnt_tbl_BySNR_%s', snr_str)))
%     cd (subDirs{ii})
    load(fullfile(subDirs{ii},'segmentTable')) %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CHECK THIS~~~~~~~~~~~~~~~~~~~~~~~~~~~
    evnt = cutEtable(evnt_tbl,segmentTable',0.4);%~~~~~~~~~~~~~~~~~~~~ CHECK THIS~~~~~~~~~~~~~~~~~~~~~~~~~~~
    evnt = sortEvnt(evnt);
    listId = unique(evnt.name);
    listId(listId<=0) = [];
%     patternsAll = findRepeatsNew4(evnt, listId, params, 0, 0, 0);
    patternsAll = findRepeatsNew5(evnt, listId, params, 0, 0, 0);
    save(fullfile(subDirs{ii},'patternsAll.mat'), 'patternsAll', 'params','-v7.3')
    disp([fullfile(subDirs{ii},'patternsAll.mat'),' Saved']);
    [patterns, patternCount]=purgePatterns(patternsAll, [],[], 3, []);
    patterns1 = addPatNo(patterns,1000,0);
    patterns1.Trial = nan(size(patterns1.No));
    save(fullfile(subDirs{ii},'patterns1.mat'), 'patterns1', 'params','-v7.3')
%     save patternsB1 patternsAll patterns patternCount patterns1 params
    
end


% 
% %% There are several steps for obtaining the patterns:
% % Prepare the parameters for finding patterns:
% cd(baseDirName)
% 
% cd (outDirName)
% load(sprintf('evnt_tbl_BySNR_%s', num2str(cubeID)))
% 
% 
% % create matrix D with distances between all pnts
% 
% 
% dbstop if error
% % creates patterns_BySNR_s1 in each subDir
% getPatterns(subDirs, params, listId,D, 'BySNR')
% 
% 
% 
% 
% 
% 
% 
% cd excercise2
% clear
% load evnts
% load('C:\Users\Ohad\Downloads\params.mat')
% params = setTmatParams(params, 'MinUnitsInBin',3);
% listId = unique(evnt1.name);
% listId(listId<=0) = [];
% patternsAll = findRepeatsNew4(evnt2, listId, params, 0, 0, 0);
% [patterns, patternCount]=purgePatterns(patternsAll, [],[], 3, []);
% patterns1 = addPatNo(patterns,1000,0);
% save patternsB1 patternsAll patterns patternCount patterns1 params
