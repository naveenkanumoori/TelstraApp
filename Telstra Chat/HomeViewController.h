//
//  HomeViewController.h
//  WelcomeToInfosys
//
//  Created by admin on 5/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *homeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
- (IBAction)onClickingOffers:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *offersButton;

@end
