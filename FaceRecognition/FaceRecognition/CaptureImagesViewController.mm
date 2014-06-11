#import "CaptureImagesViewController.h"
#import "OpenCVData.h"
#import <notify.h>
#import "ACvVideoCamera.h"

@implementation CaptureImagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    
    NSString *instructions = NSLocalizedString(@"INSTRUCTIONS_LABEL", @"");
    self.instructionsLabel.text = [NSString stringWithFormat:instructions, self.personName];
    
    [self setupCamera];
    
    UIAlertView *alert;
    
    if (self.personID == [NSNumber numberWithInt:1])
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                       message:NSLocalizedString(@"DENY_ENTRY", @"")
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        instructions = NSLocalizedString(@"DENY_ENTRY_INSTRUCTIONS", @"");
        self.instructionsLabel.text = instructions;
    }
    else
        alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                                    message:NSLocalizedString(@"INSTRUCTIONS_POPUP", @"")
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Switch" style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(barItemTap)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

-(void) viewDidDisappear:(BOOL)animated
{
    //if (self.videoCamera.running)
    //    [self.videoCamera stop];
    //self.videoCamera = nil;
    
    // Reload SpringBoard part
    notify_post("com.efrederickson.appellancy/reloadRecognizer");
        
    [super viewDidDisappear:animated];
}

-(void) barItemTap
{
    if (self.videoCamera.running)
        [self switchCameraButtonClicked:nil];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:NSLocalizedString(@"CANNOT_SWITCH_CAMERA_WARNING", @"")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setupCamera
{
    self.videoCamera = [[ACvVideoCamera alloc] initWithParentView:self.previewImage];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
}

- (void)processImage:(cv::Mat&)image
{
    // Only process every 60th frame (every 2s)
    if (self.frameNum == 30) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 1;
    }
    else {
        self.frameNum++;
    }
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (![self learnFace:faces forImage:image]) {
        return;
    };
    
    self.numPicsTaken++;
     
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self highlightFace:[OpenCVData faceToCGRect:faces[0]]];
        self.instructionsLabel.text = [NSString stringWithFormat:@"Taken %d of 5", (int)self.numPicsTaken];
        
        if (self.numPicsTaken == 5) {
            self.featureLayer.hidden = YES;
            [self.videoCamera stop];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done"
                                                            message:@"5 pictures have been taken."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            //[self.faceRecognizer saveModel];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
  
    });
}

- (bool)learnFace:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return NO;
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // Learn it
    [self.faceRecognizer learnFace:face ofPersonID:[self.personID intValue] fromImage:image];
    
    return YES;
}

- (void)noFaceToDisplay
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderColor = [[UIColor greenColor] CGColor];
            //[[UIColor redColor] CGColor];
        self.featureLayer.borderWidth = 4.0;
        [self.previewImage.layer addSublayer:self.featureLayer];
    }
    
    self.featureLayer.hidden = NO;
    self.featureLayer.frame = faceRect;
}

- (IBAction)cameraButtonClicked:(id)sender
{
    if (self.videoCamera.running){
        self.switchCameraButton.hidden = YES;
        self.libraryButton.hidden = NO;
        [self.cameraButton setTitle:@"Start" forState:UIControlStateNormal];
        self.featureLayer.hidden = YES;
        
        [self.videoCamera stop];
        
        self.instructionsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"INSTRUCTIONS_LABEL", @""), self.personName];
    } else {
        self.imageScrollView.hidden = YES;
        self.libraryButton.hidden = YES;
        [self.cameraButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.switchCameraButton.hidden = NO;
        // First, forget all previous pictures of this person
        //[self.faceRecognizer forgetAllFacesForPersonID:[self.personID integerValue]];
    
        // Reset the counter, start taking pictures
        self.numPicsTaken = 0;
        [self.videoCamera start];

        self.instructionsLabel.text = @"Taking pictures...";
    }
}

- (IBAction)switchCameraButtonClicked:(id)sender
{
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}
@end
