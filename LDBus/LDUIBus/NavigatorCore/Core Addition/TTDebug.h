//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

/**
 *
 * Provided in this header are a set of debugging tools. This is meant quite literally, in that
 * all of the macros below will only function when the DEBUG preprocessor macro is specified.
 *
 * TTDPRINT(@"formatted log text %d", param1);
 * Print the given formatted text to the log.
 *
 * TTDCONDITIONLOG(<statement>, @"formatted log text %d", param1);
 * If <statement> is true, then the formatted text will be written to the log.
 *
 * TTDINFO/TTDWARNING/TTDERROR(@"formatted log text %d", param1);
 * Will only write the formatted text to the log if TTMAXLOGLEVEL is greater than the respective
 * TTD* method's log level. See below for log levels.
 *
 * The default maximum log level is TTLOGLEVEL_WARNING.
 */

#define TTLOGLEVEL_INFO     5
#define TTLOGLEVEL_WARNING  3
#define TTLOGLEVEL_ERROR    1

#ifndef TTMAXLOGLEVEL
    #ifdef DEBUG
        #define TTMAXLOGLEVEL TTLOGLEVEL_INFO
    #else
        #define TTMAXLOGLEVEL TTLOGLEVEL_ERROR
    #endif
#endif


// The general purpose logger. This ignores logging levels.
#ifdef DEBUG
  #define TTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
  #define TTDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG


// Log-level based logging macros.
#if TTLOGLEVEL_ERROR <= TTMAXLOGLEVEL
  #define TTDERROR(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDERROR(xx, ...)  ((void)0)
#endif // #if TTLOGLEVEL_ERROR <= TTMAXLOGLEVEL

#if TTLOGLEVEL_WARNING <= TTMAXLOGLEVEL
  #define TTDWARNING(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDWARNING(xx, ...)  ((void)0)
#endif // #if TTLOGLEVEL_WARNING <= TTMAXLOGLEVEL

#if TTLOGLEVEL_INFO <= TTMAXLOGLEVEL
  #define TTDINFO(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDINFO(xx, ...)  ((void)0)
#endif // #if TTLOGLEVEL_INFO <= TTMAXLOGLEVEL


#ifdef DEBUG
  #define TTDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
                                                  TTDPRINT(xx, ##__VA_ARGS__); \
                                                } \
                                              } ((void)0)
#else
  #define TTDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG
