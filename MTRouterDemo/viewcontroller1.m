//
//  viewcontroller1.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/2.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "viewcontroller1.h"

@implementation viewcontroller1

-(void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    lable.text = self.titletext;
    [self.view addSubview:lable];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initViewControllerParam:(NSDictionary *)dic
{
    self.titletext = [dic objectForKey:@"title"];
}

@end
