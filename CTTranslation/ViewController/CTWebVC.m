//
//  CTWebVC.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/1/5.
//

#import "CTWebVC.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKWebViewConfiguration.h>
#import "CTNavigationView.h"
#import "UIView+CT.h"

@interface CTWebVC ()
@property (nonatomic, strong) CTNavigationView *navView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *url;
@end

@implementation CTWebVC

- (void)didVC {
    [super didVC];
}

- (id)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.view addSubview:self.webView];
    
    self.navView = [[CTNavigationView alloc] init];
    [self.navView.leftButton nImage:[UIImage imageNamed:@"back_b"] hImage:nil];
    [self.view addSubview:self.navView];
}

@end
