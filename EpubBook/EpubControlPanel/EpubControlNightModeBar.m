
#import "EpubControlNightModeBar.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"

@interface EpubControlNightModeButton : UIButton
@property (nonatomic, strong) UIImageView *imgView;
- (void)showImageView:(BOOL)isShow;
@end

@implementation EpubControlNightModeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"read_nightsel"]];
        [self addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(_imgView.mas_height);
        }];
    }
    return self;
}

- (void)showImageView:(BOOL)isShow{
    _imgView.hidden = !isShow;
}


@end

@interface EpubControlNightModeBar ()

@property (nonatomic, strong) EpubControlNightModeButton *dayBtn;
@property (nonatomic, strong) EpubControlNightModeButton *nightBtn;

@end


@implementation EpubControlNightModeBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
        _dayBtn = [self buttonWithTitle:@"日间模式" backColor:EpubReadDayColor tag:100];
        [_dayBtn setTitleColor:EpubReadDayTextColor forState:UIControlStateNormal];
        _nightBtn = [self buttonWithTitle:@"夜间模式" backColor:EpubReadNightColor tag:101];
        [_nightBtn setTitleColor:EpubReadNightTextColor forState:UIControlStateNormal];

        if ([EpubDefaultUtil isNightMode]) {
            [_dayBtn showImageView:NO];
            [_nightBtn showImageView:YES];
        }else{
            [_dayBtn showImageView:YES];
            [_nightBtn showImageView:NO];
        }
        [self layoutAllSubveiws];
    }
    return self;
}

- (EpubControlNightModeButton *)buttonWithTitle:(NSString *)title backColor:(UIColor *)backColor tag:(NSInteger)tag{
    EpubControlNightModeButton *button = [[EpubControlNightModeButton alloc]init];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = backColor;
    button.tag = tag;
    [button addTarget:self action:@selector(dayNightBtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)dayNightBtn_click:(EpubControlNightModeButton *)btn{
    if (btn==_dayBtn&&[EpubDefaultUtil isNightMode]) {
        [EpubDefaultUtil setIsNightMode:NO];
        [NSNotificationCenter postNotificationName:Epub_NightModeChanged];
        [_dayBtn showImageView:YES];
        [_nightBtn showImageView:NO];
        return;
    }
    if (btn==_nightBtn&&![EpubDefaultUtil isNightMode]) {
        [EpubDefaultUtil setIsNightMode:YES];
        [NSNotificationCenter postNotificationName:Epub_NightModeChanged];
        [_dayBtn showImageView:NO];
        [_nightBtn showImageView:YES];
        return;
    }
}

- (void)layoutAllSubveiws{
    [_dayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(0.5);
        make.centerY.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5).offset(-16);
        make.height.mas_equalTo(30);
    }];
    [_nightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(1.5);
        make.centerY.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5).offset(-16);
        make.height.mas_equalTo(30);
    }];
    _dayBtn.layer.cornerRadius = 15;
    _nightBtn.layer.cornerRadius = 15;
}



@end
