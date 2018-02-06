//
//  viewcontroller2.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/2.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "viewcontroller2.h"

@interface viewcontroller2 ()

@end

@implementation viewcontroller2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    lable.textColor = [UIColor blueColor];
    lable.text =@"我是vc2";
    [self.view addSubview:lable];
    
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
    self.title = [dic objectForKey:@"title"];
}

@end
