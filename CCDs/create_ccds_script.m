% Generate INDATA (OUTDATA) markers
addpath(genpath('/cortex/users/ohad/pairs_analysis/Idans_code/'))
addpath(genpath('/home/lab/ohadfel/Code/fieldtrip-20140630'))
addpath(genpath('/home/lab/ohadfel/Code/ft_BIU'))
addpath(genpath('/media/FC7016037015C4F4/CCdata/matlab/IT'))
addpath(genpath('/media/FC7016037015C4F4/CCdata/matlab/MEGanalysis'));
%% ============== Initialize ============================================
% baseDirName = '/media/565821CF5821AEA5/Users/idan/Desktop/CCdata/1'; %'E:\MEGdata\2013_03_13';
copy_process_files = 1;
sub_num=102;
base_path = '/cortex/data/MEG/Baus/CCdata/';
% base_path = '/media/565821CF5821AEA5/Users/idan/Desktop/CCdata/';
% base_path = '/media/FC7016037015C4F4/Ohad/';

baseDirName_input = [base_path,num2str(sub_num)]; %'E:\MEGdata\2013_03_13';
baseDirName_output= [base_path,num2str(sub_num)]; %'E:\MEGdata\2013_03_13';
baseDirName= [base_path,num2str(sub_num)];

wtsOutDirName = sprintf('%s/SAM/wtsIT', baseDirName_output);
outDirName =sprintf('%s/matlabData', baseDirName_output);
cd(baseDirName_input)
% fileName = sprintf('%s/rs,xc,hb,lf_c,rfhp0.1Hz', baseDirName_input);
megFileName = 'rs,xc,hb,lf_c,rfhp0.1Hz';
megFileName = 'xc,hb,lf_c,rfhp0.1Hz';
fileName = sprintf('%s/%s', baseDirName_input, megFileName);
p = pdf4D(fileName);
samplingRate   = double(get(p,'dr')); %get the sqampling rate
hdr = get(p, 'header');  % get the header information
lastSample = double(hdr.epoch_data{1,1}.pts_in_epoch);  % get the length of the data from the header info.
conds = {'CHANGE', 'LAST'};
subDirs = {sprintf('%s/CHANGE11', outDirName), sprintf('%s/LAST11', outDirName)};

%% Add markerfile stuff
%% ============== Create MarkeFile with INDATA and OUTDATA ===============
%allMarkers = uniteAllOKtimes([baseDirName filesep 'MarkerFile.mrk']);
%
%allTimes = catStructFieldHoriz(allMarkers,'Times');
%
%allTimes = unique(allTimes);
%
%dT=0.5;
%
%continuousT = extendMarkers(allTimes, dT);
%
%tEnd = lastSample/samplingRate; % total length of file
%
%[marksIn, marksOut] = fillWithMarks(continuousT, dT, tEnd);
%
%uppendMarkers([baseDirName filesep 'MarkerFile.mrk'],marksIn, marksOut);
%
%% the new marker file is called NewMarker.mrk
%
%% rename it to MarkerFile.mrk
%% !mv MarkerFile.mrk MarkerFile_orig2.mrk
%% !mv NewMarker.mrk MarkerFile.mrk


%% points and cubes creation
balls = create_pnts( baseDirName_input, baseDirName_output);
cubeID = length(balls);
%% ==============  Around each point build a cube ====================
if ~exist(sprintf('%s/SAM',baseDirName),'dir')
    command = sprintf('mkdir SAM');
    unix(command);
end
cd SAM
if ~exist(sprintf('%s/SAM/Cubes512',baseDirName),'dir')
    command = sprintf('mkdir Cubes512');
    unix(command);
end
cd Cubes512

% DATA = centers2mat('Centers.txt');
DATA = balls;
cubeID = length(balls);
XYZcub = makeBasiccube(2.0);
% scatter3(XYZcub(:,1),XYZcub(:,2), XYZcub(:,3));

rotateCube2files(pi/6, 3, 3, 3, 'Cubes512Loc', 1:512,XYZcub, DATA);

