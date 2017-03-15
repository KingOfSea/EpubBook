
#import "EpubMenuViewController.h"
#import "EpubDrawerDockView.h"
#import "EpubDrawerCatalogCell.h"
#import "EpubDrawerMindCell.h"
//#import "EpubDrawerMarkCell.h"
#import "Masonry.h"
#import "EpubDefaultUtil.h"
#import "HGDrawerViewController.h"


static NSString *catalogCell_ID = @"EpubDrawerViewController_catalogCell_ID";
static NSString *mindCell_ID    = @"EpubDrawerViewController_mindCell_ID";
static NSString *markCell_ID    = @"EpubDrawerViewController_markCell_ID";

@interface EpubMenuViewController()<UITableViewDelegate,UITableViewDataSource>
{
    EpubBookModel *_bookModel;
    EpubParser *_epubParser;
}
@property (nonatomic, strong) UITableView *catalogTableView;
@property (nonatomic, strong) UITableView *mindsTableView;
@property (nonatomic, strong) UITableView *marksTableView;
@property (nonatomic, strong) UITableView *curTableView;

@property (nonatomic, strong) EpubDrawerMindCell *temp_MindCell;
@property (nonatomic, strong) EpubDrawerMindCell *temp_MarkCell;

@property (nonatomic, strong) NSMutableArray *markArray;
@property (nonatomic, strong) NSMutableArray *mindArray;
@property (nonatomic, strong) EpubDrawerDockView *dockView;

@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation EpubMenuViewController

- (instancetype)initWithBookModel:(EpubBookModel *)bookModel epubParser:(EpubParser *)epubParser{
    self = [super init];
    if (self) {
        _bookModel = bookModel;
        _epubParser = epubParser;
        _mindArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:_bookModel type:EpubMarkTypeMind]];
        _markArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:_bookModel type:EpubMarkTypeMark]];
        
        if (_epubParser.epubCatalog.chapters.count) {
            EpubChapter *epubChapter = _bookModel.currentChapter>=0?_epubParser.epubCatalog.chapters[_bookModel.currentChapter]:_epubParser.epubCatalog.chapters.firstObject;
            
            _selectedRow = [_epubParser.epubCatalog.chapters_order indexOfObject:epubChapter];
            _selectedRow = _selectedRow>=0&&_selectedRow<=_epubParser.epubCatalog.chapters.count?_selectedRow:epubChapter.playOrder;
        }
        
    }
    return self;
}

- (EpubBookModel *)bookModel{
    return _bookModel;
}

- (EpubParser *)epubParser{
    return _epubParser;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if ([EpubDefaultUtil isNightMode]) {
        self.view.backgroundColor = EpubReadNightViewColor;
    }else{
        self.view.backgroundColor = EpubReadDayViewColor;
    }
//    self.view.backgroundColor = [UIColor colorWithWhite:228/255.0 alpha:1];
    _catalogTableView = [self tableViewWithRegisterCellClass:[EpubDrawerCatalogCell class] cellId:catalogCell_ID tag:100];
    _catalogTableView.hidden = NO;
    _curTableView = _catalogTableView;
    _mindsTableView = [self tableViewWithRegisterCellClass:[EpubDrawerMindCell class] cellId:mindCell_ID tag:101];
    _marksTableView = [self tableViewWithRegisterCellClass:[EpubDrawerMindCell class] cellId:markCell_ID tag:102];
    {//需要设置_temp_MindCell.bounds，否则计算cell高度不准确
        _temp_MindCell = [_mindsTableView dequeueReusableCellWithIdentifier:mindCell_ID];
        CGRect bounds = _temp_MindCell.bounds;
        bounds.size.width = [UIScreen mainScreen].bounds.size.width*0.8;
        _temp_MindCell.bounds = bounds;
    }
    {
        _temp_MarkCell = [_marksTableView dequeueReusableCellWithIdentifier:markCell_ID];
        CGRect bounds = _temp_MarkCell.bounds;
        bounds.size.width = [UIScreen mainScreen].bounds.size.width*0.8;
        _temp_MarkCell.bounds = bounds;
    }
    [self addDockView:nil];
    [self layoutAllSubveiws];
    [self addNotis];
}

- (void)addNotis{
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:EpubDataBaseMarkTableUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        EpubMarkModel *markModel = userInfo[@"MarkModel"];
        if (markModel.markType == EpubMarkTypeMind) {
            weakSelf.mindArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:weakSelf.bookModel type:EpubMarkTypeMind]];
            [weakSelf.mindsTableView reloadData];
        }else{
            weakSelf.markArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:weakSelf.bookModel type:EpubMarkTypeMark]];
            [weakSelf.marksTableView reloadData];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:EpubDataBaseMarkTableDelete object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        EpubMarkModel *markModel = userInfo[@"MarkModel"];
        if (markModel.markType == EpubMarkTypeMind) {
            weakSelf.mindArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:weakSelf.bookModel type:EpubMarkTypeMind]];
            [weakSelf.mindsTableView reloadData];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//            [weakSelf.mindsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }else{
            weakSelf.markArray = [NSMutableArray arrayWithArray:[EpubDataBase marksForBookModel:weakSelf.bookModel type:EpubMarkTypeMark]];
            [weakSelf.marksTableView reloadData];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//            [weakSelf.marksTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:EpubDataBaseBookTableUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        NSInteger selectedRow = [userInfo[@"CurrentChapter"] integerValue];
        if (selectedRow != weakSelf.selectedRow&&weakSelf.epubParser.epubCatalog.chapters.count>selectedRow) {
            EpubChapter *chapter = [weakSelf.epubParser.epubCatalog.chapters objectAtIndex:selectedRow];
            selectedRow = [weakSelf.epubParser.epubCatalog.chapters_order indexOfObject:chapter];
            selectedRow = selectedRow>=0&&selectedRow<=weakSelf.epubParser.epubCatalog.chapters.count?selectedRow:chapter.playOrder;
            weakSelf.selectedRow = selectedRow;
            [weakSelf.catalogTableView reloadData];
        }
    }];
    
    
    [NSNotificationCenter addObserverForName:Epub_NightModeChanged usingBlock:^(NSNotification *note) {
        if ([EpubDefaultUtil isNightMode]) {
            weakSelf.view.backgroundColor = EpubReadNightViewColor;
            weakSelf.dockView.titleColor = EpubReadNightTextColor;
        }else{
            weakSelf.view.backgroundColor = EpubReadDayViewColor;
            weakSelf.dockView.titleColor = EpubReadDayTextColor;
        }
        [weakSelf.catalogTableView reloadData];
        [weakSelf.mindsTableView reloadData];
        [weakSelf.marksTableView reloadData];

    }];
    
    [NSNotificationCenter addObserverForName:HGDrawerViewControllerWillShow usingBlock:^(NSNotification *note) {
        [weakSelf resetCatalogTableViewOffset];
    }];

}

