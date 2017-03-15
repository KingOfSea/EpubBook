
#import "EpubDrawerCatalogCell.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
#define E_SelectedColor [UIColor colorWithRed:220/255.0 green:50/255.0 blue:40/255.0 alpha:1]

@interface EpubDrawerCatalogCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sepLine;
@end

@implementation EpubDrawerCatalogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addTitleLabel:nil];
        [self addSepLine:nil];
        [self layoutAllSubviews];
    }
    return self;
}

- (void)setIsCellSelected:(BOOL)isCellSelected{
    if ([EpubDefaultUtil isNightMode]) {
        _titleLabel.textColor = isCellSelected?E_SelectedColor:EpubReadNightTextColor;
    }else{
        _titleLabel.textColor = isCellSelected?E_SelectedColor:EpubReadDayTextColor;
    }
    _sepLine.hidden = [EpubDefaultUtil isNightMode];
}

- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
}

- (void)addTitleLabel:(NSSet *)objects{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)addSepLine:(NSSet *)objects{
    UILabel *sepLine = [[UILabel alloc]init];
    sepLine.backgroundColor = [UIColor colorWithWhite:210/255.0 alpha:1];
//    sepLine.backgroundColor = [UIColor redColor];
    [self addSubview:sepLine];
    _sepLine = sepLine;
}

- (void)layoutAllSubviews{
    CGFloat sep = 25;
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(sep);
        make.right.equalTo(self).offset(-sep);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0.7);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self);
        make.left.right.equalTo(_sepLine);
    }];
}

@end
