#import "AppellancyTintedSwitchCell.h"
#import "common.h"

@implementation AppellancyTintedSwitchCell

- (void)layoutSubviews {
	[super layoutSubviews];
    
    ((UILabel*)self.titleTextLabel).textColor = DARKER_GREEN_COLOR;
}

@end