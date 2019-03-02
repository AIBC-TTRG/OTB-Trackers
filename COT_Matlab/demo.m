
% This demo script runs the C-COT on the included "Crossing" video.

% Add paths
setup_paths();

file = 'girl2_COT1.txt';
finalPath = '/home/aibc/Documents/xiangmu/matlab/COT/result/';
filess = fullfile(finalPath,file);

% Load video information
video_path = 'sequences/OTB-100/Girl2';

[seq, ground_truth] = load_video_info(video_path);
%%
% 
%  PREFORMATTED
%  TEXT
% 
fp = fopen(filess,'wt');
% Run C-COT                              
results = testing(seq);

positions = results.res;



[b1 b2]=size(positions);
for k = 1:b1
    for l = 1:b2
        fprintf(fp, '%10d', positions(k,l));              
    end
    fprintf(fp,'\n');
end
disp(results.res);
fclose(fp);
