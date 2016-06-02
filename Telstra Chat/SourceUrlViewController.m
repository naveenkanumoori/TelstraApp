//
//  SourceUrlViewController.m
//  WelcomeToInfosys
//
//  Created by admin on 5/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SourceUrlViewController.h"

@interface SourceUrlViewController ()

@end

@implementation SourceUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.detailImage.image=[UIImage imageNamed:[self.objectFromParent objectForKey:@"cDetailImage"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickingClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
