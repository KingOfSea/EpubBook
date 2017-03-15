

#import "EpubMindListViewController.h"
#import "EpubDataBase.h"
#import "Masonry.h"
@interface EpubMindListCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, strong) EpubMarkModel *markModel;

@end

@implementation EpubMindListCell{
    CGFloat _height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _nameLabel = [self labelWithFont:[UIFont systemFontOfSize:15] textAlignment:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        _timeLabel = [self labelWithFont:[UIFont systemFontOfSize:13] textAlignment:NSTextAlignmentRight textColor:[UIColor blackColor]];
        _contentLabel = [self labelWithFont:[UIFont systemFontOfSize:13] textAlignment:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [self layoutAllSubviews];
        
    }
    return self;
}

- (UILabel *)labelWithFont:(UIFont *)font
             textAlignment:(NSTextAlignment)textAlignment
                 textColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc]init];
    label.font = font;
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    [self addSubview:label];
    return label;
}

- (void)layoutAllSubviews{
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(15);
        make.right.lessThanOrEqualTo(_timeLabel.mas_left).offset(-5);
    }];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(self).offset(15);
        make.width.mas_equalTo(80);
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLabel.mas_bottom).offset(10);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
    }];
}

- (CGFloat)height{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return _height;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _height = CGRectGetMaxY(_contentLabel.frame)+15;
}

- (void)setMarkModel:(EpubMarkModel *)markModel{
    _markModel = markModel;
    _nameLabel.text = markModel.userName;
    _timeLabel.text = [self timeFromDate:markModel];
    _contentLabel.text = markModel.markInfo;
}

- (NSString *)timeFromDate:(EpubMarkModel *)markModel{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:markModel.timeStamp];
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

@end

@interface EpubMindListViewController ()
@property (nonatomic, strong) EpubMindListCell *tempCell;

@end

static NSString *cellId = @"EpubMindListCell";
@implementation EpubMindListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"想法评论列表";
    [self.tableView registerClass:[EpubMindListCell class] forCellReuseIdentifier:cellId];
    _tempCell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
//    CGRect bounds = _tempCell.bounds;
//    bounds.size.width = [UIScreen mainScreen].bounds.size.width;
//    _tempCell.bounds = bounds;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _mindList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EpubMarkModel *markModel = _mindList[indexPath.row];
    EpubMindListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.markModel = markModel;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    EpubMarkModel *markModel = _mindList[indexPath.row];
    _tempCell.markModel = markModel;
    return _tempCell.height;
}



@end
