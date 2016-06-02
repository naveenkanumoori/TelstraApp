//
//  UsersTableViewCell.m
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "UsersTableViewCell.h"

@implementation UsersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
     [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.backView.layer setCornerRadius:7.0f];
    [self.backView.layer setMasksToBounds:YES];
    [self.backView.layer setBorderWidth:0.5f];
    [self.backView.layer setBorderColor:[UIColor whiteColor].CGColor];
 self.selectionStyle=UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
