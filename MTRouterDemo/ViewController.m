//
//  ViewController.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/1.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "ViewController.h"
#import "TMRouter.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 200, 50)];
    [button setTitle:@"访问vc1" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.tag = 1;
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 110, 200, 50)];
    [button2 setTitle:@"访问vc2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *butto3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 170, 200, 50)];
    [butto3 setTitle:@"访问webview" forState:UIControlStateNormal];
    [butto3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    butto3.tag = 3;
    [butto3 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:butto3];
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 230, 200, 50)];
    [button4 setTitle:@"访问未定义的页面" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button4.tag = 4;
    [button4 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
}

-(void)back:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"hello world" forKey:@"title"];
            UIViewController *controller = [[TMRouter sharedInstance] getViewController:@"VC1" withParam:dic];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 2:{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"hello world" forKey:@"title"];
            UIViewController *controller = [[TMRouter sharedInstance] getViewController:@"VC2"  withParam:dic];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 3:{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:@"https://www.baidu.com" forKey:@"url"];
            UIViewController *controller = [[TMRouter sharedInstance] getViewController:@"VC3" withParam:dic];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 4:{
            UIViewController *controller = [[TMRouter sharedInstance] getViewController:@"VC4"  withParam:nil];
            [self presentViewController:controller animated:YES completion:nil];
        }
            
        default:
            break;
    }
}


@end
