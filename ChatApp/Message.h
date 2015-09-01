//
//  Message.h
//  test
//
//  Created by Artemy Pestretsov on 7/16/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

@interface Message : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) UserData *user;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSArray *mentions;
@property BOOL isHistory;

@property (nonatomic, strong) NSDictionary *dict;

@end
