//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


typedef enum {
  TTNavigationModeNone,
  TTNavigationModeCreate,            // a new view controller is created each time
  TTNavigationModeShare,             // a new view controller is created, cached and re-used
  TTNavigationModeModal,             // a new view controller is created and presented modally
  TTNavigationModePopover,           // a new view controller is created and presented in a popover
  TTNavigationModeExternal,          // an external app will be opened
} TTNavigationMode;
