### Check out <a href="https://github.com/martin-danelljan/ECO">our more recent tracker ECO</a>, which is based on C-COT. ECO achieves a <b>20-fold speedup</b> and further performance improvements compared to C-COT.


# Continuous-ConvOp

This MATLAB code implements Continuous Convolution Operator Tracker (C-COT).

It is the top-ranked tracker in the Visual Object Tracking (VOT) challenge 2016. [9]


## Publication

Details about the tracker can be found in the ECCV 2016 paper:

Martin Danelljan, Andreas Robinson, Fahad Khan, Michael Felsberg.  
"Beyond Correlation Filters: Learning Continuous Convolution Operators for Visual Tracking."  
In Proceedings of the European Conference on Computer Vision (ECCV), 2016.  
[<a href="http://www.cvl.isy.liu.se/research/objrec/visualtracking/conttrack/C-COT_ECCV16.pdf">PDF</a>] [<a href="http://www.cvl.isy.liu.se/research/objrec/visualtracking/conttrack/C-COT_ECCV16_suppl.pdf">Supplementary</a>]

Please cite the above publication if you use the code or compare with our C-COT tracker in your work. Bibtex entry:

@InProceedings{DanelljanECCV2016,  
  Title = {Beyond Correlation Filters: Learning Continuous Convolution Operators for Visual Tracking},  
  Author = {Danelljan, Martin and Robinson, Andreas and Shahbaz Khan, Fahad and Felsberg, Michael},  
  Booktitle = {ECCV},  
  Year = {2016},  
}


## Project Webpage

http://www.cvl.isy.liu.se/research/objrec/visualtracking/conttrack/index.html


## Contact

Martin Danelljan

Email: martin.danelljan@liu.se  
Webpage: http://users.isy.liu.se/cvl/marda26/


## Installation

### Using git clone

1. Clone the GIT repository:

   $ git clone https://github.com/martin-danelljan/Continuous-ConvOp.git

2. Clone the submodules.  
   In the repository directory, run the commands:

   $ git submodule init  
   $ git submodule update

3. Start Matlab and navigate to the repository.  
   Run the install script:

   |>> install

4. Run the demo script to test the tracker:

   |>> demo


Note:  
This package requires matconvnet [1], if you want to use deep CNN features, and PDollar Toolbox [2], if you want to use HOG features. Both these externals are included as git submodules and should be installed by following step 2. above.


### Without using git

You could also downlad and install without using git. This is however not recommented since it will be harder to incorporate updates and you will not get the correct versions of matconvnet and PDollar Toolbox.

1. Download ZIP file from https://github.com/martin-danelljan/Continuous-ConvOp and unpack it somewhere.

2. Download matconvnet ZIP file from https://github.com/vlfeat/matconvnet and unpack it in the external_libs/matconvnet/ folder of the repository.
   
   Download PDollar Toolbox ZIP file from https://github.com/pdollar/toolbox and unpack it in the external_libs/pdollar_toolbox/ folder of the repository.

Lastly, perform steps 3. and 4. above.


## Description and Instructions

### Runfiles

The files in the runfiles/ directory are uset to set parameters and run the tracker. You can create your own runfiles by copying an existing one and then play around with different parameters and feature combinations. 

These runfiles are included:

* ECCV2016_settings.m  -  Contains the parameter settings that were used in the ECCV 2016 paper.

* VOT2016_settings.m  -  Contains the parameter settings that were used in the Visual Object Tracking (VOT) 2016 challenge submission.

* CNN_HOG_settings.m  -  Employs Deep CNN features and HOG for the best performance.

* HOG_CN_settings.m  -  Employs only HOG and Color Names [6] features with cell sizes 6 and 4 respectively. This version is faster and does not require matconvnet.

* HOG_settings.m  -  Employs only HOG features. Similar to SRDCF but significantly faster (13 mean FPS on OTB-2015).

* testing.m  -  Has the same settings as in ECCV2016_settings.m by default, but can be used for playing around with parameters and features.

Tracking performance on the OTB-2015 dataset is shown bellow for different runfile settings. For comparison, results of our previous trackers DSST [3], SRDCF [4] and DeepSRDCF [5] are included.

<img src="https://github.com/martin-danelljan/Continuous-ConvOp/blob/master/result_plots/OTB-2015_succsess_plot.png" alt="Could not display image" height=400 width=500>


### Features

