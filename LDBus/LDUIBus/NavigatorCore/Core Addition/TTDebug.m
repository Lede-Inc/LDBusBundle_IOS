//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "TTDebug.h"

#ifdef DEBUG

#if TARGET_IPHONE_SIMULATOR

#import <unistd.h>
#import <sys/sysctl.h>

// From: http://developer.apple.com/mac/library/qa/qa2004/qa1361.html
int TTIsInDebugger(void) {
  int                 mib[4];
  struct kinfo_proc   info;
  size_t              size;

  // Initialize the flags so that, if sysctl fails for some bizarre
  // reason, we get a predictable result.

  info.kp_proc.p_flag = 0;

  // Initialize mib, which tells sysctl the info we want, in this case
  // we're looking for information about a specific process ID.

  mib[0] = CTL_KERN;
  mib[1] = KERN_PROC;
  mib[2] = KERN_PROC_PID;
  mib[3] = getpid();

  // Call sysctl.

  size = sizeof(info);
  sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);

  // We're being debugged if the P_TRACED flag is set.

  return (info.kp_proc.p_flag & P_TRACED) != 0;
}

#endif // #ifdef TARGET_IPHONE_SIMULATOR

#endif // #ifdef DEBUG
