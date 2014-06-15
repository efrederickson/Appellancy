@class UIActivityIndicatorView;

@interface PSSwitchTableCell : PSControlTableCell  {
    UIActivityIndicatorView *_activityIndicator;
}

@property BOOL loading;


- (BOOL)loading;
- (void)setLoading:(BOOL)arg1;
- (id)controlValue;
- (id)newControl;
- (void)setCellEnabled:(BOOL)arg1;
- (void)refreshCellContentsWithSpecifier:(id)arg1;
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
- (void)reloadWithSpecifier:(id)arg1 animated:(BOOL)arg2;
- (BOOL)canReload;
- (void)dealloc;
- (void)prepareForReuse;
- (void)layoutSubviews;
- (void)setValue:(id)arg1;

@end