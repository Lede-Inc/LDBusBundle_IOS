//
//  LDMBundleConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDMBundleConfigurationItem : NSObject {
    BOOL _isMainbundle;
    BOOL _hasFirstEnterVC;
    BOOL _hasBundleImage;
    NSString *_bundleName;

    NSString *_bundleWebHost;  //所属bundle不存在时，替代的url,保留配置
    NSString *_updateURL;  // bundle自动更新的URL
    NSString *_installLevel;  // bundle自动下载的级别
    NSString *_connectorClass;           //每个bundle uibus connector的管理类；
    NSString *_version;                  //当前bundle的版本号；
    NSString *_customWebContainerClass;  //自定义的降级webController；（可以集成JSBridge）


    NSMutableArray *_urlViewCtrlConfigurationList;  // url直接open列表，url直接和ViewController对应
    NSMutableArray *_serviceConfigurationList;  // service配置列表
    NSMutableArray *_postMessageConfigurationList;     //发送消息配置列表
    NSMutableArray *_receiveMessageConfigurationList;  //接收消息配置列表
}

@property (readonly, nonatomic) BOOL isMainBundle;
@property (nonatomic) BOOL hasFirstEnterVC;
@property (readonly, nonatomic) BOOL hasBundleImage;
@property (readonly, nonatomic) NSString *bundleName;

@property (readonly, nonatomic) NSString *bundleWebHost;
@property (readonly, nonatomic) NSString *updateURL;
@property (readonly, nonatomic) NSString *installLevel;
@property (readonly, nonatomic) NSString *connectorClass;
@property (readonly, nonatomic) NSString *version;
@property (readonly, nonatomic) NSString *customWebContainerClass;

@property (readwrite, nonatomic) NSMutableArray *urlViewCtrlConfigurationList;
@property (readwrite, nonatomic) NSMutableArray *serviceConfigurationList;
@property (readwrite, nonatomic) NSMutableArray *postMessageConfigurationList;
@property (readwrite, nonatomic) NSMutableArray *receiveMessageConfigurationList;

+ (BOOL)isURLConfigurationSame:(id)arg1 toItem:(id)arg2;
+ (BOOL)checkDuplicateBetweenItem:(id)arg1 andItem:(id)arg2;
- (BOOL)checkDuplicateMyself;

- (id)initWithBundleConfigurationItem:(NSString *)theBundleName
                               isMain:(BOOL)theIsMainBundle
                      hasFirstEnterVC:(BOOL)theHasFirstEnterVC
                       hasBundleImage:(BOOL)theHasBundleImage
                           bundleHost:(NSString *)theBundleWebHost
                            updateURL:(NSString *)theUpdateURL
                         installLevel:(NSString *)theInstallLevel
                       connectorClass:(NSString *)theConnetorClass
                              version:(NSString *)theVersion
              customWebContainerClass:(NSString *)theCustomWebContainerClass;

@end
