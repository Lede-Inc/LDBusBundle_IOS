#import "ContentController.h"

@implementation ContentController

@synthesize content = _content, text = _text;

//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)orderAction:(NSString*)action {
}

- (void)showNutrition {
  //TTOpenURL([NSString stringWithFormat:@"tt://food/%@/nutrition", self.content]);
}


-(id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self =[super init];
    if(self){
        
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject
-(id)initWithType:(int) type query:(NSDictionary *)query {
    NSArray *array = [query objectForKey:@"_array_"];
    NSDictionary *dic = [query objectForKey:@"_dic_"];
    self = [super init];
    if(self){
        for(int i=0; i < array.count; i++){
            NSLog(@">>>index=%d:value=%@",i, [array objectAtIndex:i]);
        }
        
        NSArray *keys = dic.allKeys;
        for(int j=0; j<keys.count; j++){
            NSLog(@">>>key=%@:value=%@", [keys objectAtIndex:j], [dic objectForKey:[keys objectAtIndex:j]]);
        }
        
    }
    return self;
}


- (id)initWithWaitress:(NSString*)waitress query:(NSDictionary*)query {
  if (self = [super init]) {
    _contentType = ContentTypeOrder;
    self.content = waitress;
    self.text = [NSString stringWithFormat:@"Hi, I'm %@, your imaginary waitress.", waitress];

    self.title = @"Place Your Order";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Order" style:UIBarButtonItemStyleDone
        target:@"tt://order/confirm" action:@selector(openURL)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered
        target:self action:@selector(dismiss)];
  }
  return self;
}

- (id)initWithFood:(NSString*)food {
  if (self = [super init]) {
    _contentType = ContentTypeFood;
    self.content = food;
    self.text = [NSString stringWithFormat:@"<b>%@</b> is just food, ya know?", food];

    self.title = food;
    self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Nutrition" style:UIBarButtonItemStyleBordered
                                target:self action:@selector(showNutrition)];
  }
  return self;
}

- (id)initWithModeController:(NSString*)food {
    if (self = [super init]) {
        _contentType = ContentTypeFood;
        self.content = food;
        self.text = [NSString stringWithFormat:@"<b>%@</b> is just food, ya know?", food];
        
        self.title = food;
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"dissmiss" style:UIBarButtonItemStyleBordered
                                         target:self action:@selector(dismiss)];
    }
    return self;
}


-(void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (id)initWithNutrition:(NSString*)food {
  if (self = [super init]) {
    _contentType = ContentTypeNutrition;
    self.content = food;
    self.text = [NSString stringWithFormat:@"<b>%@</b> is healthy.  Trust us.", food];

    self.title = @"Nutritional Info";
  }
  return self;
}

- (id)initWithAbout:(NSString*)about {
  if (self = [super init]) {
    _contentType = ContentTypeAbout;
    self.content = about;
    self.text = [NSString stringWithFormat:@"<b>%@</b> is the name of this page.  Exciting.", about];

    if ([about isEqualToString:@"story"]) {
      self.title = @"Our Story";
    } else if ([about isEqualToString:@"complaints"]) {
      self.title = @"Complaints Dept.";
    }
  }
  return self;
}

- (id)initWithUs:(NSString*)about others:(int)page {
    if (self = [super init]) {
        _contentType = ContentTypeAbout;
        self.content = about;
        self.text = [NSString stringWithFormat:@"<b>%@</b> is the name of this page.  Exciting.", about];
        self.title = [NSString stringWithFormat:@"two parameter:about=%@,page=%d", about,page];
    }
    return self;
}


- (id)init {
  if (self = [super init]) {
    _contentType = ContentTypeNone;
    _content = nil;
    _text = nil;
  }
  return self;
}

- (void)dealloc {
    _content=nil;
    _text = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  CGRect frame = CGRectMake(10, 10, self.view.frame.size.width-20, 100);
  UILabel* label = [[UILabel alloc] initWithFrame:frame];
  label.tag = 42;
  label.font = [UIFont systemFontOfSize:22];
  [self.view addSubview:label];

  if (_contentType == ContentTypeNutrition) {
    self.view.backgroundColor = [UIColor grayColor];
    label.backgroundColor = self.view.backgroundColor;
    self.hidesBottomBarWhenPushed = YES;
  } else if (_contentType == ContentTypeAbout) {
	  self.view.backgroundColor = [UIColor grayColor];
	  label.backgroundColor = self.view.backgroundColor;
  } else if (_contentType == ContentTypeOrder) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"What do you want to eat?" forState:UIControlStateNormal];
    [button addTarget:@"tt://order/food" action:@selector(openURLFromButton:)
            forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    CGFloat y = label.frame.origin.y + label.frame.size.height + 20;
    CGFloat x = floor(self.view.frame.size.width/2 - button.frame.size.width/2);
    button.frame = CGRectMake(x, y, button.frame.size.width, 100.0f);
    [self.view addSubview:button];
  }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UILabel* label = (UILabel*)[self.view viewWithTag:42];
    label.text = _text;
}

@end
