
#import "EpubControlMoreBar.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"

@interface EpubControlMoreCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sepLine;

@end

@implementation EpubControlMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addImgView:nil];
        [self addTitleLabel:nil];
        [self addSepLine];
        [self layoutAllSubveiws];
        
    }
    return self;
}

- (void)addImgView:(NSSet *)objects{
    _imgView = [[UIImageView alloc]init];
    [self addSubview:_imgView];
}

- (void)addTitleLabel:(NSSet *)objects{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
}

- (void)addSepLine{
    _sepLine = [[UILabel alloc]init];
    _sepLine.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self addSubview:_sepLine];
}

- (void)layoutAllSubveiws{
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.4);
        make.width.equalTo(_imgView.mas_height);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgView.mas_right).offset(15);
        make.centerY.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.5);
        make.right.equalTo(self).offset(-15);
    }];
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.7);
        make.left.bottom.right.equalTo(self);
    }];
}


@end


static NSString *cellId = @"EpubControlMoreBar_Cell";
@interface EpubControlMoreBar ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *imgArray;
@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation EpubControlMoreBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([EpubDefaultUtil isNightMode]) {
            self.backgroundColor = EpubReadNightNavColor;
        }else{
            self.backgroundColor = EpubReadDayNavColor;
        }
//        self.layer.cornerRadius = 6;
        _imgArray = @[@"icon_share",@"read_tipoff",@"read_mark"];
        _titleArray = @[@"分享",@"举报",@"书签"];
        
        [self addTableView];
        
    }
    return self;
}

- (void)addTableView{
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[EpubControlMoreCell class] forCellReuseIdentifier:cellId];
    _tableView.bounces = NO;
    [self addSubview:_tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EpubControlMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.imgView.image = [UIImage imageNamed:_imgArray[indexPath.row]];
    cell.titleLabel.text = _titleArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.frame.size.height/(_titleArray.count*1.0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (_shareHandle) {
            _shareHandle();
        }
        return;
    }
    if (indexPath.row == 1) {
        if (_tipoffHandle) {
            _tipoffHandle();
        }
        return;
    }
    if (indexPath.row == 2) {
        if (_markHandle) {
            _markHandle();
        }
        return;
    }
}

@end
