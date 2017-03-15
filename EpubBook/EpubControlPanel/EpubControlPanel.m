
#import "EpubControlPanel.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
@interface EpubControlPanel ()
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *progressButton;
@property (nonatomic, strong) UIButton *daynightButton;
@property (nonatomic, strong) UIButton *fontButton;

@end

@implementation EpubControlPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if ([EpubDefaultUtil isNightMode]) {
            self.backgroundColor = EpubReadNightViewColor;
        }else{
            self.backgroundColor = [UIColor whiteColor];
        }
        _menuButton         = [self buttonWithImageName:@"read_menu" tag:100];
        _progressButton     = [self buttonWithImageName:@"read_progress" tag:101];
        _daynightButton     = [self buttonWithImageName:@"read_daynight" tag:102];
        _fontButton         = [self buttonWithImageName:@"read_font" tag:103];
        [self layoutAllSubveiws];
    }
    return self;
}

- (UIButton *)buttonWithImageName:(NSString *)imgName tag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc]init];
    button.tag = tag;
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)btn_click:(UIButton *)button{
    if (_panelClick) {
        _panelClick(button.tag-100);
    }
}

- (void)layoutAllSubveiws{
    NSArray *subviews = @[_menuButton,_progressButton,_daynightButton,_fontButton];
    for (NSInteger index = 0; index<subviews.count; index++) {
        UIView *view = subviews[index];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            if (index) {
                UIView *lastView = subviews[index-1];
                make.left.equalTo(lastView.mas_right);
            }else{
                make.left.equalTo(self);
            }
            make.width.equalTo(self).multipliedBy(0.25);
        }];
    }
}


@end
