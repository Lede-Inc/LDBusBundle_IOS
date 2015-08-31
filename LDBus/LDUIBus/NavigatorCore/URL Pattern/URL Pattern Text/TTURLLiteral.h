//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLPatternText.h"

/**
 * @class 生成一个普通的url pattern选项，区别于带行参的参数
 */
@interface TTURLLiteral : NSObject <TTURLPatternText> {
    NSString *_name;
}
@property (nonatomic, copy) NSString *name;
@end
