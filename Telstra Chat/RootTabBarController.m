//
//  RootTabBarController.m
// Flyers
//
//  Created by Infosys on 25/11/14.
//  Copyright (c) 2014 com.infosys. All rights reserved.
//

#import "RootTabBarController.h"


@interface RootTabBarController ()<UITabBarDelegate>

@end

@implementation RootTabBarController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   [self attributesForTabBarItem];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.rootView = self;
   // self.tabBar.backgroundImage=
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tabbar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag==4)
    {
        //        [self.view setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:12]];
        //        [UIView beginAnimations:@"fade in" context:nil];
        //        [UIView setAnimationDuration:0.1f];
        //        [self.view setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:12]];
        //        [UIView commitAnimations];
        
        //        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LOGGEDKEY"])
        //        {
        //            [self SignupPopupViewController];
        //        }
    }
}

- (void) attributesForTabBarItem
{
    
    
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateSelected];
    UITabBarItem *tabBarItem0 = [self.tabBar.items objectAtIndex:0];
    UIImage* selectedImage0 = [[UIImage imageNamed:@"home1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem0.selectedImage = selectedImage0;
    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:1];
    UIImage* selectedImage1 = [[UIImage imageNamed:@"offer1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.selectedImage = selectedImage1;
    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:2];
    UIImage* selectedImage2 = [[UIImage imageNamed:@"chat1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = selectedImage2;
//    UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:3];
//    UIImage* selectedImage3 = [[UIImage imageNamed:@"meON.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    tabBarItem3.selectedImage = selectedImage3;
//    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:4];
//    UIImage* selectedImage4 = [[UIImage imageNamed:@"menuON.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    tabBarItem4.selectedImage = selectedImage4;
}

@end
