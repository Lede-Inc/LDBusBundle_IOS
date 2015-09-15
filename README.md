# LDBus 使用说明

## LDBus的作用

随着应用需求逐步迭代，应用的代码体积将会越来越大，为了更好的管理应用工程，我们开始借助CocoaPods版本管理工具对原有应用工程进行拆分。但是仅仅完成代码拆分还不足以解决业务之间的代码耦合，为了更好的让拆分出去的业务工程能够独立运行，实现组件服务化，我们在此引入LDBus去完成业务组件工程之间的UI跳转（UI总线）和Service服务化（ServiceBus）.

LDBus的目标：（保持业务组件的相对独立性，尽量解耦业务组件之间的代码依赖）

- 主工程只负责组装业务组件，按需所取，组合不同业务组件生成不同应用；
- 业务组件之间的UI跳转不引用任何其他业务组件工程的头文件；  
- 业务组件之间的服务调用只提供服务的接口头文件，不提供任何服务实现文件；


## LDBus如何使用

### （1）Bus如何配置

每一个业务组件工程对应一个Bus配置，将Bus配置文件放在每个独立的业务组件工程中，主要是为了让最熟悉业务逻辑的开发人员去配置。

配置步骤如下：

- 创建.Bundle资源包文件，添加一个命名为“busconfig.xml”
- 在busconfig.xml文件配置URL导航Controller和提供的Service


		<?xml version="1.0" encoding="utf-8"?>
		<bundle name="LDBusDemo" connectorClass="LDCustomConnector" version="0.1.11" customWebContainer="LDMPopWebViewController">
		    <url_handler_list>
        		<ViewController name="menu" webquery="menuID=(initWithMenu:)" class="MenuController" type="share">
	        	</ViewController>
    	    	<ViewController name="food" class="ContentController" type="push">
        	    	<URLPattern name="foo/(initWithFood:)" webquery=""/>
            		<URLPattern name="type/(initWithType:)"/>
            		<URLPattern name="popover/(initWithFood:)" type="pop"/>
            		<URLPattern name="modeview" webquery="param=(initWithFood:)" type="modal"/>
            		<URLPattern name="about/(initWithUs:)/(others:)" parent="menu?menuID=5" type="push"/>
        		</ViewController>
    	</url_handler_list>
    	<service_list>
        	<service name="loginService" class="LDLoginServiceImpl"  protocol="LDLoginService"/>
    	</service_list>
		</bundle>


配置选项说明：

- bundle 选项说明

		name: 组件名称 
		
		version: 组件版本
		
		connectorClass: 自定义UIBus Connector的实现类名（注意需要集成LDMUIBusConnector）可选
		
		host: URL降级host，如“http://piao.163.com” 可选
		
		customWebContainer: URL降级的外部定制的WebContainer（需要遵循LDMWebContainerProtocol）可选，默认为Bus的简单Web容器
		
		
- url_handler_list UI总线配置
- ViewController UI总线配置的可导航Controller (URL)
		
		class: UI总线URL对应的Controller实现类名
		
		type：Controller被创建或者打开的方式，目前有share（共享controller）、push（通过Navigation Push打开）、modal(Modal或者Present打开)、pop(ipad上的popover打开) 可选 默认为push方式
		
		parent: 配置当前Controller的parentController的URL 可选
		
		name：UI总线URL的host+path选项，如：**或者**/**/**
		
		webpath: URL降级的path选项配置，如：/wap/index.html 可选 （当class未实现且webpath也未配置情况下，编译阶段提示）
		
		webquery: UI总线URL的query选项，用于初始化Controller的参数传递，如: XX=(XX:)&YY=(YY:)  可选 默认通过initWithNavigation:query: 或者initWithNibName:bundle: 或者init 方式打开
		
- URLPattern 用于配置ViewController被多种方式打开的情况下

		tip：path选项继承ViewController的name选项，其他选项和Controller相同
		
- service_list Service总线配置
- service 服务总线选项配置

		name： 服务名称，一般在提供protocol中通过宏定义对外提供
		
		protocol: 服务遵守的接口协议类名
		
		class: 服务具体的实现类名，实现类必须遵守服务的接口协议 服务protocol和implemention分开


### （2）Bus启动

在主工程和各个业务组件工程中皆可使用Bus，业务组件可以使用Bus调用其他组件提供的URL跳转配置和提供的服务； 主工程在拆分结束之前也可以使用Bus进行配置以及调用其他组件提供的bus服务（只是业务组件工程无法依赖主工程，也就无法做依赖主工程的业务调试）。


所有的Bus调用接口均封装在LDMBusContext中，使用者可以查看头文件确定具体使用方式。

