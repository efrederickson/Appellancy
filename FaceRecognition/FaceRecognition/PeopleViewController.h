#import <UIKit/UIKit.h>
#import "CustomFaceRecognizer.h"
#import "BOZPongRefreshControl.h"

@interface PeopleViewController : UITableViewController

@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) NSDictionary *selectedPerson;
@property (nonatomic) BOOL showDenyEntry;
@property (nonatomic, retain) BOZPongRefreshControl *pongRefreshControl;

@end