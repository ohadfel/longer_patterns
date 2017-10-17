function [ decimated_mat ] = my_decimate( matrix,factor )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
decimated_mat = nan(size(matrix,1),round(size(matrix,2)/factor)+1);
figure;
cur_slices = nan(1,size(decimated_mat,2));
for ii=1:size(decimated_mat,2)
    cur_range = ((ii-1)*factor - factor/2+1):((ii-1)*factor+factor/2);
    cur_range(cur_range<1 | cur_range>size(matrix,2))='';
    cur_slices(ii)=cur_range(end);
%     cur_range = max(1,((ii-1)*factor/2+1)):ii*factor/2;
    decimated_mat(:,ii) = sum(matrix(:,cur_range),2);
end
[qq,ww]=find(matrix);
plot(ww,qq,'*')
hold on
[qq1,ww1]=find(decimated_mat);
plot((ww1-1)*factor,qq1,'r*')
for ii=1:length(cur_slices)
    vline(cur_slices(ii),'g')
end



end
