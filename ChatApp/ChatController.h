//
//  ChatController.h
//  test
//
//  Created by Artemy Pestretsov on 7/21/15.
//  Copyright © 2015 Artemy Pestretsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#include "UserData.h"
#include "UIImage+RoundedCorner.h"
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

@interface ChatController : SLKTextViewController

@property (strong, nonatomic) SocketIOClient *socket;
@property (strong, nonatomic) UserData *userMe;

@end
