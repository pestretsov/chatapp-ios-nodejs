//
//  MainTabBarViewController.m
//  ChatApp
//
//  Created by Artemy Pestretsov on 9/3/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "ChatController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIViewController *chatController = [[ChatController alloc] init];
    
    self.viewControllers = [[NSArray alloc] initWithObjects:chatController, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
