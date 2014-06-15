#import <Preferences/Preferences.h>

#define SETTINGS_FILE            @"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"
#define NEON_GREEN_COLOR         [UIColor colorWithRed:0/255.0f green:252/255.0f blue:21/255.0f alpha:1.0f]
#define NEON_GREEN_COLOR_ANDREW  [UIColor colorWithRed:128/255.0f green:185/255.0f blue:91/255.0f alpha:1.0f] // @drewplex prefers this color for the UISwitch onTintColor
#define NAVBAR_GREEN_COLOR       [UIColor colorWithRed:41/255.0f green:177/255.0f blue:52/255.0f alpha:1.0f]
#define DARKER_GREEN_COLOR       [UIColor colorWithRed:0/255.0f green:224/255.0f blue:42/255.0f alpha:1.0f]

@interface PSListController (Appellancy)
-(UIView*)view;
-(UINavigationController*)navigationController;
-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
-(UINavigationController*)navigationController;

-(void)loadView;
@end

@interface UIImage (Appellancy)
+ (UIImage *)imageNamed:(NSString *)named inBundle:(NSBundle *)bundle;
@end

@interface PSTableCell (Appellancy)
@property (nonatomic) UIView *backgroundView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(UILabel*)textLabel;
@end

@interface UIPreferencesTable : UITableView // wat
@end