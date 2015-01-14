//
//  LDMBusContext.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/10/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMBusContext.h"
#import "LDMContainer.h"

@implementation LDMBusContext

+(void)initialBundleContainerWithWindow:(UIWindow *)window andRootViewController:(UIViewController *)rootViewController{
    //初始化容器和window
    [[LDMContainer container] setNavigatorRootWindow:window];
    
    [LDMBusContext initialBundleContainerWithRootViewController:rootViewController];
}

+(void)initialBundleContainerWithRootViewController:(UIViewController *)rootViewController {
    //先初始化容器
    [[LDMContainer container] preloadConfig];
    
    //在设置rootViewController
    if(rootViewController){
        [[LDMContainer container] setNavigatorRootViewController:rootViewController];
    }
}

@end