>
tip：由于集成Bus之后，对Bus头文件的引用会比较频繁，建议将LDMBusContext.h 放到头文件预处理中。


在AppDelegate中完成Bus启动，启动时机在appdelegate的window初始化成功之后:

	//bus容器初始化
    [LDMBusContext initialBundleContainerWithWindow:self.window andRootViewController:nil];

>
tip: rootViewController可以不作为启动参数（因为在tabController设置为rootViewController前，可能需要通过URL获取各个tab），bus会在启动window设置rootViewController自动设置Bus导航器navigator的rootViewController。


### （3）如何使用UIBus和服务Bus


使用UIBus的几种情形，通过［LDMBusContext  XXMethod］完成调用


	(1) 简单数字和字符参数可以配置到URL中传递，调用方式如下：
	
		+(BOOL)openURL:(NSString *)url;
		
	(2) 如果还需要传递Object参数，将object参数封装到query中，controller实例化方法从中获取：
		
		+(BOOL)openURL:(NSString *)url query:(NSDictionary *)query;
		
	(3) 如果需要传递更多展示Controller的参数，如parentURLPath(父Controller的URL), animated（是否展示动画）, sourceRect(popOver的源view)， sourceViewController(已经初始化的父亲Controller)， 则可以调用TTURLAction.h 进行封装， 调用如下：
	
		+(BOOL)openURLWithAction:(TTURLAction *)action;
	
	（4）如果只是想获得一个Controller实例，而不想马上展示，可以调用如下方法获得：
	
		+(UIViewController *)controllerForURL:(NSString *)url;
		+(UIViewController *)controllerForURL:(NSString *)url query:(NSDictionary *)query;


另外还可以判断是否能够通过URL导航：

	+(BOOL)canOpenURL:(NSString *)url;
	
	
业务组件提供的服务Bus使用如下：

- （1）引用业务组件提供的服务接口文件；（接口文件可以定义一些消息Notification的name）

		#import <LDCILogin/LDCILoginSessionService.h>
		
		#define SERVICE_LDCILOGINSESSION      @"ldci_loginsessionService"
		#define kAccountLoginNotification     @"AccountLoginNotifcation"
		#define kAccountLogoutNotification    @"AccountLogoutNotifcation"
		
		@protocol LDCILoginSessionService <NSObject>
		
		/**
		 *  自动登录
		 */
		- (void)autoLogin;
		
		@end
		
		

- （2）通过Bus获取Service实例，调用服务接口方法即可

		[[LDMBusContext getService:SERVICE_LDCILOGINSESSION]  autoLogin];



## UIBus的Connector扩展以及兼容JLRoute

UIBus提供了基于Connector基础上的URL跳转扩展，主要是基于以下两个原因：

1. 之前彩票项目使用了JLRoute进行页面跳转，JLRoute导航有如下特点：

(1) 如果没有在调用之前统一register短链，则需要在使用之前先register短链，然后再通过JLRoute进行导航; (2) 每次注册需要引入短链的注册头文件; (3) 每个业务组件工程通过代码完成对外提供的短链，代码部分主要完成viewController的创建和展示；


2. 其次在具体使用UIBus过程中，某些URL可能需要通过一个URL在不同情况下跳转到不同的Controller，或者说是想自行去完成页面动画的展示效果；

Connector的扩展需要继承Bus提供LDMUIBusConnector，然后在其基础上重写几个类方法实现。拿彩票的扩展举个例子：

- （1）继承

		#import "LDMUIBusConnector.h"

		@interface LDCPHostConnector : LDMUIBusConnector {
		}
		@end

