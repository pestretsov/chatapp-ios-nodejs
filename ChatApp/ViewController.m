//
//  ViewController.m
//  test
//
//  Created by Artemy Pestretsov on 7/13/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "ViewController.h"
#import "NSString+MD5.h"
#import "UserData.h"
#import "Chat.h"
#import "LoginData.h"
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

@interface ViewController () <ChatDelegate>

@property (weak, nonatomic) IBOutlet UITextField *MessageField;
@property (weak, nonatomic) IBOutlet UITableView *MessagesList;
@property (strong, nonatomic) Chat *chat;

- (IBAction)SendButton:(id)sender;


@property (strong, nonatomic) SocketIOClient *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startHandshake];
}

- (void)startHandshake {
    
    UserData *userData = [[UserData alloc] initWithUserId:@"1488" name:@"User" image:@"https://static39.cmtt.ru/paper-preview-fox/m/us/musk-longread-1/1bce7f668558-normal.jpg"];
    LoginData *loginData = [[LoginData alloc] initWithUserData:userData];
    
    _socket = [[SocketIOClient alloc] initWithSocketURL:@"localhost:3000" options:nil];
    
    [_socket on:@"connect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"Socket connected");
        
        [_socket emit:@"authentication" withItems:@[loginData.data]];
    }];
    
    [_socket on:@"authenticated" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        NSLog(@"%@ authenticated!", loginData.username);
        [_socket emit:@"add user" withItems:@[@{@"room":loginData.room, @"roomHash":loginData.roomHash, @"socket": [_socket sid]}]];
    }];
    
    _chat = [[Chat alloc] initWithSocket:_socket];
    _chat.delegate = self;
    [_socket connect];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SendButton:(id)sender {
    NSString *message = _MessageField.text;
    [_chat sendMessage:_socket message:message];
    [_MessageField setText:@""];
}

#pragma mark - <ChatDelegate>

-(void)didReceiveMessage:(Message *)message {
    NSLog(message.message);
}

@end
