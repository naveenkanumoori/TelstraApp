//
//  AdPopUpLaunchViewController_iPad.h
//  Parity Plus
//
//  Created by Ashirvad on 22/06/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AdViewController_iPad.h"

@interface AdPopUpLaunchViewController_iPad : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
- (IBAction)btnMoreClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@property (nonatomic, strong) NSArray *adFeeds;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UIPageControl *myPageControl;
@property (nonatomic, strong) AdViewController_iPad *boxChildViewController;

@end
