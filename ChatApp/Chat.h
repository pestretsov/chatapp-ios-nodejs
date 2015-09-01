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
#import "LoginData.h"

@class Chat;

//@protocol ChatDelegate <NSObject>
//
//- (void)didReceiveMessage:(Message *)message;
//- (void)updateUserList:(UserData *)userData action:(NSString *)action;
//// FIX
//// create event class (dont use string)
//- (void)didReceiveEvent:(NSString *)event;
//
//@optional
//
//@end

@interface Chat : NSObject

typedef NS_ENUM(NSInteger, ConnectionStatus) {
    StatusOFFLINE = -1,
    StatusCONNECTING = 0,
    StatusCONNECTED = 1
};

extern NSString * const ClientDidReceiveNewMessageNotification;
extern NSString * const ClientDidReceiveBanNotification;
extern NSString * const ClientDidReceiveUserJoinedNotification;
extern NSString * const ClientDidReceiveUserLeftNotification;
extern NSString * const ClientDidReceiveAccessDeniedNotification;

//@property (nonatomic, weak) id <ChatDelegate> delegate;
@property (nonatomic, strong) SocketIOClient *socket;
@property (getter=getConnectionStatus) ConnectionStatus connectionStatus;

+ (id)sharedClient;
- (void)sendMessage:(Message *)message;
- (void)authenticateWithLoginData:(LoginData *)loginData;

@end
