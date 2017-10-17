function [ ] = find_baus_inner_func( CCD,...
        samplingRate, tmplt0Interp, offset, cur_snr, finalLint)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    disp(['Starting snr = ',num2str(cur_snr)]);
    [tmplts, eigV, tmplts1, tmplts2, WF0, WF1,snr_peaks_vals] = getPCs4All(CCD,...
        samplingRate, tmplt0Interp, offset, cur_snr, finalLint);
    snr_str = num2str(cur_snr);
    snr_str(snr_str=='.')='p';
    save(['getPCs4AllOPnew_SNR_',snr_str,'.mat'], 'tmplts', 'eigV', 'tmplts1', 'tmplts2' ,'WF0', 'WF1', 'snr_peaks_vals');

end

