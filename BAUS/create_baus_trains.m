%% Create BAUs trains

[base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName ] = set_subject_params(sub_num);

%% Start here after creating CCDs
cd(outDirName)
[CCD, numChans, numData]=load_CCD_and_normalized(outDirName);
[tmplt0Interp,offset,initialSNR,finalLint]=load_template_and_interpolate(base_path,0);


%% Find baus for range of snrs 
addpath(baseDirName_input)
for cur_snr=1:length(valid_inds)
    find_baus_inner_func( CCD,samplingRate, tmplt0Interp, offset, valid_inds(cur_snr), finalLint);
end

% To see the parameters results ess /home/lab/ohadfel/Code/longer_patterns/BAUS/WF2Baus_trains.m

[WF1_positive,WF1_negative,BAUrate,BAUratePerChn,CCDpp] = split_wf_to_polarity(CCD,WF1,samplingRate);
save(['CCDppBySNR_max_baus_',num2str(max_num_of_baus_in_trl),'.mat'],'CCDpp','samplingRate','-v7.3');
disp('file Saved!')


% % % check if OK
% % sum(CCDpp(500,:)) % ans = 6950
% % save CCDppBySNRnew2 CCDpp samplingRate
% mData1=zeros(512,201);
% vData1=zeros(512,201);
% N1 = zeros(512,1);
% for ii=1:512
%     if mod(ii,100)==0
%         disp(ii);
%     end
%     [mData1(ii,:), vData1(ii,:),N1(ii)] = meanAround(CCD(ii,:), WF0{ii},100, 100,...
%         'Flip',[],'peak');
% end
% figure
% plot(-100:100,mData1);
% hist(min(mData1'));
% 
% 
% 
% 
% % Validate that the BAUs are OK by plotting mean and variance around the BAU times:
% ii = 96;  % an example for BAU No. 96
% for ii = 1 : numChans
%     [mData1, vData1,N1] = meanAround(CCD(ii,:), WF0{ii},100, 100,...
%         'Flip',[],'peak');
% %     Handles1 = dualPlot (-100:100, mData1, vData1, 'Lag, samples',...
% %         'Amplitude, normalized', 'Variance', ...
% %         ['mean BAU on tmplt1   for CCD(' num2str(ii) '), SNR=3.5, N=' num2str(N1)]);
%     Handles1 = dualPlot (-100:100, mData1, vData1, 'Lag, samples',...
%         'Amplitude, normalized', 'Variance', ...
%         ['CCD(' num2str(ii) '), SNR=3.5, N=' num2str(N1)]);
%     pause
%     close
% end
%        
% 
% clear CCD