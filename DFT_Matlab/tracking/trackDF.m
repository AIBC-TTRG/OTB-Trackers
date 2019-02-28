% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function positions = trackDF(params)

%%% INPUT PARAMETERS FOR IMAGE SEQUENCE 

% -- file_path: path where frame sequence is found, including the invariant
% part of the frames name 
% -- file_format: string containing the format of the frames 
% -- output_name: name of the output file with the results of tracking 
% -- start_fr: number of the first frame where the target appears 
% -- end_fr: number of the last frame where you want to track the target
% -- init_pos: position of the target in the first frame, specified as [row, col]
% -- wsize: size of target specified as [height, width]

%%% INPUT PARAMETERS FOR DISTRIBUTION FIELDS 

% -- nbins: number of bins used to quantize the feature space in a DF  
% -- feat_width: width of kernel for convolving a DF in feature space 
% -- feat_sig: std dev of the gaussian kernel for convolving a DF in feat space
% -- sp_width: set of widths of the kernels for convolving a DF in image space
% -- sp_sig: set of std devs of the gaussian kernels for convolving a DF in image space
% -- max_shift: maximum number of pixels the target is expected to move 

%%% OUTPUT

% -- positions: n-by-2 array containing the positions of the object at each
% frame 


% rename variables for clarity
start_fr = params.start_fr;
end_fr = params.end_fr;
init_pos = params.init_pos;
wsize = params.wsize;
nbins = params.nbins;
feat_width = params.feat_width; 
feat_sig = params.feat_sig;
sp_width = params.sp_width;
sp_sig = params.sp_sig;
max_shift = params.max_shift;


% Read first frame and crop target
f1 = double(imread(sprintf('%s%d.%s', params.file_path, 1, params.file_format)));

% f1 = f1(init_pos(1):init_pos(1)+wsize(1)-1, init_pos(2):init_pos(2)+wsize(2)-1);
f1 = imcrop(f1,[269,75,63,33]);
disp(size(f1));
% Compute and smooth DF of target with different levels of blur
df = img2df(f1, nbins);
for i=1:length(sp_width)
    target_models{i} = smoothDF(df, [sp_width(i) feat_width], [sp_sig(i), feat_sig]);
end;

% create the name of the files to save the results 
pos_file = sprintf('%s.mat', params.output_name);

% track the object along the sequence 
num_frames = end_fr - start_fr; 
positions = zeros(num_frames, 2);
last_motion = [0, 0];

fprintf('Processing frame number \n');

for i=1:num_frames

    % read image
    f2 = double(imread(sprintf('%s%d.%s', params.file_path, i+start_fr, params.file_format)));
    % compute new starting position using last motion
    init_pos = computeStartingPoint(init_pos, last_motion, wsize, size(f2));
    % crop the image around the starting position for speed
    crop_params = computeCropParams(init_pos, size(f2), wsize, max_shift, sp_width(end));
    f2 = f2(crop_params(1):crop_params(1)+crop_params(3)-1, crop_params(2):crop_params(2)+crop_params(4)-1);
    
    % find target in frame 
    pts = findTargetHier(target_models, f2, init_pos-crop_params(1:2)+1, wsize, sp_width, sp_sig, feat_width, feat_sig, nbins); 
    end_pos = pts(end, :);
    
    % update target model 
    f2 = f2(end_pos(1):end_pos(1)+wsize(1)-1, end_pos(2):end_pos(2)+wsize(2)-1);
    df2 = img2df(f2, nbins);
    for j = 1:length(sp_width)
        df2_s = smoothDF(df2, [sp_width(j) feat_width], [sp_sig(j), feat_sig]);
        target_models{j} = 0.95.*target_models{j} + 0.05.*df2_s;
    end;
    
    % store result
    end_pos = end_pos+crop_params(1:2)-1;
%     disp(end_pos);
    positions(i, :) = end_pos;
    fprintf(1,' %d ', i);
    if mod(i, 10) == 0
        fprintf('\n');
    end;
    last_motion = end_pos - init_pos;
    init_pos = end_pos; 
    save(pos_file, 'positions');

end;


