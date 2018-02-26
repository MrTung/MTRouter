//
//  ViewController3.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/26.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "ViewController3.h"

@interface ViewController3 ()
{
    void (^block)(NSString *msg);
}

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    lable.textColor = [UIColor blueColor];
    lable.text =@"我是vc3";
    [self.view addSubview:lable];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
    [button setTitle:@"back(点击向前传值)" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void) back{
    block(@"我是VC3的数据");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initViewControllerParam:(NSDictionary *)dic
{
    self.title = [dic objectForKey:@"title"];

    block =  [dic objectForKey:@"block"];
    
}

@end
