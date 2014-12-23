//
//  LDDemoMessageHandler.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/23/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDDemoMessageHandler.h"

@implementation LDDemoMessageHandler

-(void)didReceiveMessageNotification:(NSNotification *)notification {
    if([notification.name isEqualToString:@"LocationModified"]){
        id object = notification.object;
        NSDictionary *dic_userInfo = notification.userInfo;
        NSString *message =[NSString stringWithFormat:@"message excute....: %@, %@", object, [dic_userInfo objectForKey:@"userInfo"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息总线" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
