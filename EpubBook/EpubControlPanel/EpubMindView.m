
#import "EpubMindView.h"
#import "EpubReadStyle.h"
NSString * const EpubMindViewColorChanged = @"EpubMindViewColorChanged";

@interface EpubMindViewColorBtn : UIButton

@end

@implementation EpubMindViewColorBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.layer.borderWidth = 1.5;
    }else{
        self.layer.borderWidth = 0;
    }
}

@end


@implementation EpubMindView{
    EpubMindViewColorBtn *_curSelectedBtn;
    
    EpubMindViewColorBtn *_cyanBtn;
    EpubMindViewColorBtn *_greenBtn;
    EpubMindViewColorBtn *_orangeBtn;
    EpubMindViewColorBtn *_purpleBtn;
    
    UIButton *_copyBtn;
    UIButton *_mindBtn;
    UIButton *_shareBtn;
    UIButton *_tipoffBtn;
}

static EpubMindView *shareInstance;

+ (EpubMindView *)mindView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        shareInstance = [[self alloc]initWithFrame:CGRectMake(0, 0, width-32, 120)];
    });
    return shareInstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        self.backgroundColor = [UIColor colorWithWhite:25/255.0 alpha:1];
        
        _cyanBtn    = [self colorBtnWithColor:[UIColor colorWithRed:90/255.0 green:168/255.0 blue:247/255.0 alpha:1] tag:200];
        _greenBtn   = [self colorBtnWithColor:[UIColor colorWithRed:96/255.0 green:189/255.0 blue:22/255.0 alpha:1] tag:201];
        _orangeBtn  = [self colorBtnWithColor:[UIColor colorWithRed:243/255.0 green:114/255.0 blue:0/255.0 alpha:1] tag:202];
        _purpleBtn  = [self colorBtnWithColor:[UIColor colorWithRed:163/255.0 green:93/255.0 blue:229/255.0 alpha:1] tag:203];
        
        _copyBtn    = [self buttonWithTitle:@"复制" tag:100];
        _mindBtn    = [self buttonWithTitle:@"想法" tag:101];
        _shareBtn   = [self buttonWithTitle:@"分享" tag:102];
        _tipoffBtn  = [self buttonWithTitle:@"删除" tag:103];
        
        [self layoutAllSubviews];
    }
    return self;
}

- (EpubMindViewColorBtn *)colorBtnWithColor:(UIColor *)color tag:(NSInteger)tag{
    EpubMindViewColorBtn *btn = [[EpubMindViewColorBtn alloc]init];
    btn.backgroundColor = color;
    btn.tag = tag;
    [btn addTarget:self action:@selector(colorBtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    NSInteger selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"EpubMindView_selectedIndex"];
    if (selectedIndex == tag-200) {
        btn.selected = YES;
        _curSelectedBtn = btn;
    }
    return btn;
}

- (UIColor *)lineColor{
//    _lineColor = _curSelectedBtn.backgroundColor;
    return _curSelectedBtn.backgroundColor;
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.tag = tag;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithWhite:70/255.0 alpha:1].CGColor;
    button.layer.cornerRadius = 4;
    [button addTarget:self action:@selector(actionBtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)colorBtn_click:(EpubMindViewColorBtn *)btn{
    _curSelectedBtn.selected = NO;
    _curSelectedBtn = btn;
    _curSelectedBtn.selected = YES;
    
    _lineColor = _curSelectedBtn.backgroundColor;
    [EpubReadStyle sharedInstance].bottomLineColor = _curSelectedBtn.backgroundColor;
    [[NSUserDefaults standardUserDefaults] setInteger:btn.tag-200 forKey:@"EpubMindView_selectedIndex"];
    [[NSNotificationCenter defaultCenter] postNotificationName:EpubMindViewColorChanged object:nil userInfo:@{@"lineColor":_curSelectedBtn.backgroundColor}];
    
}

- (void)actionBtn_click:(UIButton *)btn{
    if (_actionHandle) {
        _actionHandle(btn.tag-100);
    }
}

- (void)layoutAllSubviews{
    
    CGFloat width = self.bounds.size.width;
    
    NSArray *colorBtns = @[_cyanBtn,_greenBtn,_orangeBtn,_purpleBtn];
    for (NSInteger index = 0; index<colorBtns.count; index++) {
        EpubMindViewColorBtn *btn = colorBtns[index];
        btn.frame = CGRectMake((2*index+1)*width/8.0, 20, 34, 34);
        btn.center = CGPointMake((2*index+1)*width/8.0, 36);
        btn.layer.cornerRadius = 34/2.0;
    }
    
    NSArray *actionBtns = @[_copyBtn,_mindBtn,_shareBtn,_tipoffBtn];
    for (NSInteger index = 0; index<actionBtns.count; index++) {
        UIButton *btn = actionBtns[index];
        btn.frame = CGRectMake(0, 0, 58, 32);
        btn.center = CGPointMake((2*index+1)*width/8.0, 88);
    }
}

@end
