function [ fold_num, status,fName] = find_next_run( base_path,output_file_name_format,vals_range )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
status = 0;
fold_num=nan;
fName = '';
cur_perm = randperm(length(vals_range));

for ii = 1:length(vals_range)
    if exist([base_path,'/',output_file_name_format,num2str(vals_range(cur_perm(ii))),'.txt'],'file')==0
        fName = [base_path,'/',output_file_name_format,num2str(vals_range(cur_perm(ii))),'.txt'];         %# A file name
        fid = fopen(fName,'w');                                                               %# Open the file
        if fid ~= -1
            fprintf(fid,'%s\r\n','Running...');                                               %# Print the string
            fclose(fid);                                                                      %# Close the file
        end
        fold_num = vals_range(cur_perm(ii));
        status = 1;
        break
    end

end

end