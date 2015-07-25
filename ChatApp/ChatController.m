//
//  ChatController.m
//  test
//
//  Created by Artemy Pestretsov on 7/21/15.
//  Copyright © 2015 Artemy Pestretsov. All rights reserved.
//

#import "ChatController.h"
#import "MessageTextView.h"
#import "MessageTableViewCell.h"
#import "Message.h"
#import "Chat.h"
#import "NSString+MD5.h"
#import "UserData.h"
#import "LoginData.h"
#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *MessengerCellIdentifier = @"MessengerCell";

@interface ChatController () <ChatDelegate>

@property (strong, nonatomic) SocketIOClient *socket;
@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) NSMutableArray *messages;

@end


@implementation ChatController

- (id)init {
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    
    NSLog(@"START");
    return self;
}

- (void)commonInit {
    [self registerClassForTextView:[MessageTextView class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
    

    self.messages = [[NSMutableArray alloc] init];
    
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    
    [self startHandshake];
}

- (void)startHandshake {
    UserData *userData = [[UserData alloc] initWithUserId:@"1488" name:@"User" image:@"https://static39.cmtt.ru/paper-preview-fox/m/us/musk-longread-1/1bce7f668558-normal.jpg"];
    LoginData *loginData = [[LoginData alloc] initWithUserData:userData];
    
    _socket = [[SocketIOClient alloc] initWithSocketURL:@"localhost:3000" options:nil];
    
    [_socket on:@"connect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"Socket connected");
        
        [_socket emit:@"authentication" withItems:@[loginData.data]];
    }];
    
    [_socket on:@"authenticated" callback:^(NSArray *data, void (^ack)(NSArray *)) {
        NSLog(@"%@ authenticated!", loginData.username);
        [_socket emit:@"add user" withItems:@[@{@"room":loginData.room, @"roomHash":loginData.roomHash, @"socket": [_socket sid]}]];
    }];
    
    _chat = [[Chat alloc] initWithSocket:_socket];
    _chat.delegate = self;
    [_socket connect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
}

- (void)textWillUpdate
{
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    [super textDidUpdate:animated];
}

- (void)willRequestUndo
{
    [super willRequestUndo];
}

- (void)didCancelTextEditing:(id)sender
{
    [super didCancelTextEditing:sender];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self messageCellForRowAtIndexPath:indexPath];
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    
    Message *message = self.messages[indexPath.row];
    
    cell.usernameLabel.text = @"username";
    cell.bodyLabel.text = message.message;
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:@"https://static39.cmtt.ru/paper-preview-fox/m/us/musk-longread-1/1bce7f668558-normal.jpg"]
                          placeholderImage:nil
                                 completed:nil];
    
    cell.indexPath = indexPath;
    
    cell.transform = self.tableView.transform;
    
//    NSLog(@"%@", message.message);
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        Message *message = self.messages[indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
        width -= 25.0;
        
        CGRect titleBounds = [@"username" boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (message.message.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;
        
        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMessageTableViewCellMinimumHeight;
    }
}

- (void)didPressRightButton:(id)sender {
    [self.textView refreshFirstResponder];
    
    Message *message = [[Message alloc] init];
    
    message.message = [self.textView.text copy];
    message.user = @"artemy";
    message.messageId = @"0123984";
    
    [_chat sendMessage:_socket message:message];
    
    [super didPressRightButton:sender];
}

#pragma mark - ChatDelegate

-(void)didReceiveMessage:(Message *)message {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    
    [self.tableView beginUpdates];
    [self.messages insertObject:message atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
