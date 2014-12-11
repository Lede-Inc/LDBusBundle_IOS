#import <UIKit/UIKit.h>

typedef enum {
  ContentTypeNone,
  ContentTypeFood,
  ContentTypeNutrition,
  ContentTypeAbout,
  ContentTypeOrder,
} ContentType;

@interface ContentController : UIViewController {
  ContentType _contentType;
  NSString* _content;
  NSString* _text;
}

@property(nonatomic,copy) NSString* content;
@property(nonatomic,copy) NSString* text;

@end
