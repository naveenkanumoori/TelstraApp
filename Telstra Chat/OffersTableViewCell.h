//
//  OffersTableViewCell.h
//  IEEP
//
//  Created by admin on 3/10/16.
//  Copyright © 2016 com.infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OffersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *offersImage;
@property (weak, nonatomic) IBOutlet UILabel *offersTitle;
@property (weak, nonatomic) IBOutlet UILabel *expiresOn;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *offersvIEW;

@end
