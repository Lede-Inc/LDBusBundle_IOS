//
//  LDLoginServiceImpl.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/4/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LDLoginServiceImpl.h"

@implementation LDLoginServiceImpl
-(void)autologin {
    NSLog(@"I am busy with auto loging.....");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"服务总线" message:@"我是LoginService的提供的服务，已经完成自动登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
