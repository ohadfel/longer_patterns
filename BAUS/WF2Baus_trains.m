[base_path,baseDirName_input,baseDirName_output,wtsOutDirName,outDirName ] = set_subject_params(sub_num);

%% Start here after creating CCDs
cd(outDirName)
[CCD, numChans, numData]=load_CCD_and_normalized(outDirName);
[tmplt0Interp,offset,initialSNR,finalLint]=load_template_and_interpolate(base_path,0);


cd ..
range_of_snrs = 1.5:0.1:3.5;
BAUratePerChnMat = zeros(1024,length(range_of_snrs));
for ii=1:length(range_of_snrs)
cur_snr = range_of_snrs(ii)
cur_snr_str = num2str(cur_snr);
cur_snr_str(cur_snr_str=='.')='p';
load(['/cortex/data/MEG/Baus/CCdata/102/matlabData/getPCs4AllOPnew_SNR_',cur_snr_str,'.mat'])
[~,~,BAUrate,BAUratePerChn] = split_wf_to_polarity(CCD,WF1,samplingRate);
BAUratePerChnMat(:,ii) = BAUratePerChn;
end

figure;
boxplot(BAUratePerChnMat)
hold on
plot(1:length(range_of_snrs),ones(length(range_of_snrs),1)*2,'--g')
plot(1:length(range_of_snrs),ones(length(range_of_snrs),1)*3,'--g')
set(gca,'XTick',1:5:21)
set(gca,'XTickLabel',{'1.5','2','2.5','3','3.5'})
xlabel('SNR')
ylabel('Mean BAUs rate')
axis tight
set(gca,'fontsize',16)
hold off


balls = create_pnts( baseDirName_input, baseDirName_output);
num_of_baus = median(BAUratePerChnMat');
figure;
ax1 = subplot(1,2,1)
scatter3(balls(:,1),balls(:,2),balls(:,3),ones(512,1)*40,num_of_baus(1:2:1024),'o','filled')
colormap jet
colorbar
ax2 = subplot(1,2,2)
scatter3(balls(:,1),balls(:,2),balls(:,3),ones(512,1)*40,num_of_baus(2:2:1024),'o','filled')
colormap jet
colorbar
hlink = linkprop([ax1,ax2],{'CameraPosition','CameraUpVector'}); 
rotate3d on
