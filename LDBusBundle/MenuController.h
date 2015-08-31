#import <UIKit/UIKit.h>

typedef enum {
    MenuPageNone,
    MenuPageBreakfast,
    MenuPageLunch,
    MenuPageDinner,
    MenuPageDessert,
    MenuPageAbout,
} MenuPage;

@interface MenuController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    MenuPage _page;
}

@property (nonatomic) MenuPage page;

- (id)initWithMenu:(MenuPage)page;

@end
