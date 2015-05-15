//
//  LDMWebContainerProtocol.h
//  LDBusBundle
//
//  Created by 庞辉 on 5/15/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

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
