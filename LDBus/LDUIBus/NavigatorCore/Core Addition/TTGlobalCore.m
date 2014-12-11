//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "TTGlobalCore.h"

#import <objc/runtime.h>

// No-ops for non-retaining objects.
static const void* TTRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void TTReleaseNoOp(CFAllocatorRef allocator, const void *value) { }


///////////////////////////////////////////////////////////////////////////////////////////////////
NSMutableArray* TTCreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = TTRetainNoOp;
  callbacks.release = TTReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSMutableDictionary* TTCreateNonRetainingDictionary() {
  CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
  CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
  callbacks.retain = TTRetainNoOp;
  callbacks.release = TTReleaseNoOp;
  return (NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsArrayWithItems(id object) {
  return [object isKindOfClass:[NSArray class]] && [(NSArray*)object count] > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsSetWithItems(id object) {
  return [object isKindOfClass:[NSSet class]] && [(NSSet*)object count] > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsStringWithAnyText(id object) {
  return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTSwapMethods(Class cls, SEL originalSel, SEL newSel) {
  Method originalMethod = class_getInstanceMethod(cls, originalSel);
  Method newMethod = class_getInstanceMethod(cls, newSel);
  method_exchangeImplementations(originalMethod, newMethod);
}
