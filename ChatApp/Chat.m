//
//  Chat.m
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "Chat.h"

@implementation Chat

static NSString * port = @"localhost:3000";

NSString * const ClientDidReceiveNewMessageNotification = @"ClientDidReceiveNewMessageNotification";
NSString * const ClientDidReceiveBanNotification = @"ClientDidReceiveBanNotification";
NSString * const ClientDidReceiveUserJoinedNotification = @"ClientDidReceiveUserJoinedNotification";
NSString * const ClientDidReceiveUserLeftNotification = @"ClientDidReceiveUserLeftNotification";
NSString * const ClientDidReceiveAccessDeniedNotification = @"ClientDidReceiveAccessDeniedNotification";

+ (id)sharedClient {
    static dispatch_once_t oncePredicate;
    static Chat * sharedClient = nil;
    dispatch_once(&oncePredicate, ^{
        sharedClient = [[self alloc] init];
        sharedClient.socket = [[SocketIOClient alloc] initWithSocketURL:port options:nil];
    });
    
    return sharedClient;
}

- (void)sendMessage:(Message *)message {
    Chat *client = [Chat sharedClient];
    
    NSArray *newMessage = [NSArray arrayWithObject:@{@"text":message.message,
                                                     @"replyId":message.messageId}];
    
    [client.socket emit:@"new message" withItems:newMessage];
}

- (void)authenticateWithLoginData:(LoginData *)loginData {
    Chat *client = [Chat sharedClient];
    
    // Socket events
    
    [client.socket on:@"connect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"connect");
        
        [client.socket emit:@"authentication" withItems:@[loginData.data]];
    }];
    
    
    [client.socket on:@"reconnect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"reconnect");
        
        NSArray *newUserInfo = [NSArray arrayWithObject:@{@"room": loginData.room,
                                                          @"roomHash": loginData.roomHash,
                                                          @"socket": [client.socket sid]
                                                          }];
        
        [client.socket emit:@"add user" withItems:newUserInfo];
    }];
    
    [client.socket on:@"connect_error" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"connect_error");
//        changeStatus(-1);
    }];
    
    [client.socket on:@"disconnect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"disconnect");
//        connected = false;
//        changeStatus(-1);
//        
//        socket.removeAllListeners('authenticated');
//        socket.removeAllListeners('connect_error');

    }];
    
    [client.socket on:@"authenticated" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"authenticated");
        
        NSArray *newUserInfo = [NSArray arrayWithObject:@{@"room": loginData.room,
                                                          @"roomHash": loginData.roomHash,
                                                          @"socket": [client.socket sid]
                                                          }];
        
        
        [client.socket emit:@"add user" withItems:newUserInfo];
    
        [client registerSocketEvents:client.socket];
    }];
    
    [client.socket on:@"auth failed" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"auth failed");
        _connectionStatus = StatusOFFLINE;
        // alert('Access denied');
    }];

    
    [client.socket connect];
}

- (void)registerSocketEvents:(SocketIOClient *)socket {
    [socket on:@"login" callback:^(NSArray* data, void (^ack)(NSArray*)) {
//        connected = true;
        _connectionStatus = StatusCONNECTED;
//        changeStatus(1);
//
//        updateOnlineList(data);
    }];
  
    // message
    
    [socket on:@"new message" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        
        if ([data[0] isKindOfClass:[NSDictionary class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidReceiveNewMessageNotification object:self userInfo:data[0]];
        }
        // POST NOTIFICATION HERE
        
        
//        if (!data.history && !document.hasFocus()) {
//            if (data.message.indexOf('[id' + userData.id) >= 0) {
//                var parsedMessage = parseMentions(data, true);
//                sendNotification('Вас упомянули в чате TJ', data.user.username + ': ' + parsedMessage, data.user.image);
//            } else if (data.mentions.length > 0) {
//                data.mentions.forEach(function(mention) {
//                    if (mention.id == userData.id) {
//                        sendNotification('Вас упомянули в чате TJ', data.user.username + ': ' + data.message, data.user.image);
//                        return;
//                    }
//                });
//            }
//        }
    }];
    
    [socket on:@"user joined" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        // POST NOTIFICATION HERE
        [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidReceiveUserJoinedNotification object:self userInfo:data[0]];
//        updateOnlineList(data, 'add');
    }];
    
    [socket on:@"user left" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        // POST NOTIFICATION HERE
        [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidReceiveUserLeftNotification object:self userInfo:data[0]];
//        updateOnlineList(data, 'remove');
//        removeChatTyping(data);
    }];

    [socket on:@"banned" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        // POST NOTIFICATION HERE
        [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidReceiveBanNotification object:self userInfo:data[0]];
    }];

    // slash command response
    [socket on:@"command response" callback:^(NSArray* data, void (^ack)(NSArray*)) {
//        addCommandResponse(data);
    }];
    
    
    [socket on:@"reconnecting" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        _connectionStatus = StatusCONNECTING;
    }];
    
    [socket on:@"reconnect_failed" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        _connectionStatus = StatusOFFLINE;
    }];
    
    [socket on:@"reconnect_error" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        _connectionStatus = StatusOFFLINE;
    }];
    
    // NOT SUPPORTED YET
    
    // typing
    /*socket.on('typing', function(data) {
     addChatTyping(data);
     });
     
     socket.on('stop typing', function(data) {
     removeChatTyping(data);
     });*/
}

@end
