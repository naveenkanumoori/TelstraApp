//
//  FeedBackViewController.h
//  Telstra Chat
//
//  Created by admin on 5/30/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedBackViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *veryGoodButton;
- (IBAction)veryGoodButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
- (IBAction)goodButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *notGoodButton;
- (IBAction)notGoodButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitButtonBottomConstraint;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxTop2;

@end
