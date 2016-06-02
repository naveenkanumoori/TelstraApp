//
//  MyMessagesTableViewCell.h
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessagesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@end
