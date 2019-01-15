//
//  MTRouter.m
//  MTRouterDemo
//
//  Created by 董徐维 on 2018/2/1.
//  Copyright © 2018年 董徐维. All rights reserved.
//

#import "MTRouter.h"
#import "RouterError.h"
#import <UIKit/UIKit.h>

//ignore selector unknown warning
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface MTRouter()

/**路由信息数据字典*/
@property(nonatomic,strong) NSMutableDictionary *plistdata;

@end

@implementation MTRouter

+(id)sharedInstance{
    static dispatch_once_t onceToken;
    static MTRouter * router;
    dispatch_once(&onceToken,^{
        router = [[MTRouter alloc] init];
        //解析路由配置文件，生成路由配置字典。plist文件中的 key 就是对应控制器的简称，这个可以自由定义；而value则是对应控制器的类名，这个必须和你创建的controller一致，否则会报错
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RouterData" ofType:@"plist"];
        router.plistdata = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    });
    return router;
}

-(UIViewController *)getViewController:(NSString *)stringVCName
{
    NSString *viewControllerName = [self.plistdata objectForKey:stringVCName];
    Class class = NSClassFromString(viewControllerName);
    UIViewController *controller = [[class alloc] init];
    return controller;
}

-(UIViewController *)getViewController:(NSString *)stringVCName withParam:(NSDictionary *)paramdic
{
    UIViewController *controller = [self getViewController:stringVCName];
    if(controller != nil){
        controller = [self controller:controller withParam:paramdic andVCname:stringVCName];
    }else{
        NSLog(@"未找到此类:%@",stringVCName);
        //EXCEPTION  Push a Normal Error VC
        controller = [[RouterError sharedInstance] getErrorController];
    }
    return controller;
}

/**
 此方法用来初始化参数（控制器初始化方法默认为 initViewControllerParam。初始化方法你可以自定义，前提是VC必须实现它。要想灵活一点，也可以加一个参数actionName,当做参数传入。不过这样你就需要修改此方法了)。
 @param controller 获取到的实例VC
 @param paramdic 实例化参数
 @param vcName 控制器名字
 @return 初始化之后的VC
 */
-(UIViewController *)controller:(UIViewController *)controller withParam:(NSDictionary *)paramdic andVCname:(NSString *)vcName {
    
    SEL selector = NSSelectorFromString(@"initViewControllerParam:");
    if(![controller respondsToSelector:selector]){  //如果没定义初始化参数方法，直接返回，没必要在往下做设置参数的方法
        NSLog(@"目标类:%@未定义:%@方法",controller,@"initViewControllerParam:");
        return controller;
    }
    //在初始化参数里面添加一个key信息，方便控制器中查验路由信息
    if(paramdic == nil){
        paramdic = [[NSMutableDictionary alloc] init];
        
        [paramdic setValue:vcName forKey:@"URLKEY"];
        
        SuppressPerformSelectorLeakWarning([controller performSelector:selector withObject:paramdic]);
    }else{
        
        [paramdic setValue:vcName forKey:@"URLKEY"];
    }
    SuppressPerformSelectorLeakWarning( [controller performSelector:selector withObject:paramdic]);
    return controller;
}



@end
