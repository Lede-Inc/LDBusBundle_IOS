//
//  LDMURLActionHandlerConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDMURLViewCtrlPatternConfigurationItem.h"

@interface LDMURLViewCtrlConfigurationItem : NSObject {
    NSString *_viewCtrlName;                //所属的ViewController的名称
    NSString *_viewCtrlClass;               //所属的ViewController的类名称
    NSString *_viewCtrlWebPath;             //所属的ViewController不存在时，替代的url
    PatternType _viewCtrlDefaultType;       //viewController的打开方式
    NSString *_viewCtrlDefaultParent;       //打开viewController的父controller,通过URL配置
    NSMutableArray *_urlViewCtrlPatternConfigurationList;          //viewController配置的pattern数组
}


@property (readonly, nonatomic) NSString *viewCtrlName;
@property (readonly, nonatomic) NSString *viewCtrlClass;
@property (readonly, nonatomic) NSString *viewCtrlWebPath;
@property (readonly, nonatomic) PatternType viewCtrlDefaultType;
@property (readonly, nonatomic) NSString *viewCtrlDefaultParent;
@property (readwrite, nonatomic) NSMutableArray *urlViewCtrlPatternConfigurationList;

-(id)initWithURLViewCtrlConfigurationItem:(NSString *)theViewCtrlName
                                    class:(NSString *)theViewCtrlClass
                                  webPath:(NSString *) theViewCtrlWebPath
                                   parent:(NSString *) theViewCtrlDefaultParent
                                     type:(PatternType) theViewCtrlDefaultType;


@end
