//
//  ChatController.m
//  test
//
//  Created by Artemy Pestretsov on 7/21/15.
//  Copyright © 2015 Artemy Pestretsov. All rights reserved.
//

#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <JSQMessagesViewController/JSQMessages.h>

#import "ChatController.h"
#import "AuthController.h"
#import "MessageTextView.h"
#import "MessageTableViewCell.h"
#import "Message.h"
#import "Chat.h"
#import "NSString+MD5.h"
#import "UserData.h"
#import "LoginData.h"

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";
static NSInteger countParticipants = 0;

@interface ChatController ()

@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *lastMentionedId;
@property (strong, nonatomic) NSMutableArray *onlineUsers;
@property (nonatomic, strong) NSArray *searchResult;

@end

@implementation ChatController

- (id)init {
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    // SLKTextView needs this
    [self registerClassForTextView:[MessageTextView class]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messages = [[NSMutableArray alloc] init];
    self.onlineUsers = [[NSMutableArray alloc] init];
    
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.tableView addGestureRecognizer:tap];
    
//    self.chat = [[Chat alloc] initWithSocket:self.socket];
 //   self.chat.delegate = self;
    self.lastMentionedId = @"0";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(banned:) name:ClientDidReceiveBanNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:ClientDidReceiveNewMessageNotification object:nil];
    
//    [self continueHandshake];
    
    // FIX
    // not implemented yet
    self.navigationItem.title = [NSString stringWithFormat:@"%ld online", countParticipants];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:nil];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];

    [self.autoCompletionView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    
    // enter @ in textfield to show additional menu
    [self registerPrefixesForAutoCompletion:@[@"@"]];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - SLKTextView overriden Methods

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status {
}

- (void)textWillUpdate {
    [super textWillUpdate];
}

- (void)banned:(NSNotification *) notification {
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Banned"
                                                       message:@"You have been banned for %@ seconds"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}

- (void)textDidUpdate:(BOOL)animated {
    [super textDidUpdate:animated];
}

- (void)willRequestUndo {
    [super willRequestUndo];
}

- (void)didCancelTextEditing:(id)sender {
    [super didCancelTextEditing:sender];
}

- (void)dismissKeyboard:(BOOL)animated {
    [self.textView resignFirstResponder];
}

- (void)didPressRightButton:(id)sender {
    [self.textView refreshFirstResponder];
    
    Message *message = [[Message alloc] init];
    
    message.message = [self.textView.text copy];
    // not messageId, but replyId
    message.messageId = _lastMentionedId;
    
    [[Chat sharedClient] sendMessage:message];
    
    self.lastMentionedId = @"0";
    [super didPressRightButton:sender];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        return self.messages.count;
    }
    else {
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    }
    else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    
    Message *message = self.messages[indexPath.row];
    
    //NSString *mentionString = [self.chat parseMentions:message];
    
    cell.usernameLabel.text = message.user.username;
    cell.bodyLabel.text = message.message;
    cell.timestamp.text = message.timestamp;
    
//    if ([mentionString length]) {
//        NSDictionary *attrs = @{
//                                NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0],
//                                NSForegroundColorAttributeName:[UIColor colorWithRed:0.36 green:0.58 blue:0.76 alpha:1.0]
//                                };
//        NSDictionary *subAttrs = @{
//                                   NSFontAttributeName:[UIFont systemFontOfSize:16.0]
//                                   };
//        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:cell.bodyLabel.text                                       attributes:subAttrs];
//
//        NSRange range = NSMakeRange(0, [mentionString length]);
//        [attributedText setAttributes:attrs range:range];
//        
//        [cell.bodyLabel setAttributedText:attributedText];
//    }
    
    // FIX
    // provide a way to upload custom image
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:@"https://static39.cmtt.ru/paper-preview-fox/m/us/musk-longread-1/1bce7f668558-normal.jpg"]
                          placeholderImage:nil
                                 completed:nil];
    
    [cell.thumbnailView setImage:[cell
                                  .thumbnailView.image roundedCornerImage:cell.thumbnailView.image.size.height/2.0 borderSize:0.0]];
    
    if ([cell.usernameLabel.text length]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mentionUser:)];
        longPress.minimumPressDuration = 0.3f;
        [cell addGestureRecognizer:longPress];
    }
    
    cell.indexPath = indexPath;
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.autoCompletionView]) {
        
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        
        // FIX
        // bad idea
        for (UserData *user in self.onlineUsers) {
            if ([item isEqual:user.username]) {
                _lastMentionedId = user.userId;
            }
        }
        
        if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
            [item appendString:@","];
        }
        
        [item appendString:@" "];
        
        [self acceptAutoCompletionWithString:item keepPrefix:NO];
    }
}

