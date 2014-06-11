#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/contrib/contrib.hpp>

@interface OpenCVData : NSObject

+ (NSData *)serializeCvMat:(cv::Mat&)cvMat;
+ (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height;
+ (CGRect)faceToCGRect:(cv::Rect)face;
+ (UIImage *)UIImageFromMat:(cv::Mat)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace;
+ (CIImage*)imageFromMat:(cv::Mat)mat;
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
@end
