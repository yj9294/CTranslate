//
//  CTHistoryViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTHistoryViewController.h"
#import "CTHistoryCell.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTHistoryPop.h"
#import "CTDbHistoryHandle.h"

@interface CTHistoryViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation CTHistoryViewController

- (void)didVC {
    [super didVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"History";
    [self.view addSubview:nav];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor hexColor:@"#12263A"];
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(86);
    }];
    
    UIButton *deleteButton = [UIButton btTitle:@"Delete"];
    [deleteButton bgImage:[UIImage imageNamed:@"history_button_bg"]];
    [deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(235);
        make.height.mas_equalTo(46);
    }];
}

- (void)deleteAction {
    CTHistoryPop *pop = [[CTHistoryPop alloc] init];
    __weak typeof(self) weakSelf = self;
    [pop showWithComplete:^{
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *remainArray = [NSMutableArray arrayWithCapacity:10];
        for (CTHistoryModel *model in weakSelf.dataSource) {
            if (model.isSelect) {
                [array addObject:model];
            } else {
                model.isShowBox = NO;
                [remainArray addObject:model];
            }
        }
        
        //删除数据库里面的数据
        [CTDbHistoryHandle deleteWithModels:array];
        
        //刷新
        [weakSelf.dataSource removeAllObjects];
        [weakSelf.dataSource addObjectsFromArray:remainArray];
        [weakSelf.tableView reloadData];
        weakSelf.bottomView.hidden = YES;
    }];
}

- (void)backAction {
    [self displayBackAdvert];
}

- (void)displayBackAdvert {
    __weak typeof(self) __weakself = self;
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    [GADUtil.shared show:GADPositionInterstital p:GADSceneBackHomeInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__weakself jumpVCWithAnimated:YES];
    }];
    [GADUtil.shared logScene:GADSceneBackHomeInter];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[CTHistoryCell class] forCellReuseIdentifier:@"CTHistoryCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, CTSafeAreaBottom() + 100, 0)];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [CTDbHistoryHandle loadAlls];
        _dataSource = [NSMutableArray arrayWithArray:array];
        //数据库里面取
    }
    return _dataSource;
}

//TODO: UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 127;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTHistoryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CTHistoryModel *model = self.dataSource[indexPath.section];
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    cell.longCell = ^{
        for (CTHistoryModel *model in weakSelf.dataSource) {
            model.isShowBox = YES;
            model.isSelect = NO;
        }
        [weakSelf.tableView reloadData];
        weakSelf.bottomView.hidden = NO;
    };
    return cell;
}

#pragma  mark - UINavigationControllerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self displayBackAdvert];
    return NO;
}
@end
