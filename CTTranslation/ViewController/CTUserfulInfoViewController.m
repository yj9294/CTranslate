//
//  CTUserfulInfoViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTUserfulInfoViewController.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTTranslateViewController.h"

@interface CTUserfulInfoCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation CTUserfulInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        bgView.layer.cornerRadius = 10;
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        self.contentLabel = [UILabel lbText:@"" font:[UIFont pFont:14] color:[UIColor whiteColor]];
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(25);
            make.right.mas_equalTo(-49);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userfull_arrow"]];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-31);
            make.width.mas_equalTo(6);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

@end

@interface CTUserfulInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation CTUserfulInfoViewController

- (void)didVC {
    [super didVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    nav.textLabel.text = self.typeText;
    [self.view addSubview:nav];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[CTUserfulInfoCell class] forCellReuseIdentifier:@"CTUserfulInfoCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, 45, 0)];
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [self arrayWithKey:self.typeText];
    }
    return _dataSource;
}

- (NSArray *)arrayWithKey:(NSString *)key {
    static NSDictionary *dict = nil;
    if (dict == nil) {
        dict = @{@"Accommodation": @[@"Do you have any apartment to rent？",
                                     @"Check out please.",
                                     @"Can you look after my baggage for a while？",
                                     @"would you please call me a taxi first？",
                                     @"I would like to check out now.My room number is 402.",
                                     @"Someone has stolen my cell phone.",
                                     @"Excuse me.are there any places of interest.",
                                     @"I have a complain to make.l've just boon badly treated by a rude maid.",
                                     @"I want an extension of my room.",
                                     @"Good morning,sir.ls therea bank near here."],
                 @"Travel": @[@"Could you please tell me where the nearest airport is?",
                              @"Where will the customs procedure take place?",
                              @"Which way shall l go to immigration?",
                              @"How much does it cost to take a taxi to the city center?",
                              @"Can you recommend anygood restaurants around here?",
                              @"Excuse me, where can l find the restroom?",
                              @"Is there a supermarket nearby?",
                              @"What time does the museum open/close?",
                              @"Is there a supermarket nearby?",
                              @"Can you recommend any good shopping areas in the city?",
                              @"What are some popular festivals or events happening in the area?",
                              @"Can you recommend any good parks orgardens in the area?",
                              @"Can you recommend any good day trips from here?"],
                 @"Diet": @[@"What are some popular street foods in this city?",
                            @"What are some popular local dishes l should try?",
                            @"Welcome to our restaurant!",
                            @"We'd like a table, please.",
                            @"Here's the menu, take your time to choose.",
                            @"Do you have any specialties that are particularly spicy?",
                            @"The flavors are so well-balanced; it's a culinary delight.",
                            @"Could you recommend a dish that's popular among locals?",
                            @"Is it possible to make a reservation for tomorrow night?",
                            @"Do you have a kids' menu?"],
                 @"Shopping": @[@"What can l do for you?",
                                @"Could I have a/another carrier bag?",
                                @"Do you need a bag? would you like abag?",
                                @"Are there any sales going on?",
                                @"Do you take credit cards?",
                                @"Can l use this coupon?",
                                @"Where are your fitting rooms?",
                                @"Please give me a receipt/ could I have a receipt?",
                                @"Do you have something less pricey/expensive?",
                                @"Do you have this (coat) in other size/colour?",
                                @"Excuse me. Do you have/Is ....(still) in stock?"],
                 @"Sightseeing": @[@"let me be your guide",
                                   @"There are many well-known historic sites around here",
                                   @"Sightseeing is our agenda today",
                                   @"This is a typical itinerary of the city.",
                                   @"I'd like to ask someone to take a photo for us.",
                                   @"an you help me? l'm lost.",
                                   @"Please point out where l am on the map.",
                                   @"How long will it take to get there on foot?",
                                   @"Where should l change?",
                                   @"ls there a penalty for late check- out ?"]};
    }
    return dict[key];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTUserfulInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTUserfulInfoCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *text = self.dataSource[indexPath.section];
    cell.contentLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.waitJumpIndex = indexPath.section;
//    [self showAd];
    CTTranslateViewController *vc = [[CTTranslateViewController alloc] init];
    vc.translateType = CTTranslateTypeText;
    vc.translateText = self.dataSource[indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
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
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}

@end
