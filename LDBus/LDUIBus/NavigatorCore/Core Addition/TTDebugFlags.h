//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



/**
 * These flags are used primarily by TTDCONDITIONLOG.
 * Example:
 *
 *    TTDCONDITIONLOG(TTDFLAG_NAVIGATOR, @"TTNavigator activated");
 *
 * This will only write to the log if the TTDFLAG_NAVIGATOR is set to non-zero.
 */
#define TTDFLAG_VIEWCONTROLLERS             0
#define TTDFLAG_CONTROLLERGARBAGECOLLECTION 0
#define TTDFLAG_NAVIGATOR                   0
#define TTDFLAG_TABLEVIEWMODIFICATIONS      0
#define TTDFLAG_LAUNCHERVIEW                0
#define TTDFLAG_URLREQUEST                  0
#define TTDFLAG_URLCACHE                    0
#define TTDFLAG_XMLPARSER                   0
#define TTDFLAG_ETAGS                       0
