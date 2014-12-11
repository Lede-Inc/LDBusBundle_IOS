//
//  AppDelegate.m
//  MovieStartupBundle
//
//  Created by 庞辉 on 11/21/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum{
    PatternNone = 0,
    PatternShare,
    PatternModal,
    PatternPop,
    PatternPush
}PatternType;

@interface TTFrameworkBundleObj : NSObject {
    NSString *_bundleName;          //所属bundle
    NSString *_bundleWebHost;       //所属bundle不存在时，替代的url,保留配置
    NSString *_updateURL;           //bundle自动更新的URL
    NSString *_installLevel;        //bundle自动下载的级别
    NSString *_connectorClass;      //每个bundle uibus connector的管理类；
    NSMutableArray *_urlCtrlArray;  // 配置的URL导航的viewController数组
    NSMutableDictionary *_serviceMap; //配置服务的列表
    NSMutableDictionary *_messageMap; //配置消息的列表
}

@property (nonatomic, strong) NSString *bundleName;
@property (nonatomic, strong) NSString *bundleWebHost;
@property (nonatomic, strong) NSString *updateURL;
@property (nonatomic, strong) NSString *installLevel;
@property (nonatomic, strong) NSString *connectorClass;
@property (nonatomic, strong) NSMutableArray *urlCtrlArray;
@property (nonatomic, strong) NSMutableDictionary *serviceMap;
@property (nonatomic, strong) NSMutableDictionary *messageMap;

@end

@interface TTURLViewControlObj : NSObject {
    NSString *_viewCtrlName;      //所属的ViewController的名称
    NSString *_viewCtrlClass;     //所属的ViewController的类名称
    NSString *_viewCtrlWebPath;    //所属的ViewController不存在时，替代的url
    PatternType _viewCtrlDefaultType;       //viewController的打开方式
    NSString *_viewCtrlDefaultParent;      //打开viewController的父controller,通过URL配置
    NSMutableArray *_patternArray; //viewController配置的pattern数组
}
@property (nonatomic, strong) NSString *viewCtrlName;
@property (nonatomic, strong) NSString *viewCtrlClass;
@property (nonatomic, strong) NSString *viewCtrlWebPath;
@property (nonatomic) PatternType viewCtrlDefaultType;
@property (nonatomic, strong) NSString *viewCtrlDefaultParent;
@property (nonatomic, strong) NSMutableArray *patternArray;

@end


@interface TTURLPatternObj : NSObject{
    NSString *_patternWebPath;     //为了区分默认的pattern，自定义selector需要再增加一层path
    NSString *_patternWebQuery;    //配置url pattern的query
    NSString *_patternWebFrage;    //配置url pattern的fragement
    PatternType _patternType;      //pattern的打开方式
    NSString *_patternParent;      //pattern的父controller
}

@property (nonatomic, strong) NSString *patternWebPath;
@property (nonatomic, strong) NSString *patternWebQuery;
@property (nonatomic, strong) NSString *patternWebFrage;
@property (nonatomic) PatternType patternType;
@property (nonatomic, strong) NSString *patternParent;

@end


/**
 * 解析各个framework bundle中的配置文件
 */
@interface LDBundleConfigParser : NSObject <NSXMLParserDelegate>{
}

@property (nonatomic, readonly, strong) TTFrameworkBundleObj* frameworkBundle;

@end
