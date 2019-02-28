/*******************************************************************************
* Created by Qiang Wang on 16/7.24
* Copyright 2016 Qiang Wang.  [wangqiang2015-at-ia.ac.cn]
* Licensed under the Simplified BSD License
*******************************************************************************/
#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <cmath>

using namespace std;
using namespace cv;

void GetSubWindow(const Mat &frame, Mat &subWindow, Point centraCoor, Size sz, Mat &cos_window);

void CalculateHann(Mat &cos_window, Size sz);

void DenseGaussKernel(float sigma, const Mat &x, const Mat &y, Mat &k);

cv::Mat CreateGaussian1(int n, double sigma, int ktype);

cv::Mat CreateGaussian2(Size sz, double sigma, int ktype);

cv::Mat ComplexMul(const Mat &x1, const Mat &x2);

cv::Mat ComplexDiv(const Mat &x1, const Mat &x2);

static inline cv::Point2d centerRect(const cv::Rect& r)
{
  return cv::Point(r.x + cvFloor(double(r.width) / 2.0), r.y + cvFloor(double(r.height) / 2.0));
}

static inline cv::Rect scale_rect(const cv::Rect& r, float scale)
{
    cv::Point m=centerRect(r);
    float width  = r.width  * scale;
    float height = r.height * scale;
    int x=cvRound(m.x - width/2.0);
    int y=cvRound(m.y - height/2.0);
    
    return cv::Rect(x, y, cvRound(width), cvRound(height));
}

static inline cv::Size scale_size(const cv::Size& r, double scale)
{
    double width  = double(r.width)  * scale;
    double height = double(r.height) * scale;
    
    return cv::Size(cvFloor(width), cvFloor(height));
}

static inline cv::Size scale_sizexy(const cv::Size& r, float scalex,float scaley)
{
    float width  = r.width  * scalex;
    float height = r.height * scaley;
    
    return cv::Size(cvRound(width), cvRound(height));
}