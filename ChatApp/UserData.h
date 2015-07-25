//
//  UserData.h
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chat.h"

@interface UserData : NSObject

@property (nonatomic, strong) NSDictionary *data;

@property (strong, nonatomic) Chat *chat;
- (id)initWithUserId:(NSString *)userId name:(NSString *)name image:(NSString *)image;

@end
