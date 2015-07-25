//
//  Chat.m
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "Chat.h"

@implementation Chat

- (id)initWithSocket:(SocketIOClient *)socket {
    
    [socket on:@"new message" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        if (data[0] && [data[0] isKindOfClass:[NSDictionary class]]) {
            Message *message = [[Message alloc] initWithDictionary:data[0]];
            
            [_delegate didReceiveMessage:message];
        } else {
            NSLog(@"I KNEW YOU WERE TROUBLE");
        }
        
    }];
    
    return self;
}

- (void)sendMessage:(SocketIOClient *)socket message:(Message *)message {
    [socket emit:@"new message" withItems:@[@{@"text":message.message, @"replyId":@0}]];
}

@end
