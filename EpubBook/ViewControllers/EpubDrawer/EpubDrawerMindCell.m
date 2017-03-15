

#import "EpubDrawerMindCell.h"
#import "Masonry.h"
#import "EpubReadStyle.h"


#define TimeFont    [UIFont systemFontOfSize:12]
#define ContentFont [UIFont systemFontOfSize:14]
#define TimeColor   [UIColor colorWithWhite:0.6 alpha:1]
@interface EpubDrawerMindCell ()

@property (nonatomic, strong) UILabel *chapterNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *markTitleLabel;
@property (nonatomic, strong) UILabel *markLabel;

@property (nonatomic, strong) UILabel *sepLine;

@end

@implementation EpubDrawerMindCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addChapterNameLabel:nil];
        [self addTimeLabel:nil];
        [self addContentLabel:nil];
        [self addMarkTitleLabel:nil];
        [self addMarkLabel:nil];
        [self addSepLine:nil];
        [self layoutAllSubviews];
    }
    return self;
}

- (void)setMarkModel:(EpubMarkModel *)markModel{
    _markModel = markModel;
    if (_markModel.markInfo.length == 0) {
        _markTitleLabel.hidden = YES;
        _markLabel.hidden = YES;
    }else{
        _markTitleLabel.hidden = NO;
        _markLabel.hidden = NO;
    }
    _chapterNameLabel.text = _markModel.chapterName;
    _timeLabel.text = [self timeFromDate:_markModel];
    _contentLabel.text = _markModel.markContent;
    _markLabel.text = _markModel.markInfo;
    
}

- (CGFloat)heightWithEpubMarkModel:(EpubMarkModel *)markModel{
    self.markModel = markModel;
    [self layoutIfNeeded];
    [self layoutSubviews];
    if (_markModel.markInfo.length == 0) {
        return CGRectGetMaxY(_contentLabel.frame)+15;
    }else{
        return CGRectGetMaxY(_markLabel.frame)+15;
    }
}

- (NSString *)timeFromDate:(EpubMarkModel *)markModel{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_markModel.timeStamp];
    NSDate *dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:date];
    if (timeInterval<60) {
        return @"刚刚";
    }
    if (timeInterval<60*60) {
        return [NSString stringWithFormat:@"%ld分钟前",(NSInteger)timeInterval/60];
    }
    if (timeInterval<60*60*24) {
        return [NSString stringWithFormat:@"%ld小时前",(NSInteger)timeInterval/(60*60)];
    }
    if (timeInterval<60*60*24*30) {
        return [NSString stringWithFormat:@"%ld天前",(NSInteger)timeInterval/(60*60*24)];
    }
    return @"一个月前";
}

- (void)addChapterNameLabel:(NSSet *)objects{
    _chapterNameLabel = [self labelWithFont:TimeFont
                              textAlignment:NSTextAlignmentLeft
                                  textColor:TimeColor
                                 numOflines:1];
}

- (void)addTimeLabel:(NSSet *)objects{
    _timeLabel = [self labelWithFont:TimeFont textAlignment:NSTextAlignmentRight textColor:TimeColor numOflines:1];
}

- (void)addContentLabel:(NSSet *)objects{
    _contentLabel = [self labelWithFont:ContentFont textAlignment:NSTextAlignmentLeft textColor:[UIColor colorWithWhite:50/255.0 alpha:1] numOflines:2];
}

- (void)addMarkTitleLabel:(NSSet *)objects{
    _markTitleLabel = [self labelWithFont:TimeFont textAlignment:NSTextAlignmentLeft textColor:TimeColor numOflines:1];
    _markTitleLabel.text = @"想法：";
}

- (void)addMarkLabel:(NSSet *)objects{
    _markLabel = [self labelWithFont:TimeFont textAlignment:NSTextAlignmentLeft textColor:TimeColor numOflines:2];
}

- (void)addSepLine:(NSSet *)objects{
    UILabel *sepLine = [[UILabel alloc]init];
    sepLine.backgroundColor = [UIColor colorWithWhite:220/255.0 alpha:1];
    [self addSubview:sepLine];
    _sepLine = sepLine;
}


- (UILabel *)labelWithFont:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)textColor numOflines:(NSInteger)numOflines{
    UILabel *label = [[UILabel alloc]init];
    label.font = font;
    label.textAlignment = textAlignment;
    label.numberOfLines = numOflines;
    label.textColor = textColor;
    [self addSubview:label];
    return label;
}

- (void)layoutAllSubviews{
    CGFloat sep = 25;
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(sep);
        make.right.equalTo(self).offset(-sep);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0.7);
    }];
    
    [_chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sepLine);
        make.top.equalTo(self).offset(15);
        make.right.lessThanOrEqualTo(_timeLabel.mas_left).offset(-10);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_sepLine);
        make.top.equalTo(self).offset(15);
        make.width.mas_equalTo(80);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_bottom).offset(10);
        make.left.right.equalTo(_sepLine);
    }];
    CGSize size = [_markTitleLabel sizeThatFits:CGSizeMake(MAXFLOAT, 0)];
    [_markTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sepLine);
        make.top.equalTo(_contentLabel.mas_bottom).offset(15);
        make.width.mas_equalTo(size.width);
    }];
    
    [_markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_markTitleLabel.mas_right);
        make.right.equalTo(_sepLine);
        make.top.equalTo(_markTitleLabel);
    }];
}


@end
