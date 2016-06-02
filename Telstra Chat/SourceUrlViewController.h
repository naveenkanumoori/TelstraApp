//
//  SourceUrlViewController.h
//  WelcomeToInfosys
//
//  Created by admin on 5/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SourceUrlViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
- (IBAction)onClickingClose:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *objectFromParent;

@end
