
#import "EpubControlProgressBar.h"
#import "Masonry.h"
@interface EpubControlProgressBar ()

@property (nonatomic, strong) UIButton *lastButton;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation EpubControlProgressBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
        _lastButton = [self buttonWithImageName:@"read_lastchapter" tag:100];
        _nextButton = [self buttonWithImageName:@"read_nextchapter" tag:101];
        _slider = [self sliderWithThumbImgWithImgName:@"read_thumb"];
        [self layoutAllSubveiws];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
//    _slider.value = progress;
    [_slider setValue:progress animated:NO];
}

- (UIButton *)buttonWithImageName:(NSString *)imgName tag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (UISlider *)sliderWithThumbImgWithImgName:(NSString *)imgName{
    UISlider *slider = [[UISlider alloc]init];
    slider.continuous = NO;
    [slider setThumbImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    slider.tintColor = [UIColor colorWithRed:147/255.0 green:193/255.0 blue:183/255.0 alpha:1];
    [slider addTarget:self action:@selector(slider_changed) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    return slider;
}

- (void)slider_changed{
    if (_chooseProgress) {
        _chooseProgress(_slider.value);
    }
}

- (void)btn_click:(UIButton *)btn{
    if (_chooseChapter) {
        _chooseChapter(btn.tag-100);
    }
}

- (void)layoutAllSubveiws{
    CGFloat sep = 0;
    [_lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(sep);
        make.bottom.equalTo(self).offset(-sep);
        make.width.equalTo(_lastButton.mas_height);
    }];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(sep);
        make.bottom.right.equalTo(self).offset(-sep);
        make.width.equalTo(_lastButton.mas_height);
    }];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lastButton.mas_right).offset(sep);
        make.right.equalTo(_nextButton.mas_left).offset(-sep);
        make.top.equalTo(_lastButton);
        make.bottom.equalTo(_lastButton);
    }];
}

@end
