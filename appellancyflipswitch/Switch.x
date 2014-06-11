#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"

@interface AppellancyFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation AppellancyFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
    NSDictionary *prefs = [NSDictionary 
        dictionaryWithContentsOfFile:SETTINGS_FILE];
    if ([prefs objectForKey:@"enabled"] != nil)
        return [[prefs objectForKey:@"enabled"] boolValue] ? FSSwitchStateOn : FSSwitchStateOff;
    else
        return FSSwitchStateOn;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
   if (newState == FSSwitchStateIndeterminate)
        return;
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS_FILE];
    [prefs setObject:[NSNumber numberWithBool:newState] forKey:@"enabled"];
    [prefs writeToFile:SETTINGS_FILE atomically:YES];
    notify_post("com.efrederickson.appellancy/reloadSettings");
}

@end