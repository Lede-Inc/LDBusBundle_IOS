//
//  LDFBundleDownloader.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/6/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDBundleDownloadListener <NSObject>

/**
 * 是否下载结束
 */
-(void) downloaderOnFinish:(long long) statusCode;


/**
 * 下载进度
 */
-(void)downloaderOnProgress:(long long) written total:(long long) total;

@end


/**
 * @class 完成远程Bundle（dynamic framework）的下载
 * 只负责完成制定url对应的.framework文件的下载
 */
@interface LDFBundleDownloader : NSObject {
    
}


/**
 * 根据下载地址下载BundlePackage（framework）到本地
 * @param downloadURL 下载地址
 * @param listener 下载进度监听
 */
+(void) updateRemoteBundlePackage:(NSString *)downloadURLString delegate:(id<LDBundleDownloadListener>) listener;

@end
