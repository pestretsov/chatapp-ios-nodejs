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
    _dict = dictionary;
    
    _isHistory = [dictionary objectForKey:@"history"];
    _messageId = [dictionary objectForKey:@"id"];
    _user = [[UserData alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
    _message = [dictionary objectForKey:@"message"];

    NSString * tempTimestamp = [dictionary objectForKey:@"timestamp"];
    
    NSTimeInterval timeInterval = [tempTimestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    _timestamp = [dateFormatter stringFromDate:date];
    
    _mentions = [dictionary objectForKey:@"mentions"]; // array of dictionaries
    
    return self;
}

@end
