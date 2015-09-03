
//
//  AuthController.m
//  test
//
//  Created by Artemy Pestretsov on 7/28/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "AuthController.h"
#import "ChatController.h"
#import "NSString+MD5.h"
#import "UserData.h"
#import "Chat.h"
#import "LoginData.h"
#import "Reachability.h"
#import "MainTabBarViewController.h"
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

@interface AuthController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UIImageView *usernameImageView;
@property (strong, nonatomic) UIView *usernameTextFieldSeparator;
@property (strong, nonatomic) UIImageView *tjLogoImageView;


@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation AuthController

#pragma mark - View lifecycle

- (void)loadView {
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITraitCollection *traitCollection = self.view.traitCollection;
    
    self.usernameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,200,30,30)];
    [self.usernameImageView setImage:[UIImage imageNamed:@"tj-logo-colored"]];
    [self.view addSubview:self.usernameImageView];
    
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.usernameImageView.frame.origin.x + self.usernameImageView.frame.size.width+10, self.usernameImageView.frame.origin.y, 200, self.usernameImageView.frame.size.height)];
    self.usernameTextField.keyboardType = UIKeyboardTypeDefault;
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTextField.placeholder = @"username";
    self.usernameTextField.delegate = self;
    [self.view addSubview:self.usernameTextField];
  
    self.usernameTextFieldSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.usernameTextField.frame.origin.x, self.usernameImageView.frame.origin.y + self.usernameTextField.frame.size.height, self.view.frame.size.width-20, 1)];
    self.usernameTextFieldSeparator.backgroundColor = [UIColor colorWithRed:0.133f green:0.067f blue:0.024f alpha:1.0f];
    [self.view addSubview:self.usernameTextFieldSeparator];
    
    NSLog(@"loadView");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    if (!self.usernameTextField.isFirstResponder) {
        [self.usernameTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.usernameTextField == textField && [textField.text length]) {
        
        [self startHandshake:textField.text];
//        ChatController *chatController = [[ChatController alloc] init];
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:[[MainTabBarViewController alloc] init]];
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - ChatAppLogic Methods

- (void)startHandshake:(NSString *)username {
    
    NSString *userId = [NSString stringWithFormat:@"%ld", [self generateRandomFrom:1 to:9999]];
    
    NSDictionary *userInfo = @{@"username": username,
                               @"name": @"User",
                               @"image": @"https://static39.cmtt.ru/paper-preview-fox/m/us/musk-longread-1/1bce7f668558-normal.jpg",
                               @"id": userId
                               };
    
    UserData *userData = [[UserData alloc] initWithDictionary:userInfo];
    LoginData *loginData = [[LoginData alloc] initWithUserData:userData];

    [[Chat sharedClient] authenticateWithLoginData:loginData];
}
     
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);

    UIAlertView* connectionAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Warning" message:@"Connection Lost" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
    
    NSLog(@"SHOW");
    
    [connectionAlertView show];
}


- (NSInteger)generateRandomFrom:(NSInteger)from to:(NSInteger)to {
    return (NSInteger)(arc4random() % (to-from+1) + from);
}

@end
