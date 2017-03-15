
#import "EpubControlNavigationBar.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
@interface EpubControlNavigationBar()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *rewardButton;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation EpubControlNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([EpubDefaultUtil isNightMode]) {
            self.backgroundColor = EpubReadNightNavColor;
        }else{
            self.backgroundColor = EpubReadDayNavColor;
        }
        
        [self addBackButton:nil];
        [self addRewardButton:nil];
        [self addMoreButton:nil];
        [self layoutAllSubveiws];
        
    }
    return self;
}

- (void)addBackButton:(NSSet *)objects{
    _backButton = [self buttonWithImageName:@"icon_back"];
}

- (void)addRewardButton:(NSSet *)objects{
    _rewardButton = [self buttonWithImageName:@"read_reward"];
}

- (void)addMoreButton:(NSSet *)objects{
    _moreButton = [self buttonWithImageName:@"read_more"];
}

- (UIButton *)buttonWithImageName:(NSString *)imgName{
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click_btn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)click_btn:(UIButton *)btn{
    if (btn==_backButton&&_backHandle) {
        _backHandle();
        return;
    }
    if (btn==_rewardButton&&_rewardHandle) {
        _rewardHandle();
        return;
    }
    if (btn==_moreButton&&_moreHandle) {
        _moreHandle();
        return;
    }
}

- (void)layoutAllSubveiws{
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(10);
        make.left.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    [_rewardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_backButton);
        make.right.equalTo(_moreButton.mas_left).offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_backButton);
        make.right.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}


@end
