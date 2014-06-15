#import "AppellancySettingsListController.h"
#import "common.h"

@implementation AppellancySettingsListController
- (id)specifiers {
	if(_specifiers == nil)
    _specifiers = [self loadSpecifiersFromPlistName:@"AppellancySettings" target:self];
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

-(void)loadView
{
    [super loadView];
    
    [self setupHeader];
    
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = NEON_GREEN_COLOR;
    //[UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = NEON_GREEN_COLOR;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.tintColor = NEON_GREEN_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: NAVBAR_GREEN_COLOR};
    self.navigationController.navigationBar.tintColor = NAVBAR_GREEN_COLOR;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{};
}

-(void) setupHeader
{
    // Took me until decompiling Apex 2 Settings to realize this was possible...
    // setTableHeaderView:
    // no more empty space for the item!
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    
    UIImage *headerImage = [UIImage imageNamed:@"logo.png" inBundle:[NSBundle bundleForClass:self.class]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:headerImage];
    imageView.frame = CGRectMake(imageView.frame.origin.x, 10, imageView.frame.size.width, 75);
    
    [headerView addSubview:imageView];
    [self.table setTableHeaderView:headerView];
}

@end