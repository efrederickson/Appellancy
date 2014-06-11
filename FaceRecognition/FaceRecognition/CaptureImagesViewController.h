#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "FaceDetector.h"
#import "CustomFaceRecognizer.h"
#import "ACvVideoCamera.h"

@interface CaptureImagesViewController : UIViewController <CvVideoCameraDelegate>

@property (nonatomic, strong) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (strong, nonatomic) IBOutlet UIButton *libraryButton;
@property (nonatomic, strong) IBOutlet UIImageView *previewImage;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSNumber *personID;
@property (nonatomic, strong) FaceDetector *faceDetector;
@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) ACvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) NSInteger numPicsTaken;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;

- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)switchCameraButtonClicked:(id)sender;

@end
