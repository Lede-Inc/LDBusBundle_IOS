//
//  LDCustomConnector.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/12/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDCustomConnector.h"
#import "LDNavigator.h"
#import "TTURLAction.h"

@implementation LDCustomConnector

#pragma mark - overwite
/**
 * 如果没有自定义的拦截，可以不重载
 * 比如说一些URL没有在config中定义出来，只是口头约定，可以在这里添加
 */
-(BOOL) canOpenInBundle:(NSString *)url {
    BOOL iscan = [super canOpenInBundle:url];
    if(!iscan) {
        if([url isEqualToString:@"XX://XX/XX?XX#XX"]){
            iscan = YES;
        }
    }
    
    return iscan;
}


/**
 *  拦截action请求，过滤action中的URL，使用自定义的方式生成一个ViewController
 *  也可以处理ctrl生成为空的情况
 */
-(UIViewController *) viewControllerForAction:(TTURLAction *)action {
    UIViewController *ctrl = [super viewControllerForAction:action];
    if(ctrl == nil) {
        ctrl = [[UIViewController alloc] init];
    }
    
    return ctrl;
}



/**
 * 如果要按照自己的展示逻辑展示，则调用navigator获取当前的topViewController，rootViewController，
 * 注意root没有初始化的问题
 * 如果不想自行处理，可以不继承，或者返回NO；
 */
-(BOOL) presentViewController:(UIViewController *)controller
                    navigator:(LDNavigator *)navigator
                       action:(TTURLAction *)action {
    BOOL success = [super presentViewController:controller navigator:navigator action:action];
    if(!success) {
        //自定义展示方式：
        //获取当前显示的ViewController navigator.topViewController
        //获取当前的rootViewCOntroller navigator.rootViewController
        if(navigator.rootViewController == nil){
            [navigator presentController:controller parentURLPath:action.parentURLPath withPattern:nil action:action];
            success = YES;
        } else {
            success  = NO;
        }
    }
    
    return success;
}

@end
