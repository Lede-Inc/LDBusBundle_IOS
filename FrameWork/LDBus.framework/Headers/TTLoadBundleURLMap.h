//
//  TTLoadBundleURLMap.h
//  LDBusBundle
//
//  Created by 庞辉 on 11/28/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTNavigator.h"
#import "TTURLMap.h"

@interface TTLoadBundleURLMap : NSObject {
    
}
+(BOOL)loadURLMapsFromConfigs:(TTURLMap *)map;
@end
