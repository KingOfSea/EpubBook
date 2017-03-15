

#import "EpubMindViewController.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
//#import "HGTextView.h"

//static NSString *placeholder = @"写一下此刻的想法";

#define PlaceColor [UIColor colorWithWhite:150/255.0 alpha:1]
#define TitleColor [UIColor colorWithWhite:50/255.0 alpha:1]

@interface EpubMindViewController()<UITextViewDelegate>

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cacelButton;
@property (nonatomic, strong) UIView *contentBackView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *backView;

@end

@implementation EpubMindViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([EpubDefaultUtil isNightMode]) {
        self.view.backgroundColor = EpubReadNightViewColor;
    }else{
        self.view.backgroundColor = [UIColor colorWithWhite:0.3/255.0 alpha:0.3];
    }

    _cacelButton = [self buttonWithTitle:@"取消"];
    _saveButton  = [self buttonWithTitle:@"确定"];
    [self addBackView:nil];
    [self addContentBackView:nil];
    [self addContentLabel:nil];
    [self addTextView:nil];
    [self layoutAllSubviews];
    [_textView becomeFirstResponder];
}

- (void)addBackView:(NSSet *)objects{
    UIView *backView = [[UIView alloc]init];
    if ([EpubDefaultUtil isNightMode]) {
        backView.backgroundColor = EpubReadNightViewColor;
    }else{
        backView.backgroundColor = [UIColor colorWithWhite:231/255.0 alpha:1];
    }
    [self.view addSubview:backView];
    _backView = backView;
}

- (UIButton *)buttonWithTitle:(NSString *)title{
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)addContentBackView:(NSSet *)objects{
    UIView *contentBackView = [[UIView alloc]init];
    contentBackView.layer.borderWidth = 1;
    contentBackView.layer.borderColor = [UIColor colorWithWhite:216/255.0 alpha:1].CGColor;
    [self.view addSubview:contentBackView];
    _contentBackView = contentBackView;
}

- (void)addContentLabel:(NSSet *)objects{
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.text = _markModel.markContent;
    contentLabel.textColor = [UIColor colorWithWhite:160/255.0 alpha:1];
    contentLabel.numberOfLines = 2;
    contentLabel.font = [UIFont systemFontOfSize:11];
    
    [self.view addSubview:contentLabel];
    _contentLabel = contentLabel;
}

- (void)addTextView:(NSSet *)objects{
    UITextView *textView = [[UITextView alloc]init];
    textView.layer.borderColor = [UIColor blackColor].CGColor;
    textView.layer.borderWidth = 1;
    textView.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:textView];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [EpubDefaultUtil isNightMode]?EpubReadNightTextColor:TitleColor;
    if (_markModel.markInfo.length) {
        textView.text = _markModel.markInfo;
    }
    
    
    _textView = textView;
}

- (void)btn_click:(UIButton *)btn{
    
    if (btn == _saveButton) {
        if (!_textView.text.length) {
            NSLog(@"想法不能为空");
            return;
        }
        _markModel.markInfo = _textView.text;
        _markModel.timeStamp = [[NSDate date] timeIntervalSince1970];
        
        [self.view.window endEditing:YES];
        [EpubDataBase updateMarkWithMarkModel:_markModel];
        [self dismissViewControllerAnimated:YES completion:nil];

    }else{
        [self.view.window endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)layoutAllSubviews{
    CGFloat sep = 16;
    [_cacelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cacelButton);
        make.right.equalTo(self.view).offset(-10);
        make.size.equalTo(_cacelButton);
    }];
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(_cacelButton.mas_bottom).offset(10);
    }];
    [_contentBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(sep);
        make.right.equalTo(self.view).offset(-sep);
        make.top.equalTo(_backView).offset(10);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(_contentBackView).offset(10);
        make.right.bottom.equalTo(_contentBackView).offset(-10);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentBackView);
        make.right.equalTo(_contentBackView);
        make.top.equalTo(_contentBackView.mas_bottom).offset(10);
        make.height.mas_equalTo(100);
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    //返回白色
    return UIStatusBarStyleLightContent;
}

- (void)dealloc{
    NSLog(@"111111111");
}

@end
