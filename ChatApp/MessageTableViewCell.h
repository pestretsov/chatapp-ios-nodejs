//
//  MessageCollectionViewCell.h
//  test
//
//  Created by Artemy Pestretsov on 7/16/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kMessageTableViewCellMinimumHeight = 50.0;
static CGFloat kMessageTableViewCellAvatarHeight = 30.0;

// переделать на CollectionView
@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UILabel *timestamp;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
