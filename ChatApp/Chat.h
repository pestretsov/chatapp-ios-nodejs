//
//  Chat.h
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>
#import "Message.h"

@class Chat;

@protocol ChatDelegate <NSObject>

- (void)didReceiveMessage:(Message *)message;
- (void)updateUserList:(UserData *)userData action:(NSString *)action;
// FIX
// create event class (dont use string)
- (void)didReceiveEvent:(NSString *)event;

@optional

@end

@interface Chat : NSObject

@property (nonatomic, weak) id <ChatDelegate> delegate;

- (id)initWithSocket:(SocketIOClient *)socket;
- (void)sendMessage:(SocketIOClient *)socket message:(Message *)message;
- (NSString *)parseMentions:(Message *)message;

@end
