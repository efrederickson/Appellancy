@interface SBAwayController : NSObject
+(id) sharedAwayController;
-(BOOL) attemptDeviceUnlockWithPassword:(NSString *)arg1 lockViewOwner:(id)arg2;
@end

@interface SBUserAgent
+(id) sharedUserAgent;
-(BOOL) deviceIsPasscodeLocked;
@end

@interface SBDeviceLockController : NSObject
+(id)sharedController;
-(BOOL)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(BOOL)arg2 ;
-(BOOL)deviceHasPasscodeSet;

// TimePasscode / Pro
- (NSString *)getCurrentPasscode;
- (NSString *)getCurrentPasscode:(NSDictionary*)arg1;
@end

@class SBLockScreenNotificationListController;

@interface SBLockScreenViewControllerBase : NSObject
- (id)currentUnlockActionContext;
-(void)shakeSlideToUnlockTextWithCustomText:(id)customText;
@end

@interface SBLockStateAggregator
-(void) _updateLockState;
-(BOOL) hasAnyLockState;
@end

@interface SBUIPasscodeLockViewBase : UIView
-(id)initWithFrame:(CGRect)arg1 ;
-(void)_updateStatusText:(id)arg1 animated:(BOOL)arg2 ;
-(void)setAllowsStatusTextUpdatingOnResignFirstResponder:(BOOL)arg1 ;
-(BOOL)showsStatusField;

-(id)initWithFrame:(CGRect)arg1 ;
- (void)addSubview:(UIView *)view;
-(int)style;
-(id)_entryField;
@end

@interface SBLockScreenView
-(void)scrollToPage:(int)arg1 animated:(BOOL)arg2 completion:(/*^block*/ id)arg3;
-(void)scrollToPage:(int)page animated:(BOOL)animated;
-(void)layoutSubviews;
- (void)addSubview:(UIView *)view;
@end

@interface SBLockScreenViewController : SBLockScreenViewControllerBase
- (id)currentUnlockActionContext;
-(void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
- (void)setCustomUnlockActionContext:(id)arg1;
- (id)currentAlertItem;
- (_Bool)activateAlertItem:(id)arg1;
@end

@interface SBLockScreenManager : NSObject
- (_Bool)attemptUnlockWithPasscode:(id)arg1;
-(void)unlockUIFromSource:(int)source withOptions:(id)options;
@property(readonly, assign, nonatomic) SBLockScreenViewControllerBase* lockScreenViewController;
@end
@interface SBLockScreenManager (AndroidLockXT)
- (BOOL)androidlockIsEnabled;
- (BOOL)androidlockIsLocked;
- (BOOL)androidlockAttemptUnlockWithUnlockActionContext:(id)unlockActionContext;
- (BOOL)androidlockAttemptUnlockWithUnlockActionContext:(id)unlockActionContext animatingPasscode:(BOOL)animatingPasscode;
@end

@interface SBUnlockActionContext
@property(copy, nonatomic) id unlockAction;
@end
