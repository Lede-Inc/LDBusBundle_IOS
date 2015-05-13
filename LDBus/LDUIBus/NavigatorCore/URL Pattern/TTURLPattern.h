//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TTURLPatternText;

/**
 * @class TTURLPattern
 * 用来记录URL消息的pattern对象
 */
@interface TTURLPattern : NSObject {
    NSString*             _URL;     //urlpattern
    NSString*             _webURL;  //urlpattern对应的html5页面地址
    
    NSString*             _scheme;
    NSMutableArray*       _path;  //用来存储path选项
    NSMutableDictionary*  _query; //用来存储query选项
    id<TTURLPatternText>  _fragment; 
    NSInteger             _specificity;
    SEL                   _selector;
}

@property (nonatomic, copy)     NSString* URL;
@property (nonatomic, copy)     NSString* webURL;
@property (nonatomic, readonly) NSString* scheme;
@property (nonatomic, readonly) NSInteger specificity;
@property (nonatomic, readonly) Class     classForInvocation;
@property (nonatomic)           SEL       selector;

/**
 * 给pattern设置对应的init selector
 */
- (void)setSelectorIfPossible:(SEL)selector;
- (void)setSelectorWithNames:(NSArray*)names;



/**
 * 解析URL pattern
 */
- (void)compileURL;

@end
