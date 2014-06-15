@class UIImageView;

@interface AFaceDetector : NSObject

+(AFaceDetector*) sharedDetector;

-(void) start;
-(void) stop;
-(BOOL) running;

-(void) reloadDatabase;

-(void) registerDelegate:(id)delegate;
-(void) deregisterDelegate:(id)delegate;
-(void) changeImageView:(UIImageView*)newImageView;

-(void) reloadDatabase;

@end

@protocol AFaceDetectorProtocol
-(void)faceRecognized:(NSString*)recognized confidence:(int)confidence;
-(void)faceRejected;
@end
