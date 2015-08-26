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
        if ([data[0] isKindOfClass:[NSDictionary class]]) {
            Message *message = [[Message alloc] initWithDictionary:data[0]];
            [_delegate didReceiveMessage:message];
        } else {
            // Once upon a time a few mistakes ago
            NSLog(@"CAUSE I KNEW YOU WERE TROUBLE");
        }
    }];
    
    [socket on:@"user joined" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        if ([data[0] isKindOfClass:[NSDictionary class]]) {
            UserData *newUser = [[UserData alloc] initWithDictionary:[data[0] objectForKey:@"user"]];
            [_delegate updateUserList:newUser action:@"add"];
        } else {
            // I was in your sights, you got me alone
            NSLog(@"CAUSE I KNEW YOU WERE TROUBLE");
        }
    }];
    
    [socket on:@"user left"  callback:^(NSArray *data, void (^ack)(NSArray *)) {
        if ([data[0] isKindOfClass:[NSDictionary class]]) {
            UserData *removeUser = [[UserData alloc] initWithDictionary:[data[0] objectForKey:@"user"]];
            [_delegate updateUserList:removeUser action:@"remove"];
        } else {
            // You found me, you found me, you found me
            NSLog(@"CAUSE I KNEW YOU WERE TROUBLE");
        }
    }];

    [socket on:@"banned" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        if ([data[0] isKindOfClass:[NSDictionary class]]) {
            [_delegate didReceiveEvent:@"banned"];
        } else {
            // I guess you didn't care, and I guess I liked that
            NSLog(@"CAUSE I KNEW YOU WERE TROUBLE");
        }
    }];

    return self;
}

- (void)sendMessage:(SocketIOClient *)socket message:(Message *)message {
    [socket emit:@"new message" withItems:@[@{@"text":message.message, @"replyId":message.messageId}]];
}

- (NSString *)parseMentions:(Message *)message {
    if (message.mentions.count > 0) {
        NSMutableArray *mentions = [NSMutableArray arrayWithArray:message.mentions];
        // FIX
        // shouldnt be hardcoded (only one mention)
        NSString *mentionString = [NSString stringWithFormat:@"%@", [mentions[0] objectForKey:@"name"]];

        return mentionString;
    } else {
        return nil;
    }
}


@end
