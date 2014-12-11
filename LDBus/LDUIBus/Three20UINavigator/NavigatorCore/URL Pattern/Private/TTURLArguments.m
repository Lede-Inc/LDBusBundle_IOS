//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLArguments.h"
#import <objc/runtime.h>

TTURLArgumentType TTConvertArgumentType(char argType) {
    if (argType == 'c'
        || argType == 'i'
        || argType == 's'
        || argType == 'l'
        || argType == 'C'
        || argType == 'I'
        || argType == 'S'
        || argType == 'L') {
        return TTURLArgumentTypeInteger;
        
    } else if (argType == 'q' || argType == 'Q') {
        return TTURLArgumentTypeLongLong;
        
    } else if (argType == 'f') {
        return TTURLArgumentTypeFloat;
        
    } else if (argType == 'd') {
        return TTURLArgumentTypeDouble;
        
    } else if (argType == 'B') {
        return TTURLArgumentTypeBool;
        
    } else {
        return TTURLArgumentTypePointer;
    }
}



TTURLArgumentType TTURLArgumentTypeForProperty(Class cls, NSString* propertyName) {
    objc_property_t prop = class_getProperty(cls, propertyName.UTF8String);
    if (prop) {
        const char* type = property_getAttributes(prop);
        return TTConvertArgumentType(type[1]);
        
    } else {
        return TTURLArgumentTypeNone;
    }
}
