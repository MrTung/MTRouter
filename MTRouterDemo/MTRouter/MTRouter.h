//
//  MTRouter.h
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/1.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTRouter : NSObject

+(id)sharedInstance;

/**
 获取控制器
 @param stringVCName 控制器名字
 @return 返回控制器实例
 */
-(UIViewController *)getViewController:(NSString *)stringVCName;

/**
 返回一个初始化参数之后的控制器
 @param stringVCName 控制器名字
 @param paramdic 初始化参数 字典格式
 @return 控制器实例
 */
-(UIViewController *)getViewController:(NSString *)stringVCName withParam:(NSDictionary *)paramdic;
@end