- （2）重写部分方法（参看 @interface LDMUIBusConnector(ToBeOverwrite)）彩票Host的connector举例：

		//初始化的时候注册通过JLRoute导航的短链注册
		-(id)init
		{
		    if (self = [super init]) {
        		//注册routes
		        [CTabBarController registerRoutes];
		     }
		}
		
		
		#pragma mark -
		#pragma mark - UIBusConnector

		/**
		 * host的优先处理级最低，最后处理
		 */
		-(LDMConnectorPriority)connectorPriority{
		    return LDMConnectorPriority_HOSTLOW;
		}


		/**
		 * 判断是否能够处理URL
		 */
		-(BOOL)canOpenInBundle:(NSString *)url{
		    if (!url || ![url length]) {
    		    return NO;
    		}
    
		    _isOpenWithJLRoute = YES;
		    if([super canOpenInBundle:url]){
        		_isOpenWithJLRoute = NO;
		        return YES;
		    } else {
        		NSURL *URL = [NSURL URLWithString:url];
		        //短链接通过JLRoute判断
        		if ([[LotteryApplication sharedApplication] isInAppUrl:URL]) {
		            return [JLRoutes canRouteURL:URL];
        		}
        
		        //JLRoute也可以处理web链接
        		else {
		            NSString *scheme = URL.scheme;
        		    if ([scheme compare:@"http" options:NSCaseInsensitiveSearch] == 						NSOrderedSame || [scheme compare:@"https" 						options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			                return YES;
    		        }
        		}
        
        		return NO;
    		}
		}



		/**
		 * 根据URLAction同时完成生成ViewController和展示ViewController的过程
		 */
		-(BOOL) dealWithURLMessageFromBus:(TTURLAction *)action{
		    if(_isOpenWithJLRoute){
        		NSURL *URL = [NSURL URLWithString:action.urlPath];
         		//登录特殊处理
	        	if (URL.host && [URL.host caseInsensitiveCompare:@"login"] == 					NSOrderedSame) {
	            	return [self processLoginUrl:URL 					withTopmostViewController:self.navigator.topViewController];
	        	}
        
    	    	//需要登录，保存URL,登录成功后重新调用
        		else if([[LotteryApplication sharedApplication] isNeedLogin:URL]){
            		_loginPendingUrl = URL.absoluteString;
            		LoginController *controller = [LoginController getControllerInstance];
            		controller.delegate = self;
            		UINavigationController *navController = 					[[UINavigationController alloc] initWithRootViewController:controller];
           		 	[self.navigator.topViewController presentModalViewController:navController animated:YES];
            		return YES;
        		}
        
	        	//通过JLRoute进行导航
    	    	else{
        	    	if(action.sourceViewController == nil){
            	    	action.sourceViewController = self.navigator.topViewController;
            		}
            
            		if([JLRoutes routeURL:[NSURL URLWithString:action.urlPath] withParameters:@{kLDRouteViewControllerKey:action.sourceViewController}]){
                		return YES;
	            	} else {
    	            	return NO;
        	    	}
        		}//else
    		}
    
    		//通过UIBus的config文件配置进行导航
    		else {
        		return [super dealWithURLMessageFromBus:action];
    		}
		}

- （3）在busconfig.xml文件中配置自定义的connector，只需要配置connectorClass的值即可

		<?xml version="1.0" encoding="utf-8"?>
		<bundle name="LDCPBHost" connectorClass="LDCPHostConnector">
		    <url_handler_list>
		    </url_handler_list>
    		<service_list>
		    </service_list>
		</bundle>



## 特殊Scheme的Web处理容器配置

LDBus中目前并没有对scheme进行匹配，对特殊scheme(主要是http，https，files)的处理继承了JLRoute的方式，

- （1）注册特殊scheme的web处理容器，可以以Modal或者Push方式打开:

		//注册特殊scheme的web处理容器
	    //默认通过modal方式打开
    	[LDMBusContext registerSpecialScheme:@"http" addRoutes:@"*" handleController:@"LDMPopWebViewController"];
	    //push方式打开
    	[LDMBusContext registerSpecialScheme:@"https" addRoutes:@"*" handleController:@"LDMPopWebViewController" isModal:NO];
	    [LDMBusContext registerSpecialScheme:@"file" addRoutes:@"*" handleController:@"LDMPopWebViewController"];


- （2）handleController必须遵守LDMBusWebControllerProtocol协议, 用于处理从Bus匹配过来的URL：

		@protocol LDMBusWebControllerProtocol <NSObject>
		/**
		 * 处理从bus总线来的url
		 */
		-(BOOL)handleURLFromUIBus:(NSURL *)url;
		@end



## 扩展配置UIBus的降级处理器（WebContainer）

目前前端和客户端的开发联动性还比较薄，不过LDBus还是提供了UIBus降级处理容器的外部扩展，只需要在前文的bundle配置选项中配置：
customWebContainer，如果不扩展，就调用默认的webContainer，无法使用JSbridge联动，只有页面展示。

外部扩展容器主要是为了跟每个产品自行封装的JSBridge联动，只需要在JSBridge的容器中遵守一个实例化接口协议（LDMWebContainerProtocol）即可。

	#define TTDEGRADE_URL @"_ttdegrade_url_"

	/**
	 * @protocol 所有定制降级打开WebContainer需要继承的接口
	 */
	@protocol LDMWebContainerProtocol <NSObject>
	
	@required
	/**
	 * 定制webContainer初始化接口
	 * 可以从query对象中通过TTDEGRADE_URL作为Key获取降级urlString
	 */
	-(id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;

	@end


## 技术支持
-------------------

>
to be continued ....



庞辉, 电商技术中心，popo：__huipang@corp.netease.com__
