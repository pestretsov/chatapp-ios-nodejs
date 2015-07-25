//
//  UserData.m
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "UserData.h"

@implementation UserData

- (id)initWithUserId:(NSString *)userId name:(NSString *)name image:(NSString *)image {
    
    _data = [[NSDictionary alloc] initWithObjects:@[userId, name, image] forKeys:@[@"id", @"name", @"image"]];
    
    return self;
}
@end
