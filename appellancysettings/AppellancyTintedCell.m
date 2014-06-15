#import "AppellancyTintedCell.h"
#import "common.h"

@implementation AppellancyTintedCell

- (void)layoutSubviews {
	[super layoutSubviews];
    self.textLabel.textColor = DARKER_GREEN_COLOR;
}

@end