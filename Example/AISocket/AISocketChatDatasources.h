//
//  AISocketChatDatasources.h
//  Playground
//
//  Created by An Nguyen on 1/11/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"
#import "UserObject.h"
#import "ChatObject.h"

//#define AISocketChatDatasourcesUserID @"AISocketChatDatasourcesUserID"

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Socket.IO";

@interface AISocketChatDatasources : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

//@property (strong, nonatomic) NSDictionary *users;
@property (strong, nonatomic) JSQMessagesAvatarImage *sysImage;
@property (strong, nonatomic) JSQMessagesAvatarImage *outImage;
@property (strong, nonatomic) JSQMessagesAvatarImage *inImage;
@property (strong, nonatomic) UserObject *users;
@property (strong, nonatomic) RLMResults<ChatObject *> *chats;
- (void)reloadPrevious;
- (void)deleteMessage:(JSQMessage*)msg;
+ (AISocketChatDatasources*)sharedInstance;
@end
