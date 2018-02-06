//
//  webView.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/2.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "webView.h"

@implementation webView


-(void)viewDidLoad{
    [super viewDidLoad];
    
    UIWebView * view = [[UIWebView alloc]initWithFrame:self.view.frame];
    [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.view addSubview:view];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initViewControllerParam:(NSDictionary *)dic{
    self.url = dic[@"url"];
}

@end
