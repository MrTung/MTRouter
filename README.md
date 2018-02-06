# MTRouter
iOS模块化构建方案，模块间解耦，路由中心设计方案

#### 简要说明
在app业务堆积到一定量的时候，各个业务模块之间的通信也将会变得越来越多。这就需要设计一套符合要求且通用的模块之间通信的中间件。在查阅相关资料和方案之后结合OC的runtime特性实现了一个相对比较简单的路由中间件。demo中只实现了app内部的路由功能，不同控制器之间基本做到了解耦，不需要互相引用，只需要配置好对应的plist文件即可自由跳转。app外部之间跳转目前尚未实现，后续看需求补充。

详细思路引用了bang大神的，大家看看就好，具体实现下载demo就知道了。[点这里查看原文](http://blog.cnbang.net/tech/3080/).


###——————————————————————————————

一个 APP 有多个模块，模块之间会通信，互相调用，例如微信读书有 书籍详情 想法列表 阅读器 发现卡片 等等模块。这些模块会互相调用，例如 书籍详情要调起阅读器和想法列表，阅读器要调起想法列表和书籍详情，等等，一般我们是怎样调用呢，以阅读器为例，会这样写：

```
#import "WRBookDetailViewController.h"
#import "WRReviewViewController.h"
@implementation WRReadingViewController
- (void)gotoDetail {
 WRBookDetailViewController *detailVC = [[WRBookDetailViewController alloc] initWithBookId:self.bookId];
 [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)gotoReview {
 WRReviewViewController *reviewVC = [[WRReviewViewController alloc] initWithBookId:self.bookId reviewType:1];
 [self.navigationController pushViewController:reviewVC animated:YES];
}
@end

```
看起来挺好，这样做简单明了，没有多余的东西，项目初期推荐这样快速开发，但到了项目越来越庞大，这种方式会有什么问题呢？显而易见，每个模块都离不开其他模块，互相依赖粘在一起成为一坨：

![MacDown logo](http://blog.cnbang.net/wp-content/uploads/2016/03/component1.png)

component1
这样揉成一坨对测试/编译/开发效率/后续扩展都有一些坏处，那怎么解开这一坨呢。很简单，按软件工程的思路，下意识就会加一个中间层：

![MacDown logo](http://blog.cnbang.net/wp-content/uploads/2016/03/component2-1024x597.png)

component2
叫他 Mediator Manager Router 什么都行，反正就是负责转发信息的中间层，暂且叫他 Mediator。
看起来顺眼多了，但这里有几个问题：

1.Mediator 怎么去转发组件间调用？

2.一个模块只跟 Mediator 通信，怎么知道另一个模块提供了什么接口？

3.按上图的画法，模块和 Mediator 间互相依赖，怎样破除这个依赖？

##方案1
对于前两个问题，最直接的反应就是在 Mediator 直接提供接口，调用对应模块的方法：
//Mediator.m

```
#import "BookDetailComponent.h"
#import "ReviewComponent.h"
@implementation Mediator
+ (UIViewController *)BookDetailComponent_viewController:(NSString *)bookId {
 return [BookDetailComponent detailViewController:bookId];
}
+ (UIViewController *)ReviewComponent_viewController:(NSString *)bookId reviewType:(NSInteger)type {
 return [ReviewComponent reviewViewController:bookId type:type];
}
@end
//BookDetailComponent 组件
#import "Mediator.h"
#import "WRBookDetailViewController.h"
@implementation BookDetailComponent
+ (UIViewController *)detailViewController:(NSString *)bookId {
 WRBookDetailViewController *detailVC = [[WRBookDetailViewController alloc] initWithBookId:bookId];
 return detailVC;
}
@end
//ReviewComponent 组件
#import "Mediator.h"
#import "WRReviewViewController.h"
@implementation ReviewComponent
+ (UIViewController *)reviewViewController:(NSString *)bookId type:(NSInteger)type {
 UIViewController *reviewVC = [[WRReviewViewController alloc] initWithBookId:bookId type:type];
 return reviewVC;
}
@end
```
然后在阅读模块里：
//WRReadingViewController.m

```
#import "Mediator.h"
@implementation WRReadingViewController
- (void)gotoDetail:(NSString *)bookId {
 UIViewController *detailVC = [Mediator BookDetailComponent_viewControllerForDetail:bookId];
 [self.navigationController pushViewController:detailVC];

 UIViewController *reviewVC = [Mediator ReviewComponent_viewController:bookId type:1];
 [self.navigationController pushViewController:reviewVC];
}
@end
```
这就是一开始架构图的实现，看起来显然这样做并没有什么好处，依赖关系并没有解除，Mediator 依赖了所有模块，而调用者又依赖 Mediator，最后还是一坨互相依赖，跟原来没有 Mediator 的方案相比除了更麻烦点其他没区别。

那怎么办呢。
怎样让Mediator解除对各个组件的依赖，同时又能调到各个组件暴露出来的方法？对于OC有一个法宝可以做到，就是runtime反射调用：

//Mediator.m

```
@implementation Mediator
+ (UIViewController *)BookDetailComponent_viewController:(NSString *)bookId {
 Class cls = NSClassFromString(@"BookDetailComponent");
 return [cls performSelector:NSSelectorFromString(@"detailViewController:") withObject:@{@"bookId":bookId}];
}
+ (UIViewController *)ReviewComponent_viewController:(NSString *)bookId type:(NSInteger)type {
 Class cls = NSClassFromString(@"ReviewComponent");
 return [cls performSelector:NSSelectorFromString(@"reviewViewController:") withObject:@{@"bookId":bookId, @"type": @(type)}];
}
@end

```
这下 Mediator 没有再对各个组件有依赖了，你看已经不需要 #import 什么东西了，对应的架构图就变成：
![MacDown logo](http://blog.cnbang.net/wp-content/uploads/2016/03/component31-1024x548.png)

component3
只有调用其他组件接口时才需要依赖 Mediator，组件开发者不需要知道 Mediator 的存在。
等等，既然用runtime就可以解耦取消依赖，那还要Mediator做什么？组件间调用时直接用runtime接口调不就行了，这样就可以没有任何依赖就完成调用：
//WRReadingViewController.m

```
@implementation WRReadingViewController
- (void)gotoReview:(NSString *)bookId {
 Class cls = NSClassFromString(@"ReviewComponent");
 UIViewController *reviewVC = [cls performSelector:NSSelectorFromString(@"reviewViewController:") withObject:@{@"bookId":bookId, @"type": @(1)}];
 [self.navigationController pushViewController:reviewVC];
}
@end

```
这样就完全解耦了，但这样做的问题是：

1.调用者写起来很恶心，代码提示都没有，每次调用写一坨。

2.runtime方法的参数个数和类型限制，导致只能每个接口都统一传一个 NSDictionary。这个 NSDictionary里的key value是什么不明确，需要找个地方写文档说明和查看。

3.编译器层面不依赖其他组件，实际上还是依赖了，直接在这里调用，没有引入调用的组件时就挂了


**把它移到Mediator后：**

1.调用者写起来不恶心，代码提示也有了。

2.参数类型和个数无限制，由 Mediator 去转就行了，组件提供的还是一个 NSDictionary 参数的接口，但在Mediator 里可以提供任意类型和个数的参数，像上面的例子显式要求参数 NSString *bookId 和 NSInteger type。

3.Mediator可以做统一处理，调用某个组件方法时如果某个组件不存在，可以做相应操作，让调用者与组件间没有耦合。

到这里，基本上能解决我们的问题：各组件互不依赖，组件间调用只依赖中间件Mediator，Mediator不依赖其他组件。接下来就是优化这套写法，有两个优化点：


1.Mediator 每一个方法里都要写 runtime 方法，格式是确定的，这是可以抽取出来的。


2.每个组件对外方法都要在 Mediator 写一遍，组件一多 Mediator 类的长度是恐怖的。
优化后就成了 casa 的方案，target-action 对应第一点，target就是class，action就是selector，通过一些规则简化动态调用。Category 对应第二点，每个组件写一个 Mediator 的 Category，让 Mediator 不至于太长。这里有个demo
总结起来就是，组件通过中间件通信，中间件通过 runtime 接口解耦，通过 target-action 简化写法，通过 category 感官上分离组件接口代码。

##方案2

回到 Mediator 最初的三个问题，蘑菇街用的是另一种方式解决：注册表的方式，用URL表示接口，在模块启动时注册模块提供的接口，一个简化的实现：
//Mediator.m 中间件

```
@implementation Mediator
typedef void (^componentBlock) (id param);
@property (nonatomic, storng) NSMutableDictionary *cache
- (void)registerURLPattern:(NSString *)urlPattern toHandler:(componentBlock)blk {
 [cache setObject:blk forKey:urlPattern];
}

- (void)openURL:(NSString *)url withParam:(id)param {
 componentBlock blk = [cache objectForKey:url];
 if (blk) blk(param);
}
@end

```
//BookDetailComponent 组件

```
#import "Mediator.h"
#import "WRBookDetailViewController.h"
+ (void)initComponent {
 [[Mediator sharedInstance] registerURLPattern:@"weread://bookDetail" toHandler:^(NSDictionary *param) {
 WRBookDetailViewController *detailVC = [[WRBookDetailViewController alloc] initWithBookId:param[@"bookId"]];
 [[UIApplication sharedApplication].keyWindow.rootViewController.navigationController pushViewController:detailVC animated:YES];
 }];
}
//WRReadingViewController.m 调用者
//ReadingViewController.m
#import "Mediator.h"

+ (void)gotoDetail:(NSString *)bookId {
 [[Mediator sharedInstance] openURL:@"weread://bookDetail" withParam:@{@"bookId": bookId}];
}

```
这样同样做到每个模块间没有依赖，Mediator 也不依赖其他组件，不过这里不一样的一点是组件本身和调用者都依赖了Mediator，不过这不是重点，架构图还是跟方案1一样。
各个组件初始化时向 Mediator 注册对外提供的接口，Mediator 通过保存在内存的表去知道有哪些模块哪些接口，接口的形式是 URL->block。
这里抛开URL的远程调用和本地调用混在一起导致的问题，先说只用于本地调用的情况，对于本地调用，URL只是一个表示组件的key，没有其他作用，这样做有三个问题：

1.需要有个地方列出各个组件里有什么 URL 接口可供调用。蘑菇街做了个后台专门管理。

2.每个组件都需要初始化，内存里需要保存一份表，组件多了会有内存问题。

3.参数的格式不明确，是个灵活的 dictionary，也需要有个地方可以查参数格式。
第二点没法解决，第一点和第三点可以跟前面那个方案一样，在 Mediator 每个组件暴露方法的转接口，然后使用起来就跟前面那种方式一样了。

抛开URL不说，这种方案跟方案1的共同思路就是：

Mediator 不能直接去调用组件的方法，因为这样会产生依赖，那我就要通过其他方法去调用，也就是通过 字符串->方法 的映射去调用。

runtime 接口的 className + selectorName -> IMP 是一种，注册表的 key -> block 是一种，而前一种是 OC 自带的特性，后一种需要内存维持一份注册表，这是不必要的。


现在说回 URL，组件化是不应该跟 URL 扯上关系的，因为组件对外提供的接口主要是模块间代码层面上的调用，我们先称为本地调用，而 URL 主要用于 APP 间通信，姑且称为远程调用。按常规思路者应该是对于远程调用，再加个中间层转发到本地调用，让这两者分开。

那这里这两者混在一起有什么问题呢？


如果是 URL 的形式，那组件对外提供接口时就要同时考虑本地调用和远程调用两种情况，而远程调用有个限制，传递的参数类型有限制，只能传能被字符串化的数据，或者说只能传能被转成 json 的数据，像 UIImage 这类对象是不行的，所以如果组件接口要考虑远程调用，这里的参数就不能是这类非常规对象，接口的定义就受限了。
