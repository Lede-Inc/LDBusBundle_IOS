//
//  LDMPopWebViewController.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/25/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMPopWebViewController.h"

@implementation LDMPopWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    if ([self isModalStyle]) {
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"close"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(dismiss)];
    } else {
        NSLog(@"left>>>>>");
    }
}


- (BOOL)isModalStyle
{
    if (self.navigationController && self.navigationController.viewControllers.count == 1 &&
        self.presentingViewController) {
        return YES;
    }
    return NO;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)handleURLFromUIBus:(NSURL *)url
{
    [self openURL:url];

    return YES;
}

@end
