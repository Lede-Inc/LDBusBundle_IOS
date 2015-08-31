//
//  LDMBusWebControllerProtocol.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/25/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDMBusWebControllerProtocol <NSObject>
/**
 * 处理从bus总线来的url
 */
- (BOOL)handleURLFromUIBus:(NSURL *)url;

@end
