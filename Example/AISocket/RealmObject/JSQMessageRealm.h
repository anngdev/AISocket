//
//  JSQMessageRealm.h
//  AISocket
//
//  Created by An Nguyen on 1/17/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "JSQMessage.h"
#import "ChatObject.h"

@interface JSQMessage (RealmChatObject)
+ (JSQMessage*)createFromChatObject:(ChatObject*)obj;
- (void)writeRealm;
- (void)deleteRealm;
@end
