//
//  AdViewController_iPad.m
//  Parity Plus
//
//  Created by Ashirvad on 22/06/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import "AdViewController_iPad.h"
#import "AdPopUpLaunchViewController_iPad.h"
#import "SourceUrlViewController.h"
#import "AppDelegate.h"
#import "FeedBackViewController.h"




@interface AdViewController_iPad ()
{
    AppDelegate *appDelegate;
}
@end

@implementation AdViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //[self.indic startAnimating];
    self.webView.delegate=self;
    [self initiateParsing];
}
//-(void)sendReportToServer :(NSString *)value
//{
//    PostService *postClass=[[PostService alloc]init];
//    postClass.delegate=self;
//    
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"TestUDID" accessGroup:nil];
//    NSString *idfv=[[NSString alloc]init];
//    idfv=[keychain objectForKey:(__bridge id)(kSecAttrAccount)];
//    if(![idfv isEqualToString:@""])
//    {
//        idfv=[keychain objectForKey:(__bridge id)(kSecAttrAccount)];
//    }
//    else{
//        idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        if(![idfv isEqualToString:@""])
//        {
//            [keychain setObject:idfv forKey:(__bridge id)(kSecAttrAccount)];
//        }
//    }
//    
//    NSDateFormatter *outputDateFormat = [[NSDateFormatter alloc] init];
//    [outputDateFormat setDateFormat:@"dd-MMM-yyyy"];
//    [outputDateFormat setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    NSDate *date = [outputDateFormat dateFromString:[outputDateFormat stringFromDate:[NSDate date]]];
//    NSDate *gameDate = [NSDate date];
//    NSTimeInterval timeInMiliseconds = [date timeIntervalSince1970];
//    NSInteger timeInte = timeInMiliseconds;
//    NSTimeInterval timeInMilisecondsGame = [gameDate timeIntervalSince1970];
//    NSInteger timeInteGame = timeInMilisecondsGame;
//    
//
//    NSString *vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedLoggedUser"]];
//    if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
//    {
//        vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedAnonymousUser"]];
//        if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
//        {
//            vmdspid =@"not available";
//        }
//    }
//    
//    NSString *rowKey=[NSString stringWithFormat:@"%@_%@_%@_%@",[self.fromParent objectForKey:@"campaignId"],idfv,[NSString stringWithFormat:@"%ld",(long)timeInte],KEYSTRING];
//    
//    
//    NSDictionary *requestBody=nil;
//    
//    if ([value caseInsensitiveCompare:@"0"]==NSOrderedSame)
//    {
//        requestBody=[[NSDictionary alloc]initWithObjectsAndKeys:@"VCAMP",@"tableName",@"cgf",@"cf",rowKey,@"rowkey",[NSString stringWithFormat:@"%ld",(long)timeInte],@"dTs",[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"campaignId"]],@"cId",[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]],@"cName",vmdspid,@"vMdspId",[NSString stringWithFormat:@"%@",KEYSTRING],@"ak",idfv,@"dId",@"none",@"gId",[NSString stringWithFormat:@"%ld",(long)timeInteGame],@"gDate",@"none",@"gfId",@"none",@"vId",value,@"rs",@"none",@"rTs", nil];
//    }
//    else
//    {
//        requestBody=[[NSDictionary alloc]initWithObjectsAndKeys:@"VCAMP",@"tableName",@"cgf",@"cf",rowKey,@"rowkey",[NSString stringWithFormat:@"%ld",(long)timeInte],@"dTs",[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"campaignId"]],@"cId",[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]],@"cName",vmdspid,@"vMdspId",[NSString stringWithFormat:@"%@",KEYSTRING],@"ak",idfv,@"dId",@"none",@"gId",[NSString stringWithFormat:@"%ld",(long)timeInteGame],@"gDate",@"none",@"gfId",@"none",@"vId",value,@"rs",[NSString stringWithFormat:@"%ld",(long)timeInte],@"rTs", nil];
//    }
//
//    NSArray *listOfRead=[[NSArray alloc]initWithObjects:requestBody, nil];
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listOfRead options:kNilOptions error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSDictionary *requestDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:@"POST",@"Method",@"Not Required",@"AdditionalInfo",jsonString,@"requestDetails", nil];
//    [postClass connectToPostServer:requestDictionary:@"LOGS"];
//}
//
#pragma mark - Post Delegate

//-(void)didPostRegistered:(NSDictionary *)response :(NSString *)type
//{
//    //Do Nothing
//}



- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        
        
        
        
        
        NSLog(@"success");
        
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

//- (BOOL)canBecomeFirstResponder
//{ return YES; }



-(void)initiateParsing
{
   // [self sendReportToServer :@"0"];
  //  NSString *md5Value= [appDelegate MD5String:[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cBrandLogo"]]];
    
//    if (!([appDelegate getCachedImages:md5Value]))
//    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            UIImage *logoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.fromParent objectForKey:@"cBrandLogo"]]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.indic stopAnimating];
//                if (logoImage !=nil && [logoImage isKindOfClass:[UIImage class]])
//                {
//                    self.cmxtBrandLogo.image=logoImage;
//                  //  [appDelegate writeImageToDisc:logoImage withFilePath:md5Value];
//                }
//                else
//                {
//                    self.cmxtBrandLogo.image =[UIImage imageNamed:@"icon_image.png"];
//                }
//            });
//        });
   // }
   
    
    if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"Image"]==NSOrderedSame)
    {
//        NSString *md5ImageValue= [appDelegate MD5String:[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cImgURL"]]];
//        
//        if (!([appDelegate getCachedImages:md5Value]))
//        {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                UIImage *cellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.fromParent objectForKey:@"cImgURL"]]]];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.indic stopAnimating];
//                    if (cellImage !=nil && [cellImage isKindOfClass:[UIImage class]])
//                    {
//                        self.imgAd.image=cellImage;
//                        //[appDelegate writeImageToDisc:cellImage withFilePath:md5ImageValue];
//                    }
//                });
//            });
        
     //   }
//        else
        
        
//        {
        self.imgAd.image=[UIImage imageNamed:[self.fromParent objectForKey:@"cImage" ]];
        if ([[_fromParent objectForKey:@"cId"] isEqualToString:@"1"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"2"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"3"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"4"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"5"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"6"]|| [[_fromParent objectForKey:@"cId"] isEqualToString:@"7"]|| [[_fromParent objectForKey:@"cId"] isEqualToString:@"8"] || [[_fromParent objectForKey:@"cId"] isEqualToString:@"17"]) {
            self.leftButton.hidden=YES;
            self.rightButton.hidden=YES;
        }
        else{
            self.leftButton.hidden=NO;
            self.rightButton.hidden=NO;
        }
        
       // }
        
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"campaignTitle"]];
        self.webView.hidden = YES;
        self.lblText.hidden = YES;
        self.btnPlayClicked.hidden = YES;
        self.imgAd.hidden = NO;
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"Video"]==NSOrderedSame)
    {
//        NSString *md5ImageValue= [appDelegate MD5String:[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cThumbnailURL"]]];
//        
//        if (!([appDelegate getCachedImages:md5Value]))
//        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *cellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.fromParent objectForKey:@"cThumbnailURL"]]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indic stopAnimating];
                    if (cellImage !=nil && [cellImage isKindOfClass:[UIImage class]])
                    {
                        self.imgAd.image=cellImage;
                     //   [appDelegate writeImageToDisc:cellImage withFilePath:md5ImageValue];
                    }
                });
            });
      //  }
