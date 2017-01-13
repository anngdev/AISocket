//
//  AIViewController.h
//  AISocket
//
//  Created by An Nguyen on 01/12/2017.
//  Copyright (c) 2017 An Nguyen. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "AISocketChatDatasources.h"

@import UIKit;
@import AISocket;

@interface AIViewController : JSQMessagesViewController<JSQMessagesComposerTextViewPasteDelegate, AISocketManagerObserver>
@property (strong, nonatomic) AISocketChatDatasources *datasources;

@end
