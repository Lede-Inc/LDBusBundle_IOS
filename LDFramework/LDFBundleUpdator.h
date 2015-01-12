//
//  LDFBundleUpdator.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDFBundleUpdatorListener <NSObject>

/**
 * 信息parse完成之后，返回一个关于远程更新组件的信息数组
 */
-(void)updatorOnSuccess:(NSArray *)bundleInfoArray;

/**
 * 请求信息失败
 */
-(void)updatorOnFailure;

@end

/**
 * @class 检查服务器端组件的更新信息
 *
 */
@interface LDFBundleUpdator : NSObject


/**
 * 根据更新URL查看服务器端组件更新信息
 * @param refreshURLString 服务器端组件更新URL
 * @param listener 组件信息查询监听
 */
+(void)refreshRemoteBundleInfoWithURL:(NSString *) refreshURLString delegate:(id<LDFBundleUpdatorListener>) listener;


@end
