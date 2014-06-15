#import <opencv2/highgui/cap_ios.h>
#import "NSData+AES.h"
#import "AFaceDetector.h"
#import <substrate.h>
#import <notify.h>
#import <libPass/libPass.h>
#import "headers.h"
#import <LibGuest/LibGuest.h>

#define DISPATCH_QUEUE        DISPATCH_QUEUE_PRIORITY_DEFAULT
#define SETTINGS_FILE         @"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"
#define AFaceAccepted         @"com.efrederickson.appellancy.face_accepted"
#define AFaceRejected         @"com.efrederickson.appellancy.face_rejected"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SBLSMANAGER          ((SBLockScreenManager*)[%c(SBLockScreenManager) sharedInstance])

@interface ALSFaceHandler : NSObject <AFaceDetectorProtocol>
@end

// STATIC FIELDS
static SBUIPasscodeLockViewBase *storedPasscodeView;
static BOOL disabledForNotif = NO;
static UIImageView *imgView;
static BOOL isPasscodeAlphaNumeric = NO;
static ALSFaceHandler *aDelegate;

// OPTION FIELDS
static BOOL enabled = YES;
static BOOL disableForNotifications = YES;
static BOOL disableForAnyNotifications = NO;
static BOOL onlyStartOnSwipe = NO;
static BOOL notWhenMusic = YES;
static BOOL startOnSwipe = YES;
static BOOL startGuestModeOnFail = NO;
static BOOL dontChange1 = NO;
static BOOL showImage = YES;
static BOOL dontChange2 = NO;

static void reloadSettings(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary 
        dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"];

    if ([prefs objectForKey:@"enabled"] != nil)
        enabled = [[prefs objectForKey:@"enabled"] boolValue];
    else
        enabled = YES;
        
    if ([prefs objectForKey:@"disableForNotifications"] != nil)
        disableForNotifications = [[prefs objectForKey:@"disableForNotifications"] boolValue];
    else
        disableForNotifications = YES;
        
    if ([prefs objectForKey:@"disableForAnyNotifications"] != nil)
        disableForAnyNotifications = [[prefs objectForKey:@"disableForAnyNotifications"] boolValue];
    else
        disableForAnyNotifications = NO;
        
    if ([prefs objectForKey:@"onlyStartOnSwipe"] != nil)
        onlyStartOnSwipe = [[prefs objectForKey:@"onlyStartOnSwipe"] boolValue];
    else
        onlyStartOnSwipe = NO;
        
    if ([prefs objectForKey:@"notWhenMusic"] != nil)
        notWhenMusic = [[prefs objectForKey:@"notWhenMusic"] boolValue];
    else
        notWhenMusic = YES;
        
    if ([prefs objectForKey:@"startOnSwipe"] != nil)
        startOnSwipe = [[prefs objectForKey:@"startOnSwipe"] boolValue];
    else
        startOnSwipe = YES;
        
    if ([prefs objectForKey:@"startGuestModeOnFail"] != nil)
        startGuestModeOnFail = [[prefs objectForKey:@"startGuestModeOnFail"] boolValue];
    else
        startGuestModeOnFail = NO;

    if ([prefs objectForKey:@"dontChange1"] != nil)
        dontChange1 = [[prefs objectForKey:@"dontChange1"] boolValue];
    else
        dontChange1 = NO;
    
    if ([prefs objectForKey:@"showImage"] != nil)
        showImage = [[prefs objectForKey:@"showImage"] boolValue];
    else
        showImage = YES;
    
    imgView.hidden = !showImage;

    if ([prefs objectForKey:@"dontChange2"] != nil)
        dontChange2 = [[prefs objectForKey:@"dontChange2"] boolValue];
    else
        dontChange2 = NO;
}

static void reloadRecognizer(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    //NSLog(@"Appellancy: restarting camera");
    if ([[AFaceDetector sharedDetector] running])
        [[AFaceDetector sharedDetector] stop];
    
    [[AFaceDetector sharedDetector] reloadDatabase];
    //vidHandler = nil;
}

@implementation ALSFaceHandler
-(void)faceRecognized:(NSString*)recognized confidence:(int)confidence
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (storedPasscodeView && !dontChange1)
        {
            [storedPasscodeView _updateStatusText:[NSString stringWithFormat:@"Recognized %@", recognized] animated:YES];
        }
        if (!dontChange2)
            [SBLSMANAGER.lockScreenViewController shakeSlideToUnlockTextWithCustomText:[NSString stringWithFormat:@"Recognized %@", recognized]];
    });

    // ATTEMPT UI UNLOCK
        dispatch_sync(dispatch_get_main_queue(), ^{

            if (!enabled)
                return;
            
            //LASendEventWithName(AFaceAccepted);
            notify_post([AFaceAccepted UTF8String]);

            disabledForNotif = NO;
            
            /*
            //Check if AndroidLock XT is installed and enabled
            BOOL isAndroidLockEnabled = NO;
            SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
            if([lockScreenManager respondsToSelector:@selector(androidlockIsEnabled)])
                isAndroidLockEnabled = [lockScreenManager androidlockIsEnabled];
                
            if (isAndroidLockEnabled)
            {
                [[%c(SBLockScreenManager) sharedInstance] androidlockAttemptUnlockWithUnlockActionContext:nil];
                return;
            }
            */

            // Should work with both ClassicLockScreen and iOS 6
            id awayController_ = %c(SBAwayController);
            if (awayController_ && [awayController_ respondsToSelector:@selector(sharedAwayController)])
            {
                SBAwayController *awayController = [%c(SBAwayController) sharedAwayController];
                if ([awayController respondsToSelector:@selector(attemptDeviceUnlockWithPassword:lockViewOwner:)])
                {
                    [awayController attemptDeviceUnlockWithPassword:[[LibPass sharedInstance] getEffectiveDevicePasscode] lockViewOwner:nil];
                    return;
                }
            }

            [[LibPass sharedInstance] unlockWithCodeEnabled:NO];
        });
}
-(void)faceRejected
{
    dispatch_sync(dispatch_get_main_queue(), ^{
    
        //LASendEventWithName(AFaceRejected);
        notify_post([AFaceRejected UTF8String]);

        if (startGuestModeOnFail)
        {
            Class libGuest = %c(LibGuest);
            if (libGuest)
            {
                if (![[libGuest sharedInstance] isActive]) // wait we are on the lockscreen, right? huh oh well
                    [[libGuest sharedInstance] activate];
            }
            else
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.ianb821.guestmode/launchGuestMode"), nil, nil, YES);
        }

        if (storedPasscodeView && !dontChange1)
            [storedPasscodeView _updateStatusText:@"Face not recognized" animated:YES];
        if (!dontChange2)
            [SBLSMANAGER.lockScreenViewController shakeSlideToUnlockTextWithCustomText:@"Face not recognized"];
    });
}
@end

