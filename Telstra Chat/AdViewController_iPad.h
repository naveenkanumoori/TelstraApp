//
//  AdViewController_iPad.h
//  Parity Plus
//
//  Created by Ashirvad on 22/06/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdViewController_iPad : UIViewController<UIWebViewDelegate>

@property (assign, nonatomic) NSInteger index;
@property(strong,nonatomic) NSDictionary *dataFromParentClass;

@property(strong,nonatomic) NSMutableDictionary *fromParent;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayClicked;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property(strong,nonatomic) NSURLRequest *request;
@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIImageView *imgAd;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIImageView *imgleftIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblHeading;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indic;
- (IBAction)leftBtnClicked:(id)sender;
- (IBAction)rightBtnClicked:(id)sender;
- (IBAction)btnCloseClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *cmxtBrandLogo;

@end
