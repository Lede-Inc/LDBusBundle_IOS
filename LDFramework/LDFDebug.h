//
//  LDFDebug.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/6/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#ifndef LDBusBundle_LDFDebug_h
#define LDBusBundle_LDFDebug_h

#ifdef DEBUG
#define LOG(xx, ...)  NSLog(@"LDFramework[func:%s,line:%d]: " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LOG(xx, ...)  ((void)0)
#endif // #ifdef DEBUG



#endif
