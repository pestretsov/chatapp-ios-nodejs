
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
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

@interface AuthController () <UITextFieldDelegate>

@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) UserData *userMe;

@property (weak, nonatomic) IBOutlet UIImageView *LogoImageView;
@property (weak, nonatomic) IBOutlet UITextField *loginTextView;
@property (strong, nonatomic) SocketIOClient *socket;

@property CGFloat kHeight;

@end

@implementation AuthController

static NSString *port = @"localhost:3000";
static NSString *salt = @"salt";

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    _loginTextView.delegate = self;
    // sorry for that:)
    _LogoImageView.image = [UIImage imageNamed:@"tj-logo-colored"];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.view addGestureRecognizer:tap];
    [self.loginTextView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object: nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard events

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.loginTextView == textField && [textField.text length]) {
        
        [self startHandshake:textField.text];
        ChatController *chatController = [[ChatController alloc] init];

        chatController.socket = self.socket;
        chatController.userMe = self.userMe;
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:chatController];
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)dismissKeyboard:(BOOL)animated {
    [self.loginTextView resignFirstResponder];
}

// FIX
// fix bug with hardware keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary * userInfo = notification.userInfo;
    if (userInfo) {
        CGRect keyboardSize = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        // FIX
        // shouldnt be hardcoded
        _kHeight = keyboardSize.size.height/2;

        [self animateTextField:TRUE];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self animateTextField:FALSE];
}

- (void)animateTextField:(BOOL)up {
    NSInteger movement = (up ? -self.kHeight : self.kHeight);

    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
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
    _userMe = userData;
    LoginData *loginData = [[LoginData alloc] initWithUserData:userData];
    
    _socket = [[SocketIOClient alloc] initWithSocketURL:port options:nil];
    
    [_socket on:@"connect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"Socket connected");
        
        [_socket emit:@"authentication" withItems:@[loginData.data]];
    }];
    
    [_socket on:@"authenticated" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        [_socket emit:@"add user" withItems:@[@{@"room":loginData.room, @"roomHash":loginData.roomHash, @"socket": [_socket sid]}]];
    }];
    
    [_socket connect];
}

- (NSInteger)generateRandomFrom:(NSInteger)from to:(NSInteger)to {
    return (NSInteger)(arc4random() % (to-from+1) + from);
}

@end
