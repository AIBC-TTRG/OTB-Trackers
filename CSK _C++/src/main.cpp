/*******************************************************************************
* Created by Qiang Wang on 16/7.24
* Copyright 2016 Qiang Wang.  [wangqiang2015-at-ia.ac.cn]
* Licensed under the Simplified BSD License
*******************************************************************************/
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include "opencv2/opencv.hpp"
#include "csk.h"
#include <stdlib.h>
#include <stdio.h>
// #include "benchmark_info.h"

using namespace std;
using namespace cv;


char root_path[128] = "/home/aibc/Wen/CSK/sequence/OTB-100";
char dataset_name[128] = "Subway";
char groundtruth_name[128] = "groundtruth_rect_handle2.txt";
char frame_name[128] = "Subway_image_name.txt";
char image_path[128];
char groundtruth_path[128];
char frame_path[128];
char result_path[128];
// string benchmark_path = "E:/100Benchmark/";
// string video_name = "Tiger1";
// string video_path = benchmark_path + video_name +"/";
vector<Rect> groundtruth_rect;
vector<String>img_files;
stringstream ss;


int main(){
	cout << "starting..." << endl;
	// groundtruth_rect[0].x -= 1;     //cpp is zero based
 //    groundtruth_rect[0].y -= 1;
  // if (load_video_info(video_path, groundtruth_rect, img_files) != 1)
		// return -1;
	// string framesFilePath = "/home/kris-allen/AIBC/github/OTB/tracker/struck/" + conf.sequenceBasePath+"/"+conf.sequenceName+"/"+conf.sequenceName+"_image_name.txt";
	double _x;
	double _y;
	double _width;
	double _height;
	unsigned int num;
	stringstream __x;
	stringstream __y;
	stringstream __width;
	stringstream __height;
	sprintf(groundtruth_path, "%s/%s/%s", root_path, dataset_name, groundtruth_name);		
	sprintf(frame_path, "%s/%s/%s", root_path, dataset_name, frame_name);
	sprintf(image_path, "%s/%s/img(reorder)", root_path, dataset_name);
	// ifstream framesFile(framesFilePath.c_str(), ios::in);


	ifstream groundtruthFile(groundtruth_path);
	ifstream framesFile(frame_path);
	cout << "get File corretly" << endl;

	if (!groundtruthFile)
	{
		cout << "error: could not open groundtruth file: " << groundtruth_path << endl;
		return EXIT_FAILURE;
	}
	string groundtruthLine;
	getline(groundtruthFile, groundtruthLine);
	stringstream groundtruthfile(groundtruthLine);

	cout << "get line corretly" << endl;
	// cout << groundtruthfile << endl;

	groundtruthfile >> _x >> _y >> _width >> _height;

	printf("get number correctly\n");
	Rect rect;
	
	rect.x = _x ;
	rect.y = _y ;
	rect.width = _width;
	rect.height = _height;
	groundtruth_rect.push_back(rect);
  Point pos = centerRect(groundtruth_rect[0]);

	printf("get coordinate correctly\n");
    double padding = 2;
    double output_sigma_factor = 1./16;
    double sigma = 0.2;
    double lambda = 1e-2;
    double interp_factor = 0.075;

    // groundtruth_rect[0].x -= 1;     //cpp is zero based
    // groundtruth_rect[0].y -= 1;
    // Point pos = centerRect(groundtruth_rect[0]);
    Size target_sz(groundtruth_rect[0].width, groundtruth_rect[0].height);
    bool resize_image = false;
    if (std::sqrt(target_sz.area()) >= 1000){
      pos.x = cvFloor(double(pos.x) / 2);
    	pos.y = cvFloor(double(pos.y) / 2);
	    target_sz.width = cvFloor(double(target_sz.width) / 2);
	    target_sz.height = cvFloor(double(target_sz.height) / 2);
	    resize_image = true;
    }
    Size sz = scale_size(target_sz, (1.0+padding));
  
  
  double output_sigma = sqrt(double(target_sz.area())) * output_sigma_factor;
	Mat y = CreateGaussian2(sz, output_sigma, CV_64F);
	Mat yf;
	dft(y, yf, DFT_COMPLEX_OUTPUT);
	  
	Mat cos_window(sz, CV_64FC1);
	CalculateHann(cos_window, sz);

	Mat im;
	Mat im_gray;
	Mat z,new_z;
	Mat alphaf, new_alphaf;
	Mat x;
	Mat k, kf;
	Mat response;
	double time = 0;
	int64 tic,toc;

	vector<String> files;
	glob(image_path, files, true);
	size_t image_num = files.size();

	// cout << "image_num:" << image_num << endl;//597
	// cout << "img_files.size():" << img_files.size() << endl;

	// for (int frame = 0; frame < img_files[frame].size(); ++frame)
  for (int frame = 1; frame < image_num + 1; ++frame)
  	// image_name = fprintf(stderr, "%s\n", );
	{
		
		sprintf(image_path, "%s/%s/img(reorder)/%d.jpg", root_path, dataset_name, frame );
	  im = cv::imread(image_path, IMREAD_COLOR);
		// printf("im\n");
		im_gray = imread(image_path, IMREAD_GRAYSCALE);
		// printf("im_gary\n");

		// cout << im.size() << endl;
		
    // im = imread(img_files[frame], IMREAD_COLOR);
    // im_gray = imread(img_files[frame], IMREAD_GRAYSCALE);
    if (resize_image){
			// printf("resizeim\n");
      resize(im, im, im.size() / 2, 0, 0, INTER_CUBIC);
			// printf("resizeim_gary\n");
      resize(im_gray, im_gray, im.size() / 2, 0, 0, INTER_CUBIC);
    }

		tic = getTickCount();
		GetSubWindow(im_gray, x, pos, sz, cos_window);
		
		// printf("frame>0\n");
		// if (frame > 0)
		if (frame > 1)
		{
			DenseGaussKernel(sigma, x, z, k);
      dft(k, kf, DFT_COMPLEX_OUTPUT);
			cv::idft(ComplexMul(alphaf,kf), response, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT); // Applying IDFT
			Point maxLoc;
			// printf("MaxLoc\n");
			minMaxLoc(response, NULL, NULL, NULL, &maxLoc);
			pos.x = pos.x - cvFloor(float(sz.width) / 2.0) + maxLoc.x+1;
      pos.y = pos.y - cvFloor(float(sz.height) / 2.0) + maxLoc.y+1;
		}
		
		// printf("subwindow\n");
		//get subwindow at current estimated target position, to train classifer
		GetSubWindow(im_gray, x, pos, sz, cos_window);

		// printf("GuassKernel\n");
		DenseGaussKernel(sigma, x, x, k);
		// printf("dft\n");
    dft(k, kf, DFT_COMPLEX_OUTPUT);
		// printf("1\n");
    new_alphaf = ComplexDiv(yf, kf + Scalar(lambda, 0));
		// cout << "new_alphaf:" << new_alphaf << endl;
		// printf("2\n");
		new_z = x;

		// if (frame == 0)
		if (frame == 1)
		{
			alphaf = new_alphaf;
			z = x;
		}
		else
		{
			alphaf = (1.0 - interp_factor) * alphaf + interp_factor * new_alphaf;
			z = (1.0 - interp_factor) * z + interp_factor * new_z;
		}
		// printf("3\n");
		toc = getTickCount() - tic;
		time += toc;
		// printf("4\n");
		Rect rect_position(pos.x - target_sz.width /2, pos.y - target_sz.height/2, target_sz.width, target_sz.height);
		// printf("5\n");
		rectangle(im, rect_position, Scalar(0, 255, 0), 2);
		ss << frame;
		// printf("6\n");
		putText(im, ss.str(), Point(20, 40), 6, 1, Scalar(0, 255, 255), 2);
		// imshow(video_name, im);
		char key = waitKey(1);
		// printf("7\n");
		if (key == 27)
			break;
		
		cout << "rect_position:" << rect_position << endl;

		std::fstream resultFS;
		resultFS.open("/home/aibc/Wen/CSK/groundtruth_result/OTB-100/subway_CSK.txt", std::fstream::out | std::fstream::app);
		if (!resultFS.is_open() || !resultFS.good())
		{
			std::cerr << "Error: open() error" << std::endl;
			return -1;
		}
		resultFS << rect_position.x << " " <<  rect_position.y << " " << rect_position.width << " " << rect_position.height << std::endl;
		resultFS.close();


	}
	// printf("8\n");
	time = time / getTickFrequency();
  std::cout << "Time: " << time << "    fps:" << (image_num + 1)/ time << endl;
    waitKey();
	return 0;
}