//
//  ChatViewController.m
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "ChatViewController.h"
#import "MyMessagesTableViewCell.h"
#import "OtherMessagesTableViewCell.h"
#import "AppDelegate.h"

@interface ChatViewController (){
    int _msglength;
}

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _messages = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = false;
        [ self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-blue-wallpaper.png"]]];
    [self.clientTable setBackgroundColor:[UIColor clearColor]];

    [_clientTable registerNib:[UINib nibWithNibName:@"OtherMessagesTableViewCell" bundle:nil] forCellReuseIdentifier:@"otherCell"];
    [_clientTable registerNib:[UINib nibWithNibName:@"MyMessagesTableViewCell" bundle:nil] forCellReuseIdentifier:@"myCell"];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.title = [self.userData valueForKey:@"userName"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"ReloadTable"
                                               object:nil];
    _messageField.borderStyle=UITextBorderStyleRoundedRect;
    
    //changing Badge
    [self updateUnreadMesaages];
}

-(void)updateUnreadMesaages{
    NSArray *unreadMessages = [[NSUserDefaults standardUserDefaults] valueForKey:@"unreadMessages"];
    int count = 0;
    NSMutableArray *newUnreadMessage = [[NSMutableArray alloc] init];
    if (unreadMessages) {
        for (NSDictionary *message in unreadMessages) {
            if ([[message objectForKey:@"from"] isEqualToString:[_userData objectForKey:@"emailID"]]) {
                count++;
            }else{
                [newUnreadMessage addObject:message];
            }
        }
    }
    if (newUnreadMessage.count == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"unreadMessages"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:newUnreadMessage forKey:@"unreadMessages"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeBadge" object:newUnreadMessage];
}

- (void) reloadTable:(NSNotification *) notification{
    [_clientTable reloadData];
    int lastRow=(int)[_clientTable numberOfRowsInSection:0]-1;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [_clientTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self updateUnreadMesaages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)keyboardWillAppear:(NSNotification *)notification{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    [self.textFieldBottomConstraint setConstant:keyboardRect.size.height+8-49];
    [self.buttonBottomConstraint setConstant:keyboardRect.size.height+8-49];
}

-(void)keyboardWillDisappear{
    [self.textFieldBottomConstraint setConstant:8];
    [self.buttonBottomConstraint setConstant:8];
}

- (IBAction)sendMessage:(id)sender {
    [self sendMessageToServer:@{@"text": self.messageField.text}];
    self.messageField.text = @"";
}

- (void)sendMessageToServer:(NSDictionary *)data {
    NSString *to = [[[self.userData valueForKey:@"emailID"] componentsSeparatedByString:@"@"] firstObject];
    NSMutableDictionary *dict = [data mutableCopy];
    [dict setObject:[self.userData valueForKey:@"emailID"] forKey:@"to"];
    [dict setObject:[[FIRAuth auth] currentUser].email forKey:@"from"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    [dict setObject:stringFromDate forKey:@"time"];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate sendMessageToServer:dict toUser:to];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getNoOfRows];
}

-(NSInteger)getNoOfRows{
    int i = 0;
    NSMutableArray *storedMessages= [[NSMutableArray alloc]initWithArray: [[NSUserDefaults standardUserDefaults] valueForKey:@"storedMessages"]];
    for (NSDictionary *x in storedMessages){
        if ([[x valueForKey:@"from"] isEqualToString:[[FIRAuth auth] currentUser].email] && [[x valueForKey:@"to"] isEqualToString:[_userData valueForKey:@"emailID"]]) {
            i++;
            if (![_messages containsObject:x]) {
                [_messages addObject:x];
            }
        }else if([[x valueForKey:@"from"] isEqualToString:[_userData valueForKey:@"emailID"]]){
            i++;
            if (![_messages containsObject:x]) {
                [_messages addObject:x];
            }
        }
    }
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *messageData =[_messages objectAtIndex:indexPath.row];
    if ([[messageData valueForKey:@"from"] isEqualToString:[[FIRAuth auth] currentUser].email] && [[messageData valueForKey:@"to"] isEqualToString:[_userData valueForKey:@"emailID"]]) {
        MyMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        cell.message.text =[NSString stringWithFormat:@"  %@", [messageData valueForKey:@"text"]];
        cell.message.lineBreakMode = NSLineBreakByWordWrapping;
        cell.message.numberOfLines = 0;
        
        //width
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]};
        CGRect rect = [cell.message.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width-300, CGFLOAT_MAX)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading)
                                                   attributes:attributes context:nil];
        if (cell.frame.size.width - rect.size.width - 30>500) {
            cell.leadingConstraint.constant = 500;
        }else{
            cell.leadingConstraint.constant = cell.frame.size.width - rect.size.width - 30;
        }
        cell.message.layer.cornerRadius = 10;
        cell.message.clipsToBounds = YES;
        return cell;
    }else{
        OtherMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
        cell.message.text =[NSString stringWithFormat:@"  %@", [messageData valueForKey:@"text"]];
        cell.message.lineBreakMode = NSLineBreakByWordWrapping;
        cell.message.numberOfLines = 0;
        //width
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]};
        CGRect rect = [cell.message.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width-300, CGFLOAT_MAX)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading)
                                                   attributes:attributes context:nil];
        if (cell.frame.size.width - rect.size.width - 30>500) {
            cell.leadingConstraint.constant = 500;
        }else{
            cell.leadingConstraint.constant = cell.frame.size.width - rect.size.width - 30;
        }
        cell.message.layer.cornerRadius = 10;
        cell.message.clipsToBounds = YES;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *messageData =[_messages objectAtIndex:indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]};
    float heightOfCell = UITableViewAutomaticDimension;
    
    if ([[messageData valueForKey:@"from"] isEqualToString:[[FIRAuth auth] currentUser].email] && [[messageData valueForKey:@"to"] isEqualToString:[_userData valueForKey:@"emailID"]]) {
        
        NSString *tweetString = [messageData valueForKey:@"text"];
        CGRect rect = [tweetString boundingRectWithSize:CGSizeMake(244, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading)
                                             attributes:attributes context:nil];
        float tweetHeight = rect.size.height;
        if (tweetHeight<55) {
            tweetHeight =55;
        }
        heightOfCell = tweetHeight;
        if (heightOfCell > 0) {
            return heightOfCell;
        }
        
    }else{
        
        NSString *tweetString = [messageData valueForKey:@"text"];
        CGRect rect = [tweetString boundingRectWithSize:CGSizeMake(244, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading)
                                             attributes:attributes context:nil];
        float tweetHeight = rect.size.height;
        if (tweetHeight<55) {
            tweetHeight =55;
        }
        heightOfCell = tweetHeight;
        if (heightOfCell > 0) {
            return heightOfCell;
        }
        
    }
    
    return 49.0;
}

@end
