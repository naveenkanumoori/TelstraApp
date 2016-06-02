//
//  UsersTableViewCell.h
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessages;

@end
