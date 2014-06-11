#import <libactivator/libactivator.h>
#import <notify.h>

__attribute__((always_inline))
static inline LAEvent *LASendEventWithName(NSString *eventName) {

    // UPDATE: See Tweak.xm from AppellancySpringBoard for the notify_post (which this listens to)
#if !__has_feature(objc_arc)
    LAEvent *event = [[[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]] autorelease];
#else
    LAEvent *event = [[LAEvent alloc] initWithName:eventName mode:[LASharedActivator currentEventMode]];
#endif
    //NSLog(@"Appellancy: LASendEventWithName: %@", eventName);
    [LASharedActivator sendEventToListener:event];
    return event;
}

#define AFaceAccepted @"com.efrederickson.appellancy.face_accepted"
#define AFaceRejected @"com.efrederickson.appellancy.face_rejected"
#define AFaceAccepted2 "com.efrederickson.appellancy.face_accepted"
#define AFaceRejected2 "com.efrederickson.appellancy.face_rejected"

static void AFaceAccepted_Event(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    LASendEventWithName(AFaceAccepted);
}

static void AFaceRejected_Event(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    LASendEventWithName(AFaceRejected);
}

enum {
	eLAEventModeSpringBoard,
	eLAEventModeApplication,
	eLAEventModeLockScreen
};

static inline unsigned char LAEventModeEnum(NSString *eventMode) {
	unsigned char em;
	if ([eventMode isEqualToString:LAEventModeSpringBoard]) {
		em = eLAEventModeSpringBoard;
	}
	if ([eventMode isEqualToString:LAEventModeApplication]) {
		em = eLAEventModeApplication;
	}
	if ([eventMode isEqualToString:LAEventModeLockScreen]) {
		em = eLAEventModeLockScreen;
	}
	return em;
}

static inline unsigned char AEventName(NSString *eventName) {
	unsigned char en;
	if ([eventName isEqualToString:AFaceAccepted]) {
		en = 0;
	}
	if ([eventName isEqualToString:AFaceRejected]) {
		en = 1;
	}
	return en;
}

@interface AUnlockDataSource: NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation AUnlockDataSource

+ (id)sharedInstance {
	static AUnlockDataSource *shared = nil;
	if (!shared) {
		shared = [[AUnlockDataSource alloc] init];
	}
	return shared;
}

- (id)init {
	if ((self = [super init])) {
		[LASharedActivator registerEventDataSource:self forEventName:AFaceAccepted];
		[LASharedActivator registerEventDataSource:self forEventName:AFaceRejected];
	}
	return self;
}

- (void)dealloc {
	if (LASharedActivator.runningInsideSpringBoard) {
		[LASharedActivator unregisterEventDataSourceWithEventName:AFaceAccepted];
		[LASharedActivator unregisterEventDataSourceWithEventName:AFaceRejected];
	}
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	unsigned char en = AEventName(eventName);
	NSString *title[2] = { @"Recognition accepted", @"Recognition denied" };
	return title[en];
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Appellancy";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	unsigned char en = AEventName(eventName);
	NSString *description[2] = { @"Appellancy accepted a face", @"Appellancy rejected a face" };
	return description[en];
}

- (BOOL)eventWithNameIsHidden:(NSString *)eventName {
	return NO;
}

- (BOOL)eventWithNameRequiresAssignment:(NSString *)eventName {
	return NO;
}

- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
	unsigned char en = AEventName(eventName);
	unsigned char em = LAEventModeEnum(eventMode);
	//                em, en
	BOOL compatibility[2][3] = { { NO, NO, YES}, { NO, NO, YES} };
	return compatibility[en][em];
}

- (BOOL)eventWithNameSupportsUnlockingDeviceToSend:(NSString *)eventName {
	return NO;
}

@end

%ctor {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libactivator.dylib"])
    {
        %init;
        [AUnlockDataSource sharedInstance];
        CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterAddObserver(r, NULL, &AFaceAccepted_Event, CFSTR(AFaceAccepted2), NULL, 0);
        CFNotificationCenterAddObserver(r, NULL, &AFaceRejected_Event, CFSTR(AFaceRejected2), NULL, 0);
    }
}