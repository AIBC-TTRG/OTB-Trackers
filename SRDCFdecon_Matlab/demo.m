
% This demo script runs the SRDCFdecon tracker on the included "Couple" video.

% Add paths
setup_paths();

% Load video information
video_path = '/home/linhan/huang/OTB/OTB-Person/OTB-100/Jogging';
% video_path = 'sequences/Couple';
[seq, ~] = load_video_info(video_path);

% Run the tracker using the test.m runfile
results = test(seq);