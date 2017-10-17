function [ fullMatrix ] = createFullMatrix( markerfile_path,samplingRate,toSave )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% create fullMatrix
%% new preprocess 27/03/2016
preStimNumOfSamples =10;
postStimNumOfSamples = 480;

if iscell(markerfile_path)
    allMarkers = uniteAllOKtimes(markerfile_path{1});
else
    allMarkers = uniteAllOKtimes(markerfile_path);
end

disp('DATA LOADED')
change_ind=-1;
last_ind=-1;
trials_counter=0;
for ii=1:length(allMarkers)
    disp(['cond=',num2str(ii), ' num of trials=',num2str(length(allMarkers(ii).Times)) ])
    trials_counter=trials_counter+length(allMarkers(ii).Times);
    if strcmp(allMarkers(ii).Name,'CHANGE')
        change_ind=ii;
    end
    if strcmp(allMarkers(ii).Name,'LAST')
        last_ind=ii;
    end

end

fullMatrix = nan(trials_counter,4);
next_ind=1;
for ii=1:length(allMarkers)
    disp(['cond=',num2str(ii), ' num of trials=',num2str(length(allMarkers(ii).Times)) ])
    fullMatrix(next_ind:next_ind+length(allMarkers(ii).Times)-1,3)=ii;
    fullMatrix(next_ind:next_ind+length(allMarkers(ii).Times)-1,4)=1:length(allMarkers(ii).Times)';
    sortedTimes = sort(allMarkers(ii).Times);
    fullMatrix(next_ind:next_ind+length(allMarkers(ii).Times)-1,1)=floor(sortedTimes*samplingRate)-preStimNumOfSamples;
    fullMatrix(next_ind:next_ind+length(allMarkers(ii).Times)-1,2)=floor(sortedTimes*samplingRate)+postStimNumOfSamples;
    next_ind=next_ind+length(allMarkers(ii).Times);
end
fullMatrix = sortrows(fullMatrix);
fullMatrix(:,3)=fullMatrix(:,3)-(change_ind-36);

if toSave
    run_details.input_params = {markerfile_path};
    run_details.run_time = datestr(datetime('now'));
    run_details.created_by = [mfilename('fullpath'),'.m'];

    disp('Saving...')
    save('fullMatrixN.mat','fullMatrix','run_details','-v7.3');
end
