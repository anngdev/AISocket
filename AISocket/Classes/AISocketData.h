//
//  AISocketData.h
//  AISocket
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JSONModel;

#define AISocketDataSenderIDKey @"senderID"
#define AISocketDataReceiverID @"receiverID"
#define AISocketDataCommandKey @"command"

@interface AISocketData : JSONModel

@property (strong, nonatomic) NSString          *senderID;
@property (strong, nonatomic) NSString          *receiverID;
@property (strong, nonatomic) NSString          *key;
@property (assign, nonatomic) BOOL              isSending;
@property (assign, nonatomic) NSInteger         ackTime;
- (void)setSenderID:(NSString*)senderID receiverID:(NSString*)receiverID;
+ (NSString*)eventName;
+ (NSString*)notificationKey;
+ (NSString *)randomStringWithLength:(int)len;
@end
