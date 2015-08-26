//
//  MessageCollectionViewCell.m
//  test
//
//  Created by Artemy Pestretsov on 7/16/15.
//  Copyright (c) 2015 Artemy Pestretsov. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "UIImage+RoundedCorner.h"

@implementation MessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.timestamp];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"usernameLabel": self.usernameLabel,
                            @"bodyLabel": self.bodyLabel,
                            @"timestamp": self.timestamp,
                            };
    
    NSDictionary *metrics = @{@"thumbSize": @(kMessageTableViewCellAvatarHeight),
                              @"padding": @15,
                              @"right": @10,
                              @"left": @5,
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(thumbSize)]-left-[usernameLabel(>=0)]-right-[timestamp(>=0)]-(>=0)-|" options:kNilOptions metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(thumbSize)]-left-[bodyLabel(>=0)]-right-|" options:kNilOptions metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[thumbnailView(thumbSize)]-(>=0)-|" options:kNilOptions metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[usernameLabel]-left-[bodyLabel(>=0)]-left-|" options:kNilOptions metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[timestamp]-left-[bodyLabel(>=0)]-left-|" options:kNilOptions metrics:metrics views:views]];
}

// only change attributes here..dont touch content
- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    self.usernameLabel.textColor = [UIColor blackColor];
    self.bodyLabel.font = [UIFont systemFontOfSize:16.0];
    self.bodyLabel.textColor = [UIColor darkGrayColor];
    self.timestamp.font = [UIFont systemFontOfSize:16.0];
    self.timestamp.textColor = [UIColor lightGrayColor];
}

- (UILabel *)usernameLabel {
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.userInteractionEnabled = NO;
        _usernameLabel.numberOfLines = 1;
        
        _usernameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _usernameLabel.textColor = [UIColor blackColor];
    }
    
    return _usernameLabel;
}

- (UILabel *)bodyLabel {
    if (!_bodyLabel) {
        _bodyLabel = [[UILabel alloc] init];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.backgroundColor = [UIColor clearColor];
        _bodyLabel.userInteractionEnabled = NO;
        _bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyLabel.font = [UIFont systemFontOfSize:16.0];
        _bodyLabel.textColor = [UIColor darkGrayColor];
    }
    
    return _bodyLabel;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [UIImageView new];
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.userInteractionEnabled = NO;
        _thumbnailView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }

    
    return _thumbnailView;
}

- (UILabel *)timestamp {
    if (!_timestamp) {
        _timestamp = [[UILabel alloc] init];
        _timestamp.translatesAutoresizingMaskIntoConstraints = NO;
        _timestamp.backgroundColor = [UIColor clearColor];
        _timestamp.userInteractionEnabled = NO;
        _timestamp.numberOfLines = 1;
        _timestamp.font = [UIFont systemFontOfSize:16.0];
        _timestamp.textColor = [UIColor lightGrayColor];
    }
    
    return _timestamp;
}



@end
