//
//  AISocketChatDatasources.h
//  Playground
//
//  Created by An Nguyen on 1/11/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Socket.IO";

@interface AISocketChatDatasources : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

+ (NSString *) randomStringWithLength: (int) len;
@end
