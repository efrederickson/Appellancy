#import "AFaceDetector.h"
#import <libactivator/libactivator.h>

@interface Sample : NSObject <AFaceDetectorProtocol, LAListener>
-(void)faceRecognized:(NSString*)recognized confidence:(int)confidence;
-(void)faceRejected;
@end

static Sample *wat;

@implementation Sample
-(void)faceRecognized:(NSString*)recognized confidence:(int)confidence
{
    // The face was accepted, you don't need to do anything with the confidence.
    // Plus, confidence will vary greatly depending upon the number of pictures they have scanned, the lighting, etc.
    
    // Recognized is the profile name.
    
    NSLog(@"Appellancy sample: accepted '%@'", recognized);
    
    // Allow the user in:
    
    // [self.passcodeController allowAccess];
    //[self stop]; // we don't want to keep running in the background! :O
    [[AFaceDetector sharedDetector] stop];
    // We de-register ourself so we don't recieve extraneous notifications and updates when it isn't required and will (may) cause issues
    [[AFaceDetector sharedDetector] deregisterDelegate:self];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Appellancy Test" message:@"Face accepted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    //NSLog(@"Appellancy sample: done.");
}

-(void)faceRejected
{
    // only do this here if you don't want to wait for an acceptance (or you have some other method of authentication that will disable it)
    [[AFaceDetector sharedDetector] deregisterDelegate:self];
    [[AFaceDetector sharedDetector] stop];

    NSLog(@"Appellancy sample: face rejected");
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Appellancy Test" message:@"Face rejected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [error show];
    [error release];
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // start the listener
        NSLog(@"Appellancy sample: starting AFaceDetector");
        [[AFaceDetector sharedDetector] registerDelegate:self];
    	[[AFaceDetector sharedDetector] start];
    });

    [event setHandled:YES];
}
@end

%ctor
{
    wat = [[Sample alloc] init];
    //wat.passwordController = self;

    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [[%c(LAActivator) sharedInstance] registerListener:wat forName:@"com.efrederickson.appellancy-api-test-listener"];
}