%% ====================== Run SAMcov and SAMNwts ==================
%% ##################################################################################
%% ##################################################################################
%% ##################################################################################
%% #############################   NOT CHANGED YET   ################################
%% ##################################################################################
%% ##################################################################################
%% ##################################################################################
cd(baseDirName)
cd ..
% run SAMcov for the INDATA and OUTDATA
% command = sprintf('strace ~/bin/SAMcov64 -r 101 -d rs,xc,hb,lf_c,rfhp0.1Hz -m expSAM_INDATA_OUTDATA -v');
command = sprintf(['~/bin/SAMcov64 -r ',num2str(sub_num),' -d ',megFileName,' -m expSAM_INDATA_OUTDATA -v']);
% command = sprintf('~/bin/SAMcov64 -r 102 -d xc,hb,lf_c,rfhp0.1Hz -m expSAM_INDATA_OUTDATA -v');
% command = sprintf('~/bin/SAMcov64 -r 101 -d rs,xc,hb,lf_c,rfhp0.1Hz -m expSAM_INDATA_OUTDATA -v');
unix(command,'-echo')

% Run SAMNwts for all cubes and all rotations using shell script

if ~exist(sprintf('%s',wtsOutDirName),'dir')
   command = sprintf('mkdir %s', wtsOutDirName);
   unix(command,'-echo');
end

xxx = baseDirName(1:find(baseDirName=='/',1,'last')-1); % main data directory
vvv = num2str(sub_num);                         % subject directory
yyy = 'SAM';                       % SAM directory
zzz = 'wtsIT';                     % directory to write the wts file (created automatically)
uuu = 'Cubes512Loc';               % directory of the coordinates text files
sss = megFileName;        % MEG file name
rrr = 'expSAM_INDATA_OUTDATA';     % param file name
ttt = 'R';
ccc = '1';
ddd = '512';

% CREATE SOMETHING LIKE: ~/programs/shellWts/IT_runLoop3D /home/idan/Desktop/CCdata 2 SAM wtsIT Cubes512Loc xc,hb,lf_c,rfhp0.1Hz expSAM_INDATA_OUTDATA R
command = sprintf('~/programs/shellWts/IT_runLoop3D %s %s %s %s %s %s %s %s %s %s', xxx, vvv, yyy, zzz, uuu, sss, rrr, ttt, ccc, ddd);
% copy the string to a terminal and run it
% unix(command,'-echo');

%% ================ After creating the wts files load the MEG data =================

dbstop if error

if ~exist(outDirName,'dir')
   fprintf('Creating directory %s\n', outDirName);
   command = sprintf('mkdir %s', outDirName);
   unix(command,'-echo');
end
% Read the entire MEG file
% startMEGdata
T1=1/samplingRate;
T2=lastSample/samplingRate;
makeDIF=false;
makeCSD=false;
clean50=false;
chim = channel_index(p, 'MEG');
cd(wtsOutDirName)
MEG8t060Re = readFiltMEG(p,chim, cubeID, samplingRate);
MEG = read_data_block(p, [], chim);
% contMEGdata

% Filter the MEG in a narrow range
MEGnrw = filterMEG(MEG, 3, 35, samplingRate, 5);
% load one weights file and find the order of channels used in the weight file
eval(sprintf('Cubes%sLoc1R1_Amp_wts', num2str(cubeID)))
[chi2act, act2chi] = mapChi2ActIndex(p, ActIndex);
MEGnrwRe= reorderMEG(MEGnrw, act2chi);
% reorder also the MEG
MEGwbRe= reorderMEG(MEG, act2chi);
clear MEG
% Extract the best SNR for all locations
bestSNRallXahedrons = extractBestSNR4allPositions(MEGwbRe,...
     MEGnrwRe, samplingRate, 'Cubes512Loc', '_Amp_wts', ...
     [1 512], [1 27]);
cd(outDirName)
save bestSNRallXahedrons bestSNRallXahedrons

rotList = bestSNRallXahedrons.rotAtMinRo;
% or
% rotList = bestSNRallXahedrons.rotAtBestSNR;

% Get the CCDs at the optimal rotation
cd(wtsOutDirName)
CCD = reconstructCCDatRotation(MEG8t060Re, 'Cubes512Loc',...
                             [1,512], '_Amp_wts', rotList);
% normalize the CCD to have 0 mean and std of 1 for each
%   channel (or use Inbal’s normalization)
cd(outDirName)
save('CCD8to60', 'CCD', 'samplingRate', 'rotList', '-v7.3')
clear MEG8t060Re