This package includes a quite general framework for feature extraction. You can easily incorporate your own features in the same manner by adding a corresponding "get_featureX.m" function.

Currently, four types of features are included:

1. Deep CNN features. It uses matconvnet [1], which is included as a git submodule in external_libs/matconvnet/. The imagenet-vgg-m-2048 network available at http://www.vlfeat.org/matconvnet/pretrained/ was used in the ECCV paper. You can use other networks, by placing them in the feature_extraction/networks/ folder.

2. HOG features. It uses the PDollar Toolbox [2], which is included as a git submodule in external_libs/pdollar_toolbox/.

3. Lookup table features. These are implemented as a lookup table that directly maps an RGB or grayscale value to a feature vector. Currently, Color Names [6] and Intensity Channels [7] are included.

4. Colorspace features. Currently grayscale and RGB are implemented.

The tracker supports almost any combination of features. Currently, the only limitation is that you can only use deep features from a single network (but you can use several different layers from the same network).

Each feature has its own parameter settings. You can set the cell size for each non-CNN feature independently. Unlike previous correlation based trackers, C-COT does not assume the same cell size for all feature channels. For the CNN features, you can control the cell size by setting an additional down-sampling factor for each layer.

See the runfile testing.m for examples of how to integrate different features. You can uncomment several features at once in the params.t_features cell array.


### Integration Into OTB

It should be easy to integrate the tracker into the Online Tracking Benchmark [8]. The runfiles supports the OTB interface, so you just have to copy and rename the runfile you want to use and then add the necessary paths (see setup_paths.m).


### Integration Into VOT

To integrate the tracker into the Visual Object Tracking (VOT) challenge toolkit [9], check the VOT_integration folder. Copy the configuration file to your VOT workspace and set the path to the CCOT reposetory inside it. 


### A Note on Results

This code contains some minor updates and fixes compared to the code used for producing the results in our ECCV 2016 paper. This should however only have a marginal effect on performance (less than 0.5% on the OTB 2015 dataset). Tracking performance can also vary slightly on different machines and Matlab versions.

All raw result files used in our ECCV paper can be found at the project webpage:
http://www.cvl.isy.liu.se/research/objrec/visualtracking/conttrack/index.html

If you, for some reason, want to run the exact same version of the code as used in our ECCV 2016 paper, please send an email to martin.danelljan@liu.se.


## Acknowledgments

Gustav Häger has contributed with some of the implementation, mainly regarding feature extraction.


## References

[1] Webpage: http://www.vlfeat.org/matconvnet/  
    GitHub repository: https://github.com/vlfeat/matconvnet

[2] Piotr Dollár.  
    "Piotr’s Image and Video Matlab Toolbox (PMT)."  
    Webpage: https://pdollar.github.io/toolbox/  
    GitHub repository: https://github.com/pdollar/toolbox  

[3] Martin Danelljan, Gustav Häger, Fahad Shahbaz Khan and Michael Felsberg.  
    Accurate Scale Estimation for Robust Visual Tracking.  
    In Proceedings of the British Machine Vision Conference (BMVC), 2014.  
    http://www.cvl.isy.liu.se/research/objrec/visualtracking/scalvistrack/index.html
    
[4] Martin Danelljan, Gustav Häger, Fahad Khan, Michael Felsberg.  
    Learning Spatially Regularized Correlation Filters for Visual Tracking.  
    In Proceedings of the International Conference in Computer Vision (ICCV), 2015.  
    http://www.cvl.isy.liu.se/research/objrec/visualtracking/regvistrack/index.html

[5] Martin Danelljan, Gustav Häger, Fahad Khan, Michael Felsberg.  
    Convolutional Features for Correlation Filter Based Visual Tracking.  
    ICCV workshop on the Visual Object Tracking (VOT) Challenge, 2015.  
    http://www.cvl.isy.liu.se/research/objrec/visualtracking/regvistrack/index.html

[6] J. van de Weijer, C. Schmid, J. J. Verbeek, and D. Larlus.  
    Learning color names for real-world applications.  
    TIP, 18(7):1512–1524, 2009.  

[7] M. Felsberg.  
    Enhanced distribution field tracking using channel representations.  
    In ICCV Workshop, 2013.

[8] Y. Wu, J. Lim, and M.-H. Yang.  
    Online object tracking: A benchmark.  
    In CVPR, 2013.  
    https://sites.google.com/site/trackerbenchmark/benchmarks/v10

[9] http://votchallenge.net/
