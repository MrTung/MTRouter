//
//  RouterError.h
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/1.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RouterError : NSObject


+(id)sharedInstance;
-(UIViewController *)getErrorController;

@end