//        else
//        {
//            //self.imgAd.image=[appDelegate getCachedImages:md5ImageValue];
//        }
        
        [self.btnPlayClicked addTarget:self action:@selector(videoPlayed:) forControlEvents:UIControlEventTouchUpInside];
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        self.webView.hidden = YES;
        self.lblText.hidden = YES;
        self.btnPlayClicked.hidden = NO;
        self.imgAd.hidden = NO;
        
    }

    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"Text"]==NSOrderedSame)
    {
        
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        self.lblText.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cDesc"]];
        [self.indic stopAnimating];
        self.webView.hidden = YES;
        self.lblText.hidden = NO;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
        
        
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"Text"]==NSOrderedSame)
    {
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        self.lblText.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cDesc"]];
        [self.indic stopAnimating];
        self.webView.hidden = YES;
        self.lblText.hidden = NO;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
        
        
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"string"]==NSOrderedSame)
    {
        
        NSString* htmlString = [self.fromParent objectForKey:@"data"];
        self.webView.scrollView.scrollEnabled=YES;
        self.webView.scalesPageToFit=NO;
        [self.webView loadHTMLString:htmlString baseURL:nil];
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        
        self.webView.hidden = NO;
        self.lblText.hidden = YES;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
        
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"Presentation"]==NSOrderedSame)
    {
        
        NSURL *url = [NSURL URLWithString:[self.fromParent objectForKey:@"cBrandLogo"]];
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        self.webView.scrollView.scrollEnabled=NO;
        self.webView.scalesPageToFit=YES;
        [self.webView loadRequest:self.request];
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        
        self.webView.hidden = NO;
        self.lblText.hidden = YES;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
        
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"webURL"]==NSOrderedSame)
    {
        
        
        NSURL *url = [NSURL URLWithString:[self.fromParent objectForKey:@"cBrandLogo"]];
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        self.webView.scrollView.scrollEnabled=NO;
        self.webView.scalesPageToFit=YES;
        [self.webView loadRequest:self.request];
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        
        self.webView.hidden = NO;
        self.lblText.hidden = YES;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
    }
    else if ([[self.fromParent objectForKey:@"cType"]caseInsensitiveCompare:@"MultiPoint"]==NSOrderedSame)
    {
        NSString *vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedLoggedUser"]];
        if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
        {
            vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedAnonymousUser"]];
            if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
            {
                vmdspid =@"0";
            }
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&vmdspId=%@",[self.fromParent objectForKey:@"webAddress"],vmdspid]];
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        self.webView.scrollView.scrollEnabled=NO;
        self.webView.scalesPageToFit=YES;
        [self.webView loadRequest:self.request];
        self.lblHeading.text=[NSString stringWithFormat:@"%@",[self.fromParent objectForKey:@"cTitle"]];
        
        self.webView.hidden = NO;
        self.lblText.hidden = YES;
        self.imgAd.hidden = YES;
        self.btnPlayClicked.hidden = YES;
    }
    else
    {
        self.lblHeading.text=@"You have got an offer";
    }

}

//-(void)videoPlayed :(UIButton *)sender
//{
//    
//    SourceUrlViewController *modalVC = [[SourceUrlViewController alloc] initWithNibName:@"SourceUrlViewController" bundle:nil];
//    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    NSDictionary *tempUrls=[[NSDictionary alloc]initWithObjectsAndKeys:[self.fromParent objectForKey:@"cVidURL"],@"webAddress", nil];
//    modalVC.objectFromParent=tempUrls;
//    [self presentViewController:modalVC animated:YES completion:NULL];
//    
//    
//    //    self.moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
//    //    // Remove the movie player view controller from the "playback did finish" notification observers
//    //    [[NSNotificationCenter defaultCenter] removeObserver:self.moviePlayer
//    //                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//    //                                                  object:self.moviePlayer.moviePlayer];
//    //
//    //    // Register this class as an observer instead
//    //    [[NSNotificationCenter defaultCenter] addObserver:self
//    //                                             selector:@selector(moviePlayBackDidFinish:)
//    //                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//    //                                               object:self.moviePlayer.moviePlayer];
//    //    [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
//}
//
//-(void) moviePlayBackDidFinish:(NSNotification*)notification
//{
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//    [self dismissMoviePlayerViewControllerAnimated];
//}

#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indic stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code!=204)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Philadelphia Flyers App"
                              message:@"It is taking longer to access this content than expected. Please try agin later."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
    }
    [self.indic stopAnimating];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    self.request=nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
}

- (IBAction)leftBtnClicked:(id)sender
{
      [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)rightBtnClicked:(id)sender
{
    //    UIAlertView *alert = [[UIAlertView alloc]
    //                          initWithTitle:@"Flyers App"
    //                          message:@"Information about this offer is not available"
    //                          delegate:self
    //                          cancelButtonTitle:@"OK"
    //                          otherButtonTitles:nil];
    //
    //    [alert show];
    
//    [self sendReportToServer :@"1"];
    
    if ([[_fromParent objectForKey:@"cId"] isEqualToString:@"16"]) {
        FeedBackViewController *modalVC = [[FeedBackViewController alloc] initWithNibName:@"FeedBackViewController" bundle:nil];
        modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
      //  modalVC.objectFromParent=self.fromParent;
        [self presentViewController:modalVC animated:YES completion:NULL];

    }
    else{
    SourceUrlViewController *modalVC = [[SourceUrlViewController alloc] initWithNibName:@"SourceUrlViewController" bundle:nil];
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalVC.objectFromParent=self.fromParent;
    [self presentViewController:modalVC animated:YES completion:NULL];
    }
}

- (IBAction)btnCloseClicked:(id)sender
{
  //  [self sendReportToServer :@"1"];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
