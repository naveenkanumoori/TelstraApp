//
//  FeedBackViewController.m
//  Telstra Chat
//
//  Created by admin on 5/30/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ipad-blue-wallpaper.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     [ self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    // Do any additional setup after loading the view from its nib.
    [[_veryGoodButton layer] setBorderWidth:2.0f];
    [[_veryGoodButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    [[_goodButton layer] setBorderWidth:2.0f];
    [[_goodButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    [[_notGoodButton layer] setBorderWidth:2.0f];
    [[_notGoodButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[_commentsTextView layer] setBorderWidth:2.0f];
    [[_commentsTextView layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)keyboardWillAppear:(NSNotification *)notification{
    const int moveDistance = 200;
    const float moveDuration = 0.3f;
    
    int movement =-moveDistance ;
    [UIView beginAnimations: @"animation" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: moveDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];


   }

-(void)keyboardWillDisappear{
    const int moveDistance = 200;
    const float moveDuration = 0.3f;
    
    int movement =moveDistance ;
    [UIView beginAnimations: @"animation" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: moveDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)veryGoodButtonClicked:(id)sender {
    
    [self.veryGoodButton setImage:[UIImage imageNamed:@"check-mark.png"] forState:UIControlStateNormal];
    [self.goodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.notGoodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}
- (IBAction)goodButtonClicked:(id)sender {
    [self.veryGoodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.goodButton setImage:[UIImage imageNamed:@"check-mark.png"] forState:UIControlStateNormal];
    [self.notGoodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}
- (IBAction)notGoodButtonClicked:(id)sender {
    [self.veryGoodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.goodButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.notGoodButton setImage:[UIImage imageNamed:@"check-mark.png"] forState:UIControlStateNormal];
}
- (IBAction)submitButtonClicked:(id)sender {
  
    if ([self.veryGoodButton.imageView.image isEqual:[UIImage imageNamed:@"check-mark.png"]]||[self.goodButton.imageView.image isEqual:[UIImage imageNamed:@"check-mark.png"]] ||[self.notGoodButton.imageView.image isEqual:[UIImage imageNamed:@"check-mark.png"]]) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Success"
                                      message:@"Feedback submitted."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
     //   [self dismissViewControllerAnimated:YES completion:nil];

    }
    else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Failed"
                                      message:@"Feedback not submitted. Please Provide Feedback"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
     //   [self dismissViewControllerAnimated:YES completion:nil];
  
    }
    
    

    
    
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
