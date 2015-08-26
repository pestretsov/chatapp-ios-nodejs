//
//  LoginData.m
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "LoginData.h"

@implementation LoginData

static NSString *salt = @"salt";
static NSString *roomName = @"general";

- (id)initWithUserData:(UserData *)userData {
    
    _user = [[NSDictionary alloc] initWithDictionary:userData.data copyItems:YES];
    _room = roomName;
    _roomHash = [[_room stringByAppendingString:salt] MD5];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_user options:kNilOptions error:&error];
    
    _userHash = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _userHash = [_userHash stringByAppendingString:salt];
    
    // fixes escape slash problem
    _userHash = [_userHash stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    _userHash = [_userHash MD5];
    
    _username = [_user objectForKey:@"username"];
    
    _data = [[NSDictionary alloc] initWithObjects:@[_user, _userHash, _username] forKeys:@[@"user", @"hash", @"username"]];
    
    return self;
}

@end
