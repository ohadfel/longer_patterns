function [ tmplt0Interp,offset,initialSNR,finalLint ] = load_template_and_interpolate( base_path,toPlot )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
load(fullfile(base_path,'tmplt0.mat'));
% interpolate the template to the new samplingRate
tmplt0Interp = interp(tmplt0,2);
tmplt0Interp(1:33) = tmplt0Interp(1);
tmplt0Interp(end) = [];
% normalize to mean = 0 and norm = 1
tmplt0Interp = (tmplt0Interp-mean(tmplt0Interp))/norm(tmplt0Interp);
srOld = 508.625;
tOld = ((0:length(tmplt0)-1)/srOld)-0.04;
if toPlot
    plot(tOld,tmplt0)
    hold on
    tVec = ((0:length(tmplt0Interp)-1)/samplingRate)-0.041;
    plot(tVec, tmplt0Interp)
    axis tight
end

offset=16;  % depends on sampling rate
initialSNR = 3.5;
finalLint = true;

end

