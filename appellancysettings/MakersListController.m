#import "MakersListController.h"
#import "common.h"

@implementation MakersListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Maker" target:self];
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

- (void)viewWillAppear:(BOOL)animated {
    self.view.tintColor = NEON_GREEN_COLOR;
    self.navigationController.navigationBar.tintColor = NAVBAR_GREEN_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: NAVBAR_GREEN_COLOR};
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{};
}

-(void) openTwitter
{
    NSString *user = @"daementor";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}
-(void) openGithub
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ioc:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ioc://github.com/mlnlover11"]];
    else
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

-(void) openArtistTwitter
{
    NSString *user = @"drewplex";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

-(void) openArtistSite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://andrew-abosh.com"]];
}
-(void) openOpenCVWebsite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://opencv.org/"]];
}

-(void) openOpenCVLicense
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Itseez/opencv/blob/master/LICENSE"]];
}

-(void) openAppellancyLicense
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mlnlover11/Appellancy/blob/master/LICENSE"]];
}

-(void) openSourceCode
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ioc:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ioc://github.com/mlnlover11/Appellancy"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mlnlover11/Appellancy"]];
}
@end