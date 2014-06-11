#import <opencv2/highgui/cap_ios.h>
#import <opencv2/contrib/contrib.hpp>
#import "FaceDetector.h"
#import "CustomFaceRecognizer.h"
#import "OpenCVData.h"

@interface AFaceDetector : NSObject <CvVideoCameraDelegate>

+(AFaceDetector*) sharedDetector;

-(void) start;
-(void) stop;
-(BOOL) running;

-(void) reloadDatabase;

-(void) registerDelegate:(id)delegate;
-(void) deregisterDelegate:(id)delegate;
-(void) changeImageView:(UIImageView*)newImageView;

@end

@protocol AFaceDetectorProtocol
-(void)faceRecognized:(NSString*)recognized confidence:(int)confidence;
-(void)faceRejected;
@end
