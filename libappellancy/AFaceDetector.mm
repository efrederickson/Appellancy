#import "AFaceDetector.h"
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/contrib/contrib.hpp>
#import "FaceDetector.h"
#import "CustomFaceRecognizer.h"
#import "OpenCVData.h"
#import <notify.h>
#import "ACvVideoCamera.h"
#define CAPTURE_FPS 15

//static FaceDetector *faceDetector;
static CustomFaceRecognizer *faceRecognizer;
static BOOL modelAvailable;

// From http://opencv-code.com/quick-tips/how-to-rotate-image-in-opencv/
void rotate(cv::Mat& src, double angle, cv::Mat& dst)
{
    int len = std::max(src.cols, src.rows);
    cv::Point2f pt(len/2., len/2.);
    cv::Mat r = cv::getRotationMatrix2D(pt, angle, 1.0);
    
    cv::warpAffine(src, dst, r, cv::Size(len, len));
}

@interface AFaceDetector ()
{
    NSMutableArray *delegates;
}
@property (nonatomic) NSInteger frameNum;
@property (nonatomic, strong) FaceDetector *faceDetector;
- (void)processImage:(cv::Mat&)image;
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@end

@interface CvVideoCamera ()
-(void) pause;
@end

@implementation AFaceDetector

+(AFaceDetector*) sharedDetector
{
    static AFaceDetector *detector;
    if (detector == nil)
    {
        //NSLog(@"Appellancy: creating AFaceDetector");
        detector = [[AFaceDetector alloc] init];
    }
    
    return detector;
}

-(BOOL) isDelegateRegistered:(id)delegate
{
    return [delegates indexOfObject:delegate] != NSNotFound;
}

-(void) registerDelegate:(id)delegate
{
    if ([self isDelegateRegistered:delegate] || delegate == nil)
        return;
    
    [delegates addObject:delegate];
}
-(void) deregisterDelegate:(id)delegate
{
    if (![self isDelegateRegistered:delegate] || delegate == nil)
        return;

    NSUInteger num = [delegates indexOfObject:delegate];
    if (NSNotFound == num)
        return;
    [delegates removeObjectAtIndex:num];
}
-(void) changeImageView:(UIImageView*)newImageView
{
    self.videoCamera.parentView = newImageView;
}


-(id) init
{
    delegates = [[NSMutableArray alloc] init];
    self.faceDetector = [[FaceDetector alloc] init];
    
    if (!faceRecognizer)
    {
        faceRecognizer = [[CustomFaceRecognizer alloc] initWithEigenFaceRecognizer];
            
        modelAvailable = [faceRecognizer trainModel];
    }
    
    [self initCamera];

    return [super init];
}

-(void) initCamera
{
    self.videoCamera = [[ACvVideoCamera alloc] init];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    self.videoCamera.grayscaleMode = NO;
}

- (void)processImage:(cv::Mat&)image
{
    if (self.frameNum == 30) {
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

        switch (orientation) {
            case UIDeviceOrientationPortraitUpsideDown:
                cv::resize(image, image, cv::Size(300, 300), 0, 0);
                rotate(image, 180, image);
                break;
            case UIDeviceOrientationLandscapeLeft:
                rotate(image, 90, image);
                break;
            case UIDeviceOrientationLandscapeRight:
                rotate(image, -90, image);
                break;
                
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
            case UIDeviceOrientationUnknown:
            case UIDeviceOrientationPortrait:
            default:
                //rotate(image, 0, image);
                break;
        }
        
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 0;
    }
    
    self.frameNum++;
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    // No faces found
    if (faces.size() != 1) {
        return;
    }
    //NSLog(@"Appellancy: face detected");
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // Unless the database is empty, try a match
    if (modelAvailable) {
        NSDictionary *match = [faceRecognizer recognizeFace:face inImage:image];
        
        // Match found
        if ([match objectForKey:@"personID"] != [NSNumber numberWithInt:-1] && [match objectForKey:@"personID"] != [NSNumber numberWithInt:1]) { // -1 = not found, 1 = <empty> (the sample one to capture the wrong people)
            for (id delegate in delegates)
            {
                if (delegate && [delegate respondsToSelector:(@selector(faceRecognized:confidence:))])
                {
                    [delegate faceRecognized:[match objectForKey:@"personName"] confidence:[[match objectForKey:@"confidence"] intValue]];
                }
            }
        }
        else
        {
            for (id delegate in delegates)
            {
                if (delegate && [delegate respondsToSelector:(@selector(faceRejected))])
                {
                    [delegate faceRejected];
                }
            }
        }
    }
}

-(void) start
{
    if (![self running])
        [self.videoCamera start];
}

-(void) stop
{
    if ([self running])
        [self.videoCamera pause];
}

-(BOOL) running
{
    return self.videoCamera.running;
}

#if !__has_feature(objc_arc)
-(void) dealloc
{
    [self.videoCamera release];
    self.videoCamera = nil;
    delegates = nil;
    [super dealloc];
}
#endif

-(void) reloadDatabase
{
    if ([self running])
        [self.videoCamera pause];
    faceRecognizer = nil;
    faceRecognizer = [[CustomFaceRecognizer alloc] initWithEigenFaceRecognizer];
    modelAvailable = [faceRecognizer trainModel];
}
@end