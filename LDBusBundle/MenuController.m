#import "MenuController.h"

#import "LDMBusContext.h"
#import "LDMUIBusConnector.h"
#import "TTURLAction.h"

#import "LDLoginService.h"

@interface MenuController (){
    UITableView *_tableView;
    NSMutableArray *_urlArrary, *_keyArrary;
}

@end

@implementation MenuController
@synthesize page = _page;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithMenu:(MenuPage)page {
    if (self = [super init]) {
        _keyArrary = [[NSMutableArray alloc] initWithCapacity:2];
        _urlArrary = [[NSMutableArray alloc] initWithCapacity:2];
        self.page = page;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        _keyArrary = [[NSMutableArray alloc] initWithCapacity:2];
        _urlArrary = [[NSMutableArray alloc] initWithCapacity:2];
        _page = MenuPageNone;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self.view addSubview:_tableView];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resizeViewLayout:self.view.frame];
}

-(void)resizeViewLayout:(CGRect) frame {
    NSLog(@"view frame>>>>>%@", NSStringFromCGRect(self.view.frame));
    _tableView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (NSString*)nameForMenuPage:(MenuPage)page {
  switch (page) {
    case MenuPageBreakfast:
      return @"Breakfast";
    case MenuPageLunch:
      return @"Lunch";
    case MenuPageDinner:
      return @"Dinner";
    case MenuPageDessert:
      return @"Dessert";
    case MenuPageAbout:
      return @"About";
    default:
      return @"";
  }
}


- (void)setPage:(MenuPage)page {
    _page = page;
    self.navigationItem.title = [self nameForMenuPage:_page];
    NSLog(@"title===%@", self.navigationItem.title);
    UIImage* image = [UIImage imageNamed:@"tab.png"];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:image tag:0];
    
    
    [_keyArrary removeAllObjects];
    [_urlArrary removeAllObjects];
    if (_page == MenuPageBreakfast) {
        [_keyArrary addObjectsFromArray:@[@"点击push view，push:netescaipiao://food",
                                          @"push view",
                                          @"(只能在ipad测试)点击pop view，popOver:netescaipiao://food/popover/popview",
                                          @"pop view",
                                          @"点击tab switch, 跳到tab2，并push:netescaipiao://food/about/tabswitch/10",
                                          @"tab switch",
                                          @"点击model view, 打开netescaipiao://food/modeview/mode",
                                          @"mode view",
                                          @"点击测试，Htm5降级",
                                          @"消息总线测试，点击两个tabCtrl各收到一个通知"]];
        [_urlArrary addObjectsFromArray:@[@"",
                                          @"netescaipiao://food",
                                          @"",
                                          @"netescaipiao://food/popover/coffee",
                                          @"",
                                          @"netescaipiao://food/about/complaints/10",
                                          @"",
                                          @"netescaipiao://food/modeview/mode",
                                          @"netescaipiao://tabMovie",
                                          @"LocationModified"]];
    } else if (_page == MenuPageLunch) {
    } else if (_page == MenuPageDinner) {
    } else if (_page == MenuPageDessert) {
    } else if (_page == MenuPageAbout) {
        [_keyArrary addObjectsFromArray:@[@"Our Story", @"测试服务总线", @"Text Us", @"Complaints Dept."]];
        [_urlArrary addObjectsFromArray:@[@"netescaipiao://food/foo/story", @"loginService", @"sms://5555555", @"netescaipiao://food/foo/complaints"]];
    }

}


#pragma mark datasource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _keyArrary.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"tableviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *key = [_keyArrary objectAtIndex:indexPath.row];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [_urlArrary objectAtIndex:indexPath.row];
    return cell;
}


    -(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        NSString *url = [_urlArrary objectAtIndex:indexPath.row];
    if(![url isEqualToString:@""]){
        if(_page == 1){
            if(indexPath.row == 3){
                TTURLAction *action = [TTURLAction actionWithURLPath:url];
                [action applySourceView:[tableView cellForRowAtIndexPath:indexPath]];
                [LDMBusContext sendURLWithAction:action];
            } else if(indexPath.row == 8) {
                [LDMBusContext sendURL:url query:@{@"_array_":@[@"hello", @"baby"], @"_dic_": @{@"hello":@"1", @"baby":@"2"}}];
            } else if(indexPath.row == 9){
                NSNotification *notification = [NSNotification notificationWithName:url object:@"i am a object" userInfo:@{@"userInfo":@"i am form userinfo"}];
                [LDMBusContext postNotification:notification];
            }else {
                [LDMBusContext sendURL:url];
            }
        } else {
            if(indexPath.row == 1){
                [[LDMBusContext getService:url] autologin];
            } else {
                [LDMBusContext sendURL:url];
            }
        }
    }
}






@end
