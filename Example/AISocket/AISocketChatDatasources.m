//
//  AISocketChatDatasources.m
//  Playground
//
//  Created by An Nguyen on 1/11/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AISocketChatDatasources.h"
#import "AISocketChatData.h"
#import "JSQMessageRealm.h"

//#define RealmDBVersion 1

typedef enum : NSUInteger {
    RealmDBVersion0Init = 0,
    RealmDBVersion1AddUser = 1,
} RealmDBVersion;


@interface AISocketChatDatasources()
@property (assign, nonatomic) NSInteger lastCount;
@property (weak, nonatomic)   RLMRealm *realm;
@end

@implementation AISocketChatDatasources

static AISocketChatDatasources * _AISocketChatDatasources = nil;

+ (AISocketChatDatasources*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AISocketChatDatasources = [[AISocketChatDatasources alloc]init];
    });
    return _AISocketChatDatasources;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.schemaVersion = RealmDBVersion1AddUser;
        NSLog(@"Schema version %llu", config.schemaVersion);
        config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < RealmDBVersion1AddUser) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        };
        [RLMRealmConfiguration setDefaultConfiguration:config];
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        self.realm = [RLMRealm defaultRealm];
        self.chats = [ChatObject allObjects];
        self.lastCount = [self.chats count];
        
        self.messages = [NSMutableArray new];
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        UIImage *tImage = [UIImage imageNamed:@"avatar.png"];
        self.outImage = [[JSQMessagesAvatarImage alloc]initWithAvatarImage:tImage highlightedImage:tImage placeholderImage:tImage];
        tImage = [UIImage imageNamed:@"avatar2.png"];
        self.inImage = [[JSQMessagesAvatarImage alloc]initWithAvatarImage:tImage highlightedImage:tImage placeholderImage:tImage];
        tImage = [UIImage imageNamed:@"system.png.png"];
        self.sysImage = [[JSQMessagesAvatarImage alloc]initWithAvatarImage:tImage highlightedImage:tImage placeholderImage:tImage];
        self.users = [[UserObject allObjects] firstObject];
        if (self.users==nil) {
            self.users             = [[UserObject alloc]init];
            self.users.userName    = [AISocketData randomStringWithLength:10];
            self.users.userID      = [AISocketData randomStringWithLength:4];
            // You only need to do this once (per thread)
            // Add to Realm with transaction
            [self.realm beginWriteTransaction];
            [self.realm addObject:self.users];
            [self.realm commitWriteTransaction];
        }
    }
    
    return self;
}

- (void)reloadPrevious{
    for (int i = 0; i <2; i++) {
        self.lastCount--;
        if (self.lastCount < self.chats.count && self.lastCount>=0) {
            ChatObject *obj = self.chats[self.lastCount];
            [self.messages insertObject:[JSQMessage createFromChatObject:obj] atIndex:0];
            NSLog(@"User %@",obj.user.userName);
        }
    }
}

- (void)deleteMessage:(JSQMessage*)msg{
    ChatObject * obj = [[ChatObject objectsWhere:@"key = %@",msg.msgKey] firstObject];
    [self.messages removeObject:msg];
    NSLog(@"Count before %lu", (unsigned long)self.chats.count);
    if (obj) {
        
        [self.realm beginWriteTransaction];
        [self.realm deleteObject:obj];
        [self.realm commitWriteTransaction];
        NSLog(@"Count after %lu", (unsigned long)self.chats.count);
    }
    
}
@end
