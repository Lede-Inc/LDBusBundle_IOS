//
//
//  Created by 庞辉 on 11/21/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <UIKit/UIKit.h>

/**
 * 解析各个framework bundle中的配置文件
 */
@class LDMBundleConfigurationItem;
@interface LDMBundleConfigParser : NSObject <NSXMLParserDelegate> {
}

@property (nonatomic, readonly, strong) LDMBundleConfigurationItem *configurationItem;

@end
