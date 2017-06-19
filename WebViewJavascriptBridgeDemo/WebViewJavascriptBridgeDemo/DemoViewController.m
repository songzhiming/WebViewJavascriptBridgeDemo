//
//  DemoViewController.m
//  WebViewJavascriptBridgeDemo
//
//  Created by 宋志明 on 17/6/19.
//  Copyright © 2017年 宋志明. All rights reserved.
//

#import "DemoViewController.h"
#import "WebViewJavascriptBridge.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

#ifdef DEBUG
#define FLOG(str, args...) NSLog(@"\t[%s][%d][%s]  %@", strrchr(__FILE__, '/'), __LINE__, sel_getName(_cmd), [NSString stringWithFormat:str , ##args])
#else
#define FLOG(str, args...) ((void)0)
#endif

@interface DemoViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (strong, nonatomic)  UIWebView *webview;
@property (nonatomic,strong) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) NJKWebViewProgressView *progressView;
@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *string = @"https://www.baidu.com/";
    // webview
    self.webview = [[UIWebView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.webview.delegate = self;
    [self.view addSubview:self.webview];
    // 桥接
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
    [self.bridge setWebViewDelegate:self];
    [self _addWebBridge];
    // 进度
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;// 这个地方导致上面设置  [self.bridge setWebViewDelegate:self]; 失效了。
    _progressProxy.progressDelegate = self;
    self.webview.delegate  = _progressProxy;
    CGFloat progressBarHeight = 3.f;
    CGRect barFrame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_progressView];

    // loadrequest
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_addWebBridge
{
    [self.bridge registerHandler:@"showMediaView" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"showMediaView%@", data);
        responseCallback(data);
    }];
    [self.bridge registerHandler:@"dismissMediaView" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"dismissMediaView%@", data);
        responseCallback(data);
    }];
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    FLOG(@"progress－－－ %f", progress);
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    FLOG(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    FLOG(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    FLOG(@"didFailLoadWithError");
}


@end
