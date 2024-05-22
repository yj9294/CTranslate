//
//  CTRecommedViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTRecommedViewController.h"
#import "CTNavigationView.h"
#import "CTHomeTableViewCell.h"
#import "UIView+CT.h"
#import "CTRecommandInfoViewController.h"
#import "CTFbHandle.h"
#import "CTPosterManager.h"

@interface CTRecommedViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation CTRecommedViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] addReco:@"reco"];
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
    self.selectIndex = -1;
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"Recommend";
    [self.view addSubview:nav];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneRecommendInter completion:nil];
}

- (void)backAction {
    [self displayBackAdvert];
}

- (void)displayUsefulAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneRecommendInter completion:nil];
    __weak typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneRecommendInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__self jumpUserInfovcWithAnimated: YES];
    }];
}

- (void)jumpUserInfovcWithAnimated:(BOOL)animated {
    if (self.selectIndex >= 0) {
        CTRecommandInfoViewController *vc = [[CTRecommandInfoViewController alloc] init];
        vc.translateText = self.dataSource[self.selectIndex];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)displayBackAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    __weak typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneBackHomeInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__self jumpVCWithAnimated:YES];
    }];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:animated];
    });
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[CTHomeTableViewCell class] forCellReuseIdentifier:@"CTHomeTableViewCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, 45, 0)];
    }
    return _tableView;
}
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [[CTFbHandle shared] getRecommendList];
        _dataSource = [NSMutableArray arrayWithArray:array];
    }
    return _dataSource;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTHomeTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *text = self.dataSource[indexPath.section];
    cell.contentLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"reco_i"}];
    self.selectIndex = indexPath.section;
    [self displayUsefulAdvert];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}


#pragma  mark - UINavigationControllerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self displayBackAdvert];
    return false;
}


@end
