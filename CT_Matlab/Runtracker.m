% Demo for paper "Real-Time Compressive Tracking,"Kaihua Zhang, Lei Zhang, and Ming-Hsuan Yang
% To appear in European Conference on Computer Vision (ECCV 2012), Florence, Italy, October, 2012 
% Implemented by Kaihua Zhang, Dept.of Computing, HK PolyU.
% Email: zhkhua@gmail.com
% Date: 11/12/2011
% Revised by Kaihua Zhang, 15/12/2011
% Revised by Kaihua Zhang, 11/7/2012

clc;clear all;close all;
%----------------------------------
rand('state',0);
%----------------------------------
file = ['woman_CT.txt'];
%----------------------------------
finalPath = ['/home/kris-allen/AIBC/github/OTB/tracker/CT_MATLAB_v0/CT_code_v0/result/'];
%----------------------------------
load /home/kris-allen/AIBC/github/OTB/tracker/CT_MATLAB_v0/CT_code_v0/data/groundtruth_rect.txt;
initstate = groundtruth_rect;%initial tracker
%----------------------------Set path
img_dir = dir('/home/kris-allen/AIBC/github/OTB/tracker/CT_MATLAB_v0/CT_code_v0/data/*.jpg');
%---------------------------
filess = fullfile(finalPath,file);

img = imread(img_dir(1).name);
img = double(img(:,:,1));
%----------------------------------------------------------------
trparams.init_negnumtrain = 50;%number of trained negative samples
trparams.init_postrainrad = 4.0;%radical scope of positive samples
trparams.initstate = initstate;% object position [x y width height]
trparams.srchwinsz = 20;% size of search window
% Sometimes, it affects the results.
%-------------------------
% classifier parameters
clfparams.width = trparams.initstate(3);
clfparams.height= trparams.initstate(4);
%-------------------------
% feature parameters
% number of rectangle from 2 to 4.
ftrparams.minNumRect = 2;
ftrparams.maxNumRect = 4;
%-------------------------
M = 50;% number of all weaker classifiers, i.e,feature pool
%-------------------------
posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
posx.sig= ones(M,1);% variance of positive features
negx.sig= ones(M,1);
%-------------------------Learning rate parameter
lRate = 0.85;
%-------------------------
%compute feature template
[ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);
%-------------------------
%compute sample templates
posx.sampleImage = sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,50);
%-----------------------------------
%--------Feature extraction
iH = integral(img);%Compute integral image
posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
%--------------------------------------------------
[posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
%-------------------------------------------------
num = length(img_dir);% number of frames
%--------------------------------------------------------
x = initstate(1);% x axis at the Top left corner
y = initstate(2);
w = initstate(3);% width of the rectangle
h = initstate(4);% height of the rectangle
%--------------------------------------------------------

if exist(finalPath)
    fp = fopen(filess,'wt');
    fprintf(fp, '%10d', initstate);
    fprintf(fp,'\n');
    for i = 2:num
        img = imread(img_dir(i).name);
        imgSr = img;% imgSr is used for showing tracking results.
        img = double(img(:,:,1));
        detectx.sampleImage = sampleImg(img,initstate,trparams.srchwinsz,0,100000);   
        iH = integral(img);%Compute integral image
        detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
        %------------------------------------
        r = ratioClassifier(posx,negx,detectx);% compute the classifier for all samples
        clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
        %-------------------------------------
        [c,index] = max(clf);
        %--------------------------------
        x = detectx.sampleImage.sx(index);
        y = detectx.sampleImage.sy(index);
        w = detectx.sampleImage.sw(index);
        h = detectx.sampleImage.sh(index);
        initstate = [x y w h];
%         results{i} = initstate;
        [b1 b2]=size(initstate);
%         fprintf(fp,'%10d',i);
%         fprintf(fp,'%10d',' ');
        for k = 1:b1
            for l = 1:b2
                fprintf(fp, '%10d', initstate(k,l));
            end
        end
        fprintf(fp,'\n');
        %-------------------------------Show the tracking results
        imshow(uint8(imgSr));
        rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
        hold on;
        text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
        set(gca,'position',[0 0 1 1]); 
        pause(0.00001); 
        hold off;
        %------------------------------Extract samples  
        posx.sampleImage = sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
        negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
        %--------------------------------------------------Update all the features 
        posx.feature = getFtrVal(iH,posx.sampleImage,ftr);
        negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
        %--------------------------------------------------
        [posx.mu,posx.sig,negx.mu,negx.sig] = classiferUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
    end
    fclose(fp);
end
% results = results';

% 
% for j = 1:length(results)
%     resultss = results{j};
%     save(filess,'resultss');
% end