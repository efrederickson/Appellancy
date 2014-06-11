#import <Preferences/Preferences.h>

#define SETTINGS_FILE         @"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"

@interface AppellancySettingsListController: PSListController {
}
@end

@implementation AppellancySettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
#if !__has_feature(objc_arc)
		_specifiers = [[self loadSpecifiersFromPlistName:@"AppellancySettings" target:self] retain];
#else
        _specifiers = [self loadSpecifiersFromPlistName:@"AppellancySettings" target:self];
#endif
	}
    [self localizedSpecifiersWithSpecifiers:_specifiers];
	return _specifiers;
}

- (id)navigationTitle {
	return [[self bundle] localizedStringForKey:[super title] value:[super title] table:nil];
}

- (id)localizedSpecifiersWithSpecifiers:(NSArray *)specifiers {
    
    NSLog(@"localizedSpecifiersWithSpecifiers");
	for(PSSpecifier *curSpec in specifiers) {
		NSString *name = [curSpec name];
		if(name) {
			[curSpec setName:[[self bundle] localizedStringForKey:name value:name table:nil]];
		}
		NSString *footerText = [curSpec propertyForKey:@"footerText"];
		if(footerText)
			[curSpec setProperty:[[self bundle] localizedStringForKey:footerText value:footerText table:nil] forKey:@"footerText"];
		id titleDict = [curSpec titleDictionary];
		if(titleDict) {
			NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
			for(NSString *key in titleDict) {
				NSString *value = [titleDict objectForKey:key];
				[newTitles setObject:[[self bundle] localizedStringForKey:value value:value table:nil] forKey: key];
			}
			[curSpec setTitleDictionary:newTitles];
		}
	}
	return specifiers;
}

-(void) openTwitter
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=daementor"]];
}

-(void) openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mlnlover11"]];
}

-(void) sendEmail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:elijah.frederickson@gmail.com?subject=Appellancy"]];
}
-(void) sendEmail_FR
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:elijah.frederickson@gmail.com?subject=Appellancy%20Feature%20Request"]];
}
-(void) openArtistSite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://andrew-abosh.com"]];
}
-(void) openArtistRepo
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://andrew-abosh.com/repo"]];
}

@end

// vim:ft=objc