static void start_appellancy()
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE, 0), ^{
        if (!enabled)
            return;
            
            
        if (notWhenMusic)
            if ([[%c(SBMediaController) sharedInstance] isPlaying])
                return;

        if (disabledForNotif)
            return;

            
        if (disableForAnyNotifications && [SBLSMANAGER.lockScreenViewController isKindOfClass:[%c(SBLockScreenViewController) class]])
        {
            SBLockScreenNotificationListController* notifView = MSHookIvar<SBLockScreenNotificationListController*>(SBLSMANAGER.lockScreenViewController, "_notificationController");
            if (notifView)
            {
                NSMutableArray *li = MSHookIvar<NSMutableArray *>(notifView, "_listItems");
                if (li)
                    if ([li count] > 0)
                        return;
            }
        }

        if (!aDelegate)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (storedPasscodeView && !dontChange1)
                    [storedPasscodeView _updateStatusText:@"Starting Appellancy..." animated:YES];
                if (!dontChange2)
                    [SBLSMANAGER.lockScreenViewController shakeSlideToUnlockTextWithCustomText:@"Starting Appellancy..."];
            });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (storedPasscodeView && !dontChange1)
                    [storedPasscodeView _updateStatusText:@"Appellancy started" animated:YES];
                if (!dontChange2)
                    [SBLSMANAGER.lockScreenViewController shakeSlideToUnlockTextWithCustomText:@"Appellancy started"];
            });
        }

        if (showImage)
            [[AFaceDetector sharedDetector] changeImageView:imgView];
        if (!aDelegate)
            aDelegate = [[ALSFaceHandler alloc] init];

        [[AFaceDetector sharedDetector] registerDelegate:aDelegate];
        [[AFaceDetector sharedDetector] start];

    });
}

%group IOS_7

%hook SBLockScreenViewController

-(id) init
{
    id ret = %orig;

    if (onlyStartOnSwipe)
        return ret;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE, 0), ^{
        start_appellancy();
    });
    
    return ret;
}

-(void)lockScreenView:(id)view didScrollToPage:(int)page
{
    %orig;

    if (page == 0)
    {
        if (onlyStartOnSwipe || startOnSwipe)
            start_appellancy();
    }
}

-(void) _handleDisplayTurnedOn
{
    %orig;

    if (onlyStartOnSwipe)
        return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        start_appellancy();
    });
}

-(void)_handleDisplayTurnedOff
{
    %orig;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE, 0), ^{
        if ([[AFaceDetector sharedDetector] running])
        {
            
            [[AFaceDetector sharedDetector] stop]; // device was unlocked
            [[AFaceDetector sharedDetector] deregisterDelegate:aDelegate];

        }
    });
    disabledForNotif = NO;
}

-(void)shakeSlideToUnlockTextWithCustomText:(id)arg1
{
    static id lastSet;
    if (lastSet)
    {
        if ([lastSet isEqualToString:arg1])
            return;
    }
    %orig;
}
%end
%hook SBUIPasscodeLockViewBase
-(id) initWithFrame:(CGRect)arg1
{
    id x = %orig;
    storedPasscodeView = x;

    
    if ([[self _entryField] isKindOfClass:[%c(SBUIAlphanumericPasscodeEntryField) class]])
        isPasscodeAlphaNumeric = YES;

    if (!imgView)
    {
        //NSLog(@"Appellancy: %d", [self style]);
        if (isPasscodeAlphaNumeric)
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 110, 100, 100)];
        else
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 70, 70)];
    
        CALayer * l = [imgView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10.0];
    }
    
    if (showImage)
    {
        [self addSubview:imgView];
    }

    return x;
}
%end

%hook SBLockScreenNotificationListController
- (void)turnOnScreenIfNecessaryForItem:(id/* BBBulletin* */)arg1
{
    if (disableForNotifications)
        disabledForNotif = YES;

    %orig;
}
%end

%hook SBLockStateAggregator
-(void) _updateLockState
{
    %orig;
    
    if (![self hasAnyLockState])
    {
        [[AFaceDetector sharedDetector] stop]; // device was unlocked
        [[AFaceDetector sharedDetector] deregisterDelegate:aDelegate];
    }
}
%end

%end // GROUP IOS_7

%ctor
{
    //NSLog(@"Appellancy: initializing");
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR("com.efrederickson.appellancy/reloadSettings"), NULL, 0);
    CFNotificationCenterAddObserver(r, NULL, &reloadRecognizer, CFSTR("com.efrederickson.appellancy/reloadRecognizer"), NULL, 0);
    reloadSettings(NULL, NULL, NULL, NULL, NULL);

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        %init(IOS_7);
}