//
//  AISocketChatData.h
//  Playground
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AISocketData.h"
#define AISocketDataMessageKey      @"message"
#define AISocketDataSenderNameKey   @"senderName"

@interface AISocketChatData :AISocketData
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* senderName;
- (void)setMessage:(NSString *)message senderName:(NSString*)senderName;
//+ (AISocketChatData*)createFromDictionary:(NSDictionary*)dic;
@end
