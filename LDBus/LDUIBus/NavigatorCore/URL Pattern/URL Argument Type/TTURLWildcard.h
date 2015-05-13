//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLPatternText.h"
#import "TTURLArguments.h"

/**
 * @class 生成urlPattern中的selector选项（参数）
 */
@interface TTURLWildcard : NSObject <TTURLPatternText> {
    NSString*         _name;        //selector参数名称
    NSInteger         _argIndex;    //参数的位置
    TTURLArgumentType _argType;     //参数的类型
}

@property (nonatomic, copy)   NSString*         name;
@property (nonatomic)         NSInteger         argIndex;
@property (nonatomic)         TTURLArgumentType argType;
@end
