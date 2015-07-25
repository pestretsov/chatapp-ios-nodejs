//
//  LoginData.h
//  test
//
//  Created by Artemy Pestretsov on 7/18/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"
#import "NSString+MD5.h"

@interface LoginData : NSObject

@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSString *userHash;
@property (nonatomic, strong) NSString *room;
@property (nonatomic, strong) NSString *roomHash;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *data;

-(id)initWithUserData:(UserData *)userData;

@end
