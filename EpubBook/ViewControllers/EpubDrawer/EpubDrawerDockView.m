

#import "EpubDrawerDockView.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
#define E_SelectedColor [UIColor colorWithRed:220/255.0 green:50/255.0 blue:40/255.0 alpha:1]
#define E_TitleFont [UIFont systemFontOfSize:14]

@interface EpubDrawerDockView ()

@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) UIButton *curselectedBtn;
@property (nonatomic, strong) UILabel *showLine;
@property (nonatomic, strong) UILabel *sepLine;

@end

@implementation EpubDrawerDockView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        _views = [NSMutableArray array];
        [self addSepLine:nil];
        [self addShowLine:nil];
    }
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray{
    _titleArray = titleArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *subview in _views) {
            [subview removeFromSuperview];
        }
        [_views removeAllObjects];
        for (NSString *title in titleArray) {
            [self addButtonWithTitle:title];
        }
        UIButton *btn = _views.firstObject;
        _curselectedBtn = btn;
        _curselectedBtn.selected = YES;
        [self layoutAllSubviews];
    });
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    for (UIButton *button in _views) {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
}

- (void)setSeplineColor:(UIColor *)seplineColor{
    _seplineColor = seplineColor;
    _sepLine.backgroundColor = seplineColor;
}

- (void)addShowLine:(NSSet *)objects{
    UILabel *selectedLine = [[UILabel alloc]init];
    selectedLine.backgroundColor = E_SelectedColor;
    selectedLine.hidden = YES;
    [self addSubview:selectedLine];
    _showLine = selectedLine;
    
//    UIColor *seplineColor = [EpubDefaultUtil isNightMode]?EpubReadNightTextColor:EpubReadDayTextColor;
}

- (void)addSepLine:(NSSet *)objects{
    UILabel *sepLine = [[UILabel alloc]init];
    
    sepLine.backgroundColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    [self addSubview:sepLine];
    _sepLine = sepLine;
}

- (void)addButtonWithTitle:(NSString *)title{
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:title forState:UIControlStateNormal];
    UIColor *titleColor = [EpubDefaultUtil isNightMode]?EpubReadNightTextColor:EpubReadDayTextColor;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:E_SelectedColor forState:UIControlStateSelected];
    button.titleLabel.font = E_TitleFont;
    [button addTarget:self action:@selector(dockBtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [_views addObject:button];
}

- (void)dockBtn_click:(UIButton *)dockBtn{
    NSInteger index = [_views indexOfObject:dockBtn];
    _selectedIndex = index;
    _curselectedBtn.selected = NO;
    _curselectedBtn = dockBtn;
    _curselectedBtn.selected = YES;
    if (_clickHandle) {
        _clickHandle(index,self);
    }
    
    //更新下划线的约束
    [_showLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.right.equalTo(dockBtn);
        make.height.mas_equalTo(2);
    }];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)layoutAllSubviews{
    _showLine.hidden = NO;
    
    for (UIView *subview in _views) {
        NSInteger index = [_views indexOfObject:subview];
        UIView *subview = _views[index];
        CGFloat viewscount = (_views.count+1.0)*1.0;
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self).multipliedBy(2*(index+1)/viewscount);
            make.width.mas_equalTo(50);
        }];
    }
    
    [_showLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.right.equalTo(_views.firstObject);
        make.height.mas_equalTo(2);
    }];
    
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

@end
