#ifndef __BENCHMARK_INFO_H__
#define __BENCHMARK_INFO_H__

#ifdef __cplusplus
extern "C"
{

#include <iostream>
#include <string>
#include <vector>
#include <regex>
#include <fstream>
#include <sstream>
#include <opencv2/opencv.hpp>
// #include <opencv/io.h>
using namespace std;
using namespace cv;


int load_video_info(string base_path, string video_name, vector<Rect> &groundtruthRect, vector<String> &fileName);

void getFiles(string path, vector<string>& files, vector<string>& names);

#ifdef __cplusplus
}

#endif // __cplusplus

#endif // __BENCHMARK_INFO_H__
#endif

/*******************************************************************************
* Created by Qiang Wang on 16/7.24
* Copyright 2016 Qiang Wang.  [wangqiang2015-at-ia.ac.cn]
* Licensed under the Simplified BSD License
*******************************************************************************/
