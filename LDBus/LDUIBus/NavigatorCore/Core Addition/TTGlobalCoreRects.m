//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "TTGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(TTRectContract(rect, dx, dy), dx, dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTRectInset(CGRect rect, UIEdgeInsets insets) {
  return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
                    rect.size.width - (insets.left + insets.right),
                    rect.size.height - (insets.top + insets.bottom));
}
