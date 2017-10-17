function [ CCD, numChans, numData,samplingRate ] = load_CCD_and_normalized( outDirName )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
load(fullfile(outDirName , 'CCD8to60'));
for ccdI = 1 : size(CCD,1)
    if mod(ccdI,100)==0
        disp(ccdI);
    end
    CCD(ccdI,:) = (CCD(ccdI,:)-mean(CCD(ccdI,:)))/norm(CCD(ccdI,:));
end

[numChans, numData] = size(CCD);

end