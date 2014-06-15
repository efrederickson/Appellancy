#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
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
    
    UIImage* image = [UIImage imageNamed:@"heart.png" inBundle:[NSBundle bundleForClass:self.class]];
    CGRect frameimg = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(heartWasTouched)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *heartButton = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, heartButton, nil] animated:NO];
    
    //((UINavigationItem*)self.navigationItem).rightBarButtonItem = heartButton;
    
    [self setupHeader];
    
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = NEON_GREEN_COLOR;
    //[UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = NEON_GREEN_COLOR;
}

-(void) heartWasTouched
{
    SLComposeViewController *composeController = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [composeController setInitialText:@"I’m loving #Appellancy from @Daementor!"];
    
    [self presentViewController:composeController
                       animated:YES completion:nil];
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