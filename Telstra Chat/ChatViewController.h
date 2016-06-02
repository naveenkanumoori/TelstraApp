//
//  ChatViewController.h
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;
@property NSDictionary *userData;

@property (weak, nonatomic) IBOutlet UITextField *messageField;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *clientTable;

@end