// FIX
// magic numbers
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView]) {
        Message *message = self.messages[indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
        width -= 25.0;
        
        CGRect titleBounds = [message.user.username boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (message.message.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 30.0;
        
        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMessageTableViewCellMinimumHeight-10;
    }
}



#pragma mark - ChatDelegate

-(void)didReceiveMessage:(NSNotification *)notification {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = UITableViewRowAnimationBottom;

    NSDictionary *userInfo = [notification userInfo];
    Message *message = [[Message alloc] initWithDictionary:userInfo];
    
    [self.tableView beginUpdates];
    [self.messages insertObject:message atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    
    NSLog(@"HERE");
}

- (void)mentionUser:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    MessageTableViewCell* cell = (MessageTableViewCell*)gestureRecognizer.view;

    // FIX
    // only one user can be mentioned (for now)
    for (UserData *user in self.onlineUsers) {
        if ([cell.usernameLabel.text isEqual:user.username]) {
            _lastMentionedId = user.userId;
        }
    }
    
    NSString *mentionString = [NSString stringWithFormat:@"%@, %@", cell.usernameLabel.text, self.textView.text];
    
    [self.textView setText:mentionString];
    [self.textView becomeFirstResponder];
}

// FIX
// shouldnt be hardcoded
- (void)updateUserList:(UserData *)userData action:(NSString *)action{
    if ([action isEqualToString:@"remove"]) {
        [self.onlineUsers removeObject:userData];
        countParticipants--;
        self.navigationItem.title = [NSString stringWithFormat:@"%ld users online", countParticipants];
        // FIX
        // а тут другая вьюшка=D
    } else {
        [self.onlineUsers addObject:userData];
        countParticipants++;
        self.navigationItem.title = [NSString stringWithFormat:@"%ld users online", countParticipants];
        
        // FIX
        // тут должна создаваться специальная вьюшка)))
    }
}

//- (void)continueHandshake {
//
//    
//    [_socket connect];
//}

#pragma mark - AutoCompletionView Methods

- (CGFloat)heightForAutoCompletionView {
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight * self.searchResult.count;
}

- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    NSString *item = self.searchResult[indexPath.row];
    
    cell.usernameLabel.text = item;
    cell.usernameLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (BOOL)canShowAutoCompletion {
    NSArray *array = nil;
    NSString *prefix = self.foundPrefix;
    NSString *word = self.foundWord;
    
    self.searchResult = nil;
    
    if ([prefix isEqualToString:@"@"]) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        // FIX
        // bad idea
        for (UserData *user in self.onlineUsers) {
            [temp addObject:user.username];
        }
        
        if (word.length > 0) {
            NSPredicate *objPredicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word];
            NSArray  *filteredArray = [temp filteredArrayUsingPredicate:objPredicate];
            array = filteredArray;
        } else {
            array = [[NSArray alloc] initWithArray:temp];
        }
    }
    
    if (array.count > 0) {
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
    
    return self.searchResult.count > 0;
}


#pragma mark - UIScrollViewDelegate Methods

// SLKTextView needs those methods to be overriden
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
}

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
