
#import "EpubView.h"
#import "E_MagnifiterView.h"

#import "EpubDataBase.h"
#import "EpubNotificationHeader.h"
#import "CTFunction.h"


static dispatch_queue_t drawline_serial_queue(){
    static dispatch_queue_t epub_drawline_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        epub_drawline_serial_queue = dispatch_queue_create("com.unknown.epub.drawline.creation", DISPATCH_QUEUE_SERIAL);
    });
    return epub_drawline_serial_queue;
}

static dispatch_queue_t drawline_concurrent_queue(){
    static dispatch_queue_t epub_drawline_concurrent_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        epub_drawline_concurrent_queue = dispatch_queue_create("com.unknown.epub.drawline.concurrent.creation", DISPATCH_QUEUE_CONCURRENT);
    });
    return epub_drawline_concurrent_queue;
}

@interface EpubBadgeBtn : UIButton

@property (nonatomic, copy) UIColor *backColor;
@property (nonatomic, strong) CALayer *backLayer;
@property (nonatomic, strong) EpubBadgeModel *badgeModel;

@end



@implementation EpubBadgeBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(frame.size.width/2.0-7.5, frame.size.height/2.0-7.5, 15, 15);
        layer.cornerRadius = 7.5;
        layer.opacity = 0.7;
//        layer.backgroundColor = [EpubMindView mindView].lineColor.CGColor;
        [self.layer addSublayer:layer];
        _backLayer = layer;
        
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self setTitle:@"1" forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)setBadgeModel:(EpubBadgeModel *)badgeModel{
    _badgeModel = badgeModel;
    if (!_badgeModel.isContainedMyMind) {
        _backLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
        _backLayer.opacity = 1;
    }
}

- (void)setBackColor:(UIColor *)backColor{
    _backLayer.backgroundColor = backColor.CGColor;
}

@end

@interface EpubView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) CFIndex fisrtIndex;
@property (nonatomic, assign) CFIndex secondIndex;
@property (nonatomic, strong) E_MagnifiterView *magnifierView;
@property (nonatomic, copy) void (^longPressDoing)(CFRange range, EpubView *epubView);
@property (nonatomic, copy) void (^longPressDone)(CFRange range, EpubView *epubView);

@end

@implementation EpubView{
    
    NSRange selectedRange;//选择区域
    NSMutableArray *_allLinesFrameArr;
    NSMutableArray *_gestureLineFrameArr;
    NSArray *_badges;
    
    UILabel *_bookNameLabel;
    UILabel *_chapterNameLabel;
    NSMutableArray *_btnArray;

}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        _allLinesFrameArr = [NSMutableArray array];
        _gestureLineFrameArr = [NSMutableArray array];
        _btnArray = [NSMutableArray array];
        [self addBookNameLabel:nil];
        [self addChapterNameLabel:nil];
        [self addGestures];
        _fisrtIndex = kCFNotFound;
    }
    return self;
}

- (void)addGestures{
    _longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressAction:)];
    _longRecognizer.enabled = YES;
    [self addGestureRecognizer:_longRecognizer];
    
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    _tapRecognizer.enabled = YES;
    _tapRecognizer.delegate = self;
    [self addGestureRecognizer:_tapRecognizer];
}


- (E_MagnifiterView *)magnifierView {
    
    if (_magnifierView == nil) {
        _magnifierView = [[E_MagnifiterView alloc] init];
        //        if (_magnifiterImage == nil) {
        _magnifierView.backgroundColor = [UIColor whiteColor];
        //        }else{
        //            _magnifierView.backgroundColor = [UIColor colorWithPatternImage:_magnifiterImage];
        //        }
        _magnifierView.viewToMagnify = self;
        [self addSubview:_magnifierView];
    }
    return _magnifierView;
}

#pragma mark -移除放大镜
- (void)removeMaginfierView {
    
    if (_magnifierView) {
        [_magnifierView removeFromSuperview];
        _magnifierView = nil;
    }
}


#pragma mark - 长按手势
- (void)LongPressAction:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan||longPress.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [longPress locationInView:self];
        
        CFIndex index = ct_frameGetStringIndexForPosition(_epubPage.frameRef, point, YES);
        
        if (index == kCFNotFound) {
            return;
        }
        
        self.magnifierView.touchPoint = point;
        if (_fisrtIndex == kCFNotFound) {
            _fisrtIndex = index;
            _secondIndex = index;
        }else{
            _secondIndex = index;
        }
        
        CFIndex index1 = _fisrtIndex;
        CFIndex index2 = _secondIndex;
        index1 = MIN(_fisrtIndex, _secondIndex);
        index2 = MAX(_fisrtIndex, _secondIndex);
        CFRange selectRange = CFRangeMake(index1, index2-index1+1);
        
        if (_longPressDoing) {
            _longPressDoing(selectRange,self);
        }
        
        [self drawBottomLineWithRange:selectRange];
        
        
    }else
        if (longPress.state == UIGestureRecognizerStateEnded) {
            
            [self removeMaginfierView];
            if (_fisrtIndex == -1) {
                return;
            }
            //存储选中的部分
            CFIndex index1 = _fisrtIndex;
            CFIndex index2 = _secondIndex;
            index1 = MIN(_fisrtIndex, _secondIndex);
            index2 = MAX(_fisrtIndex, _secondIndex);
            CFRange selectRange = CFRangeMake(index1, index2-index1+1);
            
            //            [EpubViewModel setSelectedRangeWithRange:selectRange selectedRanges:_selectedRanges epubPage:_pageModel epubBookModel:_bookModel];
            //            [self renderEpubView];
            _fisrtIndex = -1;
            _secondIndex = -1;
            
            if (_longPressDone) {
                _longPressDone(selectRange,self);
            }
        }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _tapRecognizer) {
        CGPoint point = [gestureRecognizer locationInView:self];
        //1.拿到点击区域，判断CFIndex，若是是选中的文字区域，返回NO，显示想法
        CFIndex index = ct_frameGetStringIndexForPosition(_epubPage.frameRef, point, NO);
        if (_singleClick) {
            return _singleClick(index, self);
        }
        return YES;
    }
    return YES;
}

