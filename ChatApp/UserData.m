//
//  UserData.m
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "UserData.h"

@implementation UserData

- (id)initWithDictionary:(NSDictionary *)dictionary {
 
    _userId = [dictionary objectForKey:@"id"];
    _thumbnailUrl = [NSURL URLWithString:[dictionary objectForKey:@"image"]];
    _username = [dictionary objectForKey:@"username"];
    _name = [dictionary objectForKey:@"name"];
    
    _data = [[NSDictionary alloc] initWithObjects:@[_userId, _name, [dictionary objectForKey:@"image"], _username] forKeys:@[@"id", @"name", @"image", @"username"]];
    
    return self;
}

@end
