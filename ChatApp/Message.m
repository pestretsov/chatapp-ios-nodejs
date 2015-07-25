//
//  Message.m
//  test
//
//  Created by Artemy Pestretsov on 7/16/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)initWithDictionary:(NSDictionary *)dictionary {
    _messageId = [dictionary objectForKey:@"id"];
    _user = [dictionary objectForKey:@"user"];
    _message = [dictionary objectForKey:@"message"];
    _timestamp = [dictionary objectForKey:@"timestamp"];
    _mentions = [dictionary objectForKey:@"mentions"];
    
    return self;
}

@end
