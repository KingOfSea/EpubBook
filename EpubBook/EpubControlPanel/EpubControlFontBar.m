
#import "EpubControlFontBar.h"
#import "EpubReadStyle.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"

#define FONT_MIN 11
#define FONT_MAX 20
@interface EpubControlFontBar ()

@property (nonatomic, strong) UIButton *fontMinusBtn;
@property (nonatomic, strong) UILabel *fontLabel;
@property (nonatomic, strong) UIButton *fontPlusBtn;

@end

@implementation EpubControlFontBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
        _fontMinusBtn = [self buttonWithImageName:@"read_fontminus" tag:100];
        _fontPlusBtn = [self buttonWithImageName:@"read_fontplus" tag:101];
        _fontLabel = [self labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor colorWithWhite:65/255.0 alpha:1]];
        _fontLabel.text = [NSString stringWithFormat:@"%ld",(NSInteger)[EpubReadStyle sharedInstance].font.pointSize];
        [self layoutAllSubveiws];
        
        [[EpubReadStyle sharedInstance] addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc{
    [[EpubReadStyle sharedInstance] removeObserver:self forKeyPath:@"font"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == [EpubReadStyle sharedInstance]&&[keyPath isEqualToString:@"font"]) {
        NSInteger font = [EpubReadStyle sharedInstance].font.pointSize;
        _fontLabel.text = [NSString stringWithFormat:@"%ld",font];
        if (font>=FONT_MAX) {
            _fontPlusBtn.enabled = NO;
            return;
        }
        if (font<=FONT_MIN) {
            _fontMinusBtn.enabled = NO;
            return;
        }
        _fontMinusBtn.enabled = YES;
        _fontPlusBtn.enabled = YES;
    }
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor{
    UILabel *fontLabel = [[UILabel alloc]init];
    fontLabel.textColor = textColor;
    fontLabel.font = font;
    [self addSubview:fontLabel];
    return fontLabel;
}

- (UIButton *)buttonWithImageName:(NSString *)imgName tag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(fontbtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)fontbtn_click:(UIButton *)btn{
    NSInteger font = [EpubReadStyle sharedInstance].font.pointSize;
    font = btn == _fontMinusBtn?font-1:font+1;
    if (font<=FONT_MAX&&font>=FONT_MIN) {
        [EpubReadStyle sharedInstance].font = [UIFont systemFontOfSize:font];
        [EpubDefaultUtil setReadFont:[UIFont systemFontOfSize:font]];
        [NSNotificationCenter postNotificationName:Epub_FontChanged];
    }
}

- (void)layoutAllSubveiws{
    [_fontMinusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).multipliedBy(0.5);
        make.height.equalTo(self).multipliedBy(1).offset(-10);
        make.width.equalTo(self).multipliedBy(0.5).offset(-20);
    }];
    [_fontPlusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).multipliedBy(1.5);
        make.height.equalTo(self).multipliedBy(1).offset(-10);
        make.width.equalTo(self).multipliedBy(0.5).offset(-20);
    }];
    [_fontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}


@end
