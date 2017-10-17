function [WF1_positive,WF1_negative,BAUrate,BAUratePerChn,CCDpp] = split_wf_to_polarity(CCD,WF1,samplingRate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

WF1_positive = cell(size(WF1));
WF1_negative = cell(size(WF1));
CCDpp = false(size(CCD,1)*2, size(CCD,2));

for ii=1:size(CCD,1)
    cur_cell = WF1{1,ii};
    WF1_positive{ii} = cur_cell(sign(CCD(ii,(WF1{ii})))>0);
    WF1_negative{ii} = cur_cell(sign(CCD(ii,(WF1{ii})))<0);
    CCDpp(ii*2-1,WF1_positive{ii})=true;
    CCDpp(ii*2,WF1_negative{ii})=true;
end
[BAUrate,BAUratePerChn] = IT_getBAUrate(CCDpp,samplingRate);


%     for ii = 1:numChans
%         if mod(ii,20)==0
%             disp(ii)
%         end
%         updatedWF1 = updateWF1ForMaxBausInTrial( WF1{ii}, snr_peaks_vals{ii}, max_num_of_baus_in_trl, fullMatrix);
%         CCDpp(ii,updatedWF1) = true;
%     end
%     save(['CCDppBySNR_max_baus_',num2str(max_num_of_baus_in_trl),'.mat'],'CCDpp','samplingRate','-v7.3');
%     disp('file Saved!')

end

