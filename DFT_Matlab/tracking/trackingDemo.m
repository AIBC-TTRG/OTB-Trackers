
% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************


% default input parameters 

file = ['bolt2_CT.txt'];
vidoefile = ['bolt2_CT'];
outputPath = '/home/kris-allen/AIBC/github/OTB/tracker/DFT/tracking/result/video/';
filepath = '/home/kris-allen/AIBC/github/OTB/tracker/DFT/tracking/data/Bolt2/img(reorder)/';
finalpath = '/home/kris-allen/AIBC/github/OTB/tracker/DFT/tracking/result/bounding-box/';

load /home/kris-allen/AIBC/github/OTB/tracker/DFT/tracking/data/Bolt2/groundtruth_rect_handle2.txt;
initstate = groundtruth_rect;
result = fullfile(finalpath,file);

disp(initstate(1,:));

params.file_path = filepath;
params.file_format = 'jpg';
% disp(fullfile(outputPath,vidoefile));
params.output_name = fullfile(outputPath,vidoefile);
params.start_fr = 1;
params.end_fr = 293; 
params.init_pos = [initstate(1,1), initstate(1,2)];
params.wsize = [initstate(1,3), initstate(1,4)];

params.nbins = 16; 
params.feat_width = 5; 
params.feat_sig = 0.625; 
params.sp_width = [9, 15];
params.sp_sig = [1, 2];
params.max_shift = 30;

% track target along sequence 
positions = trackDF(params); 
% disp(positions);
% render video of the track (and show the images if you choose to)
show_track = 1;
fp = fopen(result,'wt');
fprintf(fp, '%10d', initstate(1,:));
fprintf(fp,'\n');
[b1, b2]=size(positions);
for k = 1:b1
    for l = 1:b2
        fprintf(fp, '%10d', positions(k,l));
    end
    fprintf(fp, '%10d', initstate(1,3:4));
    fprintf(fp,'\n');
end



fclose(fp);

disp(size(positions));
% disp(params);
% track2video(positions, params.output_name, params.file_path, params.file_format, params.start_fr, params.wsize, show_track);



