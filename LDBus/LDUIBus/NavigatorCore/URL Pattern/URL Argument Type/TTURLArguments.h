//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TTURLArgumentTypeNone,
    TTURLArgumentTypePointer,
    TTURLArgumentTypeBool,
    TTURLArgumentTypeInteger,
    TTURLArgumentTypeLongLong,
    TTURLArgumentTypeFloat,
    TTURLArgumentTypeDouble,
} TTURLArgumentType;

TTURLArgumentType TTConvertArgumentType(char argType);
TTURLArgumentType TTURLArgumentTypeForProperty(Class cls, NSString* propertyName);

