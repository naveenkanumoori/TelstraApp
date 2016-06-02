//
//  OtherMessagesTableViewCell.m
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "OtherMessagesTableViewCell.h"

@implementation OtherMessagesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
