## 正文

#### 什么是组件化

###### 其他人的组件化

在看了很多其他人的方案之后，首先对组件化思想上有一个小分歧。我认为很多人对于iOS中组件化的理解其实是有误区的。我刚工作的第一年就是在做Flex开发，其中就有很多组件化的思想，加上最近在用Vue做web项目之后，更为意识到大家在iOS开发上说的组件化有点不合适。

首先我认为组件是一个相对比较小的功能模块，不需要与外界有太多的通信，更不能依赖其他第三方，这一点尤为重要。比如说几乎所有iOS开发者都知道的MJReflesh，比如我很早之前开源的 [MTMessageKeyBoard](https://github.com/MrTung/MTMessageKeyBoard) 这些几乎不依赖业务，并且提供了良好的调用接口和使用体验的才能称为组件。而看了很多方案，大部分都是在讲app里面的业务功能组件之间的通信和解耦，其实我更愿意将这些东西称为“模块”。那如何区分这两种呢，我觉得这句话比较好理解:

**核心业务模块化，通用功能组件化**

打比方说你的app是一个电商项目,那么你的产品详情页、列表页、购物车、搜索等页面肯定就是调用频次非常高的VC了，这些界面之间跳转都会非常频繁。这就造成了互相依赖并且高度耦合。如下图所示。

![](https://ws2.sinaimg.cn/large/006tKfTcgy1frj3m1yia6j31140omgra.jpg)

看起来是不是跟个麻花一样？而怎么样才能解决这个问题呢? 等下会讲。

像商品详情页这些通常外部调入只需要传入一个productID就可以，而且高度依赖自己的业务功能的模块就可以将这些当成一个模块维护。后面需要修改里面的活动的显示、业务的增删都可以单独在详情模块里面改动而不需要改动别的代码。

而对于组件，比方说我上面提到的IM类型的app中用到的聊天键盘,或者集成支付宝、微信等支付功能的支付插件。这些可以在多个不同的项目小组内部共享。甚至可以开源到社区中供所有开发者使用的小插件，用组件来形容更贴切。在flex、Vue、angular等前端开发中体现尤为突出。

所以接下来我所要讲的组件化实际上更贴切的说法是模块化。

###### 为什么要有组件化(模块化)

客户端在公司业务发展的过程中体积越来越庞大，其中堆叠了大量的业务逻辑代码，不同业务模块的代码相互调用，相互嵌套，代码之间的耦合性越来越高，调用逻辑会越来越混乱。当某个模块需要升级的时候，改动代码的时候往往会有牵一发而动全身的感觉。特别是如果工程最初设计的时候没有考虑的接口的封装，而将大量的业务代码与功能模块代码混在一起时，将来的升级就需要对代码进行大量修改及调整，带来的工作量是非常巨大的。这就需要设计一套符合要求的组件之间通信的中间件。模块化可以将代码的功能逻辑尽量封装在一起，对外只提供接口，业务逻辑代码与功能模块通过接口进行弱耦合。


#### 我的模块化架构思路

###### 如何优化模块之间的通信

封装模块的工作只要你对面向对象思想有所理解，实现起来应该不难，确保写好调用接口就行，这里不再赘述。而模块化最重要的就是各个模块之间的通信。比如在商品搜索列表页面，需要查看购物车功能和查看商品详情功能，购物车的商品列表也能点击商品到商品详情页。等等这些界面之间都会相互调用，相互依赖。通常我们会怎么实现呢？比如这样:

```
#import "ProductDetailViewController.h"
#import "CartViewController.h"

@implementation ProductListViewController

- (void)gotoDetail {
 ProductDetailViewController *detailVC = [[ProductDetailViewController alloc] initWithProId:self.proId];
 [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)gotoCart {
 CartViewController *cartVC = [[CartViewController alloc] init];
 [self.navigationController pushViewController: cartVC animated:YES];
}
@end
```

相信这样的代码大家都不陌生，基本都是这样做。而且这样写也并没有问题。但是，项目一旦大起来问题就来了。
各个模块只要有相互调用的情况，都会相互产生依赖。每次跳转都需要import对应的控制器，重写一次代码。如果某个地方做了一点点需求改动，比如商品详情页需要多传入一个参数，这个时候就要找到各个调用的地方逐一修改。这显然不是高效的办法。

###### 运用中间件

于是很简单的就想到了一个方法，提供一个中间层:Router。在router里面定义好每次跳转的方法，然后在需要用的界面调用router函数，传入对应的参数。比如这样：

![](https://ws3.sinaimg.cn/large/006tKfTcgy1frj3s3j7soj312g0ss7be.jpg)


```
//Router.m
#import "ProductDetailViewController.h"
#import "CartViewController.h"

@implementation Router

+ (UIViewController *) getDetailWithParam:(NSString *) param {
	ProductDetailViewController *detailVC = [[ProductDetailViewController alloc] 	initWithProId:self.proId];
	return detailVC;
}

+ (UIViewController *) getCart {
   CartViewController *cartVC = [[CartViewController alloc] init];
   return cartVC;
}
@end
```

其他界面中这样使用

```
#import "Router.m"

 UIViewController * detailVC = [[Router instance] jumpToDetailWithParam:param];
 [self.navigationController pushViewController: detailVC];
  
```

###### 运用runtime

但是这样写的话也有一个问题，每个vc都会依赖Router,而Router里面会依赖所有的VC。那如何打破这层循环引用呢？OC里有个法宝可以用到:runtime。

```
-(UIViewController *)getViewController:(NSString *)stringVCName
{
  	Class class = NSClassFromString(stringVCName);
    UIViewController *controller = [[class alloc] init];
    if(controller == nil){
        NSLog(@"未找到此类:%@",stringVCName);
        controller = [[RouterError sharedInstance] getErrorController];
    }
    return controller;
}
```
这样上面的图就是这样的：

![](https://ws1.sinaimg.cn/large/006tKfTcgy1frj3tbh330j31260qoac0.jpg)

这样Router里面不需要import任何vc了，代码也就数十行而已，看起来非常的简便。而且做了异常处理，如果找不到此类，会返回预先设置的错误界面。是不是有点类似于web开发中的404界面呢？



```
  UIViewController *controller = [[Router sharedInstance] getViewController:@"ProductDetailViewController"];
  [self.navigationController pushViewController:controller];          
```
 
###### 如何传参数

很多人肯定都发现了，这样写的话如何传参数呢。比如商品详情页至少要传一个productID吧。别急，我们可以将上面的方法稍微处理，传入一个dict做了参数。

```
-(UIViewController *)getViewController:(NSString *)stringVCName
{
    Class class = NSClassFromString(stringVCName);
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

```
我们默认在业务控制器里面有个`initViewControllerParam`方法,然后再router里面可以用`respondsToSelector`手动触发这个方法，传入参数paramdict。当然如果你想要更加灵活一点，那就将`initViewControllerParam`初始化方法当做一个`actionName`参数传到router里面。类似于这样：

```
-(UIViewController *)controller:(UIViewController *)controller withParam:(NSDictionary *)paramdic andVCname:(NSString *)vcName actionName:(NSString *)actionName{
    SEL selector = NSSelectorFromString(actionName);
    
    ....后面就是一样的代码了


```

到这里基本上模块化就可以实现了。基本上通过不超过100行的代码解决了各个复杂业务模块之间的通信和高度解耦。


#### 总结

模块化的实现方法在iOS开发中算是比较好实现的，主要是OC本身就是一门动态的语言。对象类型是加上是在运行时中确定的，而调用方法在oc中是以发消息的形式实现。这就增加了很多可以操作的可能性。这种方法在大部分的app中都能很好的应用，并且解决大部分的业务需求。

而博客开始之前提到的组件化，其实一般在小中型的项目里面用到的可能性不大，除非业务真的非常复杂和庞大。有至少10个或者以上的开发者才会遇到将部分通用的功能抽离出来做成组件。iOS中组件化目前最合适也是最成熟的就是CocoaPods私有库了，直接托管到内部git服务器上使用,或者开源到gitHub上让全球的开发者使用你的插件。

类似于中间件的模块化方案其实之前在项目中我有实践,确实能解决一部分的开发问题和效率。但是在和很多其他开发者交流中发现，其实业务的复杂度很难支持你做好真正的模块化。经常都是良好的开端，最后由于项目推进中带来的需求更改，促使你不断修改这个所谓的中间件。到最后还是揉成一坨，带来更多新的问题。所以，在实践中大家仁者见仁智者见智吧,但是本文中所提到的方案还是有必要了解和掌握的。

毕竟胸有兵法，不怕干仗嘛。
