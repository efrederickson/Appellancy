#import "FaceDetector.h"

NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";
const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@implementation FaceDetector

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *faceCascadePath;
        
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
            faceCascadePath = [NSString stringWithFormat:@"%@%@%@", @"/Library/Application Support/Appellancy/", kFaceCascadeFilename, @".xml"];
        else
            faceCascadePath = [[NSBundle mainBundle] pathForResource:kFaceCascadeFilename
                                                                    ofType:@"xml"];
        
        if (!_faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Could not load face cascade: %@", faceCascadePath);
            
            // Code-ception? :0
            faceCascadePath = [NSString stringWithFormat:@"%@%@%@", @"/Library/Application Support/Appellancy/", kFaceCascadeFilename, @".xml"];
            if (!_faceCascade.load([faceCascadePath UTF8String])) {
                NSLog(@"Could not load face cascade: %@", faceCascadePath);
            }
        }
    }
    
    return self;
}

- (std::vector<cv::Rect>)facesFromImage:(cv::Mat&)image
{
    std::vector<cv::Rect> faces;
    _faceCascade.detectMultiScale(image, faces, 1.1, 3, kHaarOptions, cv::Size(60, 60));
    
    return faces;
}

@end
