//
//  AIViewController.m
//  AISocket
//
//  Created by An Nguyen on 01/12/2017.
//  Copyright (c) 2017 An Nguyen. All rights reserved.
//

#import "AIViewController.h"
#import "AISocketChatData.h"


@interface AIViewController ()

@end

@implementation AIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initJSQMessenger];
    [self initSocket];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[AISocketManager sharedInstance] removeObserver:self onEvent:kAISocketManagerEventAll];
}


#pragma mark - Init Socket
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initSocket{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    [[AISocketManager sharedInstance] connectHost:@"http://192.168.1.10:5000" delegate:self];
    [[AISocketManager sharedInstance] listenOnEvent:[AISocketChatData eventName] dataCallback:^AISocketData *(id datas) {
        AISocketChatData *obj = [[AISocketChatData alloc]initWithString:datas error:nil];
        return obj;
    }];
    [[AISocketManager sharedInstance] addObserver:self onEvent:[AISocketChatData eventName]];
}

#pragma mark - AISocket Observer
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dlgAISocketManager:(AISocketManager*)manager withData:(AISocketData*)data{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    if ([data isKindOfClass:[AISocketChatData class]]) {
        AISocketChatData *obj = (AISocketChatData*)data;
        if ([obj.senderID isEqualToString: self.senderId]) {
            return;
        }
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:obj.senderID
                                                 senderDisplayName:obj.senderName
                                                              date:[NSDate distantPast]
                                                              text:obj.message];
        [self.datasources.messages addObject:message];
        [self finishReceivingMessage];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dlgAISocketManager:(AISocketManager*)manager status:(AISocketManagerStatus)status{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"System"
                                             senderDisplayName:@"System"
                                                          date:[NSDate distantPast]
                                                          text:[AISocketManager statusNameFromCode:status]];
    [self.datasources.messages addObject:message];
    [self finishReceivingMessage];
}


#pragma mark - UI

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)initJSQMessenger{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    self.datasources = [[AISocketChatDatasources alloc]init];
    self.senderId = [AISocketChatDatasources randomStringWithLength:4];;
    self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires;
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.showLoadEarlierMessagesHeader = YES;
}
#pragma mark - JSQMessagesViewController method overrides
//
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    AISocketChatData *obj = [[AISocketChatData alloc]init];
    [obj setSenderID:senderId receiverID:@"000x0"];
    [obj setMessage:text senderName:senderDisplayName];
    [[AISocketManager sharedInstance] emitData:obj];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:obj.senderID
                                             senderDisplayName:obj.senderName
                                                          date:[NSDate distantPast]
                                                          text:obj.message];
    [self.datasources.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
    
}
#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.datasources.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.datasources.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.datasources.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.datasources.outgoingBubbleImageData;
    }
    
    return self.datasources.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.datasources.messages objectAtIndex:indexPath.item];
    return nil;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.datasources.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.datasources.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.datasources.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.datasources.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    

    JSQMessage *msg = [self.datasources.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.datasources.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.datasources.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.datasources.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

@end