- (void)resetCatalogTableViewOffset{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
    CGRect frame = [_catalogTableView rectForRowAtIndexPath:indexPath];
    CGFloat T_h = _catalogTableView.frame.size.height;
    CGFloat T_c = _catalogTableView.contentSize.height;
    CGFloat C_y = frame.origin.y+frame.size.height/2.0;
    if (T_c>=T_h) {
        if (C_y<T_h*0.5) {
            _catalogTableView.contentOffset = CGPointZero;
        }else
            if (T_c-C_y<T_h*0.5) {
                _catalogTableView.contentOffset = CGPointMake(0, T_c-T_h);
            }else{
                _catalogTableView.contentOffset = CGPointMake(0, C_y-T_h*0.5);
            }
    }
}

- (UITableView *)tableViewWithRegisterCellClass:(Class)class cellId:(NSString *)cellId  tag:(NSInteger)tag{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    tableView.tag = tag;
    [tableView registerClass:class forCellReuseIdentifier:cellId];
    [self.view addSubview:tableView];
    tableView.hidden = YES;
    return tableView;
}

- (void)addDockView:(NSSet *)objects{
    EpubDrawerDockView *dockView = [[EpubDrawerDockView alloc]init];
    dockView.backgroundColor = [UIColor clearColor];
    dockView.titleArray = @[@"目录",@"想法",@"书签"];
    __weak typeof(self) weakSelf = self;
    [dockView setClickHandle:^(NSInteger index, EpubDrawerDockView *dockView) {
        weakSelf.curTableView.hidden = YES;
        UITableView *tableView = [weakSelf.view viewWithTag:index+100];
        weakSelf.curTableView = tableView;
        weakSelf.curTableView.hidden = NO;
    }];
    dockView.selectedIndex = 0;
    [self.view addSubview:dockView];
    _dockView = dockView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _catalogTableView) {
        return _epubParser.epubCatalog.chapters_order.count;
    }
    if (tableView == _mindsTableView) {
        return _mindArray.count;
    }
    return _markArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _catalogTableView) {
        return 50;
    }
    if (tableView == _mindsTableView) {
        return [_temp_MindCell heightWithEpubMarkModel:_mindArray[indexPath.row]];
    }
    return [_temp_MarkCell heightWithEpubMarkModel:_markArray[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _catalogTableView) {
        EpubDrawerCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:catalogCell_ID];
        EpubChapter *chapter = _epubParser.epubCatalog.chapters_order[indexPath.row];
        NSString *space = [NSString string];
        for (NSInteger count = 0; count<chapter.hierarchy; count++) {
            space = [space stringByAppendingString:@"    "];
        }
        cell.title = [NSString stringWithFormat:@"%@%@",space,chapter.title];
        cell.isCellSelected = indexPath.row == _selectedRow;
        return cell;
    }
    if (tableView == _mindsTableView) {
        EpubDrawerMindCell *cell = [tableView dequeueReusableCellWithIdentifier:mindCell_ID];
        cell.markModel = _mindArray[indexPath.row];
        return cell;
    }
    if (tableView == _marksTableView) {
        EpubDrawerMindCell *cell = [tableView dequeueReusableCellWithIdentifier:markCell_ID];
        cell.markModel = _markArray[indexPath.row];
        return cell;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _catalogTableView) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == _mindsTableView) {
            [EpubDataBase deleteMarkWithMarkModel:_mindArray[indexPath.row]];
            return;
        }
        if (tableView == _marksTableView) {
            [EpubDataBase deleteMarkWithMarkModel:_markArray[indexPath.row]];
            return;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _catalogTableView) {
        _selectedRow = indexPath.row;
        [_catalogTableView reloadData];
        if (_catalogClick) {
            _catalogClick(_epubParser.epubCatalog.chapters_order[indexPath.row]);
        }
        return;
    }
    if (tableView == _mindsTableView) {
        if (_markClick) {
            _markClick(_mindArray[indexPath.row]);
        }
        return;
    }
    if (tableView == _marksTableView) {
        if (_markClick) {
            _markClick(_markArray[indexPath.row]);
        }
        return;
    }
}

- (void)layoutAllSubveiws{
    [_dockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [_catalogTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(_dockView.mas_bottom);
    }];
    
    [_mindsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(_dockView.mas_bottom);
    }];
    
    [_marksTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(_dockView.mas_bottom);
    }];
}

@end