- (void)longPressDoing:(void (^)(CFRange range, EpubView *epubView))doing done:(void (^)(CFRange range, EpubView *epubView))done{
    _longPressDoing = doing;
    _longPressDone = done;
}

- (void)setEpubPage:(EpubPage *)epubPage{
    _epubPage = epubPage;
    _bookNameLabel.text = _epubPage.epubContent.epubChapter.epubCatalog.bookName;
    _chapterNameLabel.text = _epubPage.epubContent.epubChapter.title;
}

- (void)addBookNameLabel:(NSSet *)objects{
    CGFloat x = 16;
    CGFloat y = 10;
    CGFloat w = ([UIScreen mainScreen].bounds.size.width-32)/2.0;
    CGFloat h = 14;
    UILabel *bookNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
    bookNameLabel.font = [UIFont systemFontOfSize:13];
    bookNameLabel.textColor = [UIColor grayColor];
    [self addSubview:bookNameLabel];
    _bookNameLabel = bookNameLabel;
}

- (void)addChapterNameLabel:(NSSet *)objects{
    CGFloat x = 16;
    CGFloat y = 10;
    CGFloat w = ([UIScreen mainScreen].bounds.size.width-32)/2.0;
    CGFloat h = 14;
    CGRect frame = CGRectMake(x, y, w, h);
    frame = CGRectOffset(frame, w, 0);
    UILabel *chapterNameLabel = [[UILabel alloc]initWithFrame:frame];
    chapterNameLabel.font = [UIFont systemFontOfSize:13];
    chapterNameLabel.textAlignment = NSTextAlignmentRight;
    chapterNameLabel.textColor = [UIColor grayColor];
    [self addSubview:chapterNameLabel];
    _chapterNameLabel = chapterNameLabel;
}

-(void)drawRect:(CGRect)rect
{
//    CGRect frame = ctline
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw((CTFrameRef)_epubPage.frameRef, context);
    
    CGContextSetFillColorWithColor(context, [EpubReadStyle sharedInstance].bottomLineColor.CGColor);

    for (EpubImageInfo* imageInfo in _epubPage.images) {
        @autoreleasepool {
            UIImage *img = [UIImage imageWithContentsOfFile:imageInfo.filePath];
            CGRect imgBounds = imageInfo.imgFrame;
            CGContextDrawImage(context, imgBounds, img.CGImage);
        }
    }
    
    for (NSValue *rectValue in _allLinesFrameArr) {
        CGRect rect = [rectValue CGRectValue];
        rect.origin.y -= 2.5;
        rect.size.height = 1.5;
        rect.size.width -= 1.5;
        CGContextFillRect(context, rect);
    }
    
    for (NSValue *rectValue in _gestureLineFrameArr) {
        CGRect rect = [rectValue CGRectValue];
        rect.origin.y -= 2.5;
        rect.size.height = 1.5;
        rect.size.width -= 1.5;
        CGContextFillRect(context, rect);
    }
    [self addBadgeButtonsWithBadges:_badges];
}

- (void)drawBottomLineWithRange:(CFRange)range{
    //移除之前的frame
    dispatch_async(drawline_serial_queue(), ^{
        [_gestureLineFrameArr removeAllObjects];
        [_gestureLineFrameArr addObjectsFromArray:ct_frameGetFrameOfStringInRange(_epubPage.frameRef, range)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

- (void)addBadgeButtonsWithBadges:(NSArray *)badges{
    
    for (UIButton *badgeBtn in _btnArray) {
        [badgeBtn removeFromSuperview];
    }
    [_btnArray removeAllObjects];
    
    for (EpubBadgeModel *badge in badges) {
        EpubBadgeBtn *badgeBtn = [[EpubBadgeBtn alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        badgeBtn.badgeModel = badge;
        badgeBtn.center = badge.center;
//        badgeBtn.backColor = [EpubMindView mindView].lineColor;
        [badgeBtn setTitle:[NSString stringWithFormat:@"%ld",badge.num] forState:UIControlStateNormal];
        [badgeBtn addTarget:self action:@selector(mindBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:badgeBtn];
        [_btnArray addObject:badgeBtn];
    }
}

- (void)mindBtn_Click:(EpubBadgeBtn *)btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:EpubBadgeButtonClickedNotification object:btn.badgeModel.mindModels];
}

- (void)drawAllLinesWithSelectRanges:(NSArray *)selectRanges badges:(NSArray *)badges{
    
    dispatch_async(drawline_serial_queue(), ^{
        _badges = badges;
        [_allLinesFrameArr removeAllObjects];
        [_gestureLineFrameArr removeAllObjects];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_apply(selectRanges.count, drawline_concurrent_queue(), ^(size_t index) {
            NSRange range_temp = [selectRanges[index] rangeValue];
            CFRange range = NSRangeTransferToCFRange(range_temp);
            NSArray *linesOfRange = ct_frameGetFrameOfStringInRange(_epubPage.frameRef, range);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [_allLinesFrameArr addObjectsFromArray:linesOfRange];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

@end
