//
//  OffersViewController.m
//  Telstra Chat
//
//  Created by admin on 5/26/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "OffersViewController.h"
#import "OffersTableViewCell.h"
#import "SourceUrlViewController.h"
#import "FeedBackViewController.h"

@interface OffersViewController ()

@end

@implementation OffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"OFFERS";
    self.arrayOfCampaigns=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"Campaigns"]];
    
    for (int i=0; i<self.arrayOfCampaigns.count; i++) {
        if ([[[self.arrayOfCampaigns objectAtIndex:i ]  objectForKey:@"cId"] isEqualToString:@"1"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"2"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"3"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"4"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"5"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"6"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"7"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"8"]) {
            
            [self.arrayOfCampaigns removeObjectAtIndex:i];
            break;
     }
    }
    
    
    [self.offersTableView reloadData];
    self.statusLabel.hidden=YES;
    self.offersTableView.hidden=NO;
    // Do any additional setup after loading the view.
    if (self.arrayOfCampaigns.count==0) {
        self.statusLabel.hidden=NO;
        self.offersTableView.hidden=YES;
    }

}

-(void) viewDidAppear:(BOOL)animated{
    
    self.arrayOfCampaigns=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"Campaigns"]];
    for (int i=0; i<self.arrayOfCampaigns.count; i++) {
        if ([[[self.arrayOfCampaigns objectAtIndex:i ]  objectForKey:@"cId"] isEqualToString:@"1"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"2"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"3"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"4"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"5"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"6"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"7"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"8"]) {
            
            [self.arrayOfCampaigns removeObjectAtIndex:i];
            break;
        }
    }
    if (self.arrayOfCampaigns.count==0) {
        self.statusLabel.hidden=NO;
        self.offersTableView.hidden=YES;
    }

    [self.offersTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
   
    self.arrayOfCampaigns=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"Campaigns"]];
    for (int i=0; i<self.arrayOfCampaigns.count; i++) {
        if ([[[self.arrayOfCampaigns objectAtIndex:i ]  objectForKey:@"cId"] isEqualToString:@"1"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"2"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"3"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"4"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"5"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"6"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"7"]
            || [[[self.arrayOfCampaigns objectAtIndex:i ] objectForKey:@"cId"] isEqualToString:@"8"]) {
            
            [self.arrayOfCampaigns removeObjectAtIndex:i];
            break;
            
        }
    }
    if (self.arrayOfCampaigns.count==0) {
        self.statusLabel.hidden=NO;
        self.offersTableView.hidden=YES;
    }

    [self.offersTableView reloadData];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return self.foodAndBeveragesItems.count;
    return self.arrayOfCampaigns.count;
}

//Populating Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"OffersTableViewCell";
    OffersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OffersTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // cell.offersImage.image=[UIImage imageNamed:[[self.arrayOfCampaigns objectAtIndex:indexPath.row] objectForKey:@"cImage"]];
    
    
    if (![[[self.arrayOfCampaigns objectAtIndex:indexPath.row ] objectForKey:@"imageCMSUrl"] isEqualToString:@""] && [[self.arrayOfCampaigns objectAtIndex:indexPath.row ] objectForKey:@"imageCMSUrl"]   ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *cellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.arrayOfCampaigns objectAtIndex:indexPath.row ] objectForKey:@"imageCMSUrl"]]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // [self.indic stopAnimating];
                if (cellImage !=nil && [cellImage isKindOfClass:[UIImage class]])
                {
                    float aspectRatio=cellImage.size.width/cellImage.size.height;
                    //  float screenWidth=self.imgAd.bounds.size.width;
                    //return temp.size.height+10;`
                    // self.viewHeightConstraint.constant=139+(screenWidth/aspectRatio);
                    cell.offersImage.image=cellImage;
                }
            });
        });
        
    }
    else{
        cell.offersImage.image=[UIImage imageNamed:[[self.arrayOfCampaigns objectAtIndex:indexPath.row] objectForKey:@"cImage"]];    }
    
    
    
    
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.offersTitle.text=[[self.arrayOfCampaigns objectAtIndex:indexPath.row] objectForKey:@"campaignTitle"];
    cell.expiresOn.text=@"Expires on 30th April, 2016";
    [cell.offersvIEW.layer setCornerRadius:10.0f];
    
    [cell.offersvIEW.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.offersvIEW.layer setBorderWidth:1.5f];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


- (void) btnDeleteClicked:(UIButton *)sender
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    actionSheet.tag=sender.tag;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove Offer", nil)];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)]];
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view.superview];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Remove Offer", nil)])
    {
        [self deleteOfferFeed:actionSheet.tag];
    }
}

- (void) deleteOfferFeed:(NSInteger)offerToBeDeleted
{
    
    NSMutableArray *offers = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Campaigns"] mutableCopy];
    NSMutableArray *offersIds = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CampaignsId"] mutableCopy];
    NSString *campId = [[self.arrayOfCampaigns objectAtIndex:offerToBeDeleted] objectForKey:@"cId"];
    for (int i=0; i<offers.count; i++)
    {
        if ([campId isEqualToString:[NSString stringWithFormat:@"%@",[[offers objectAtIndex:i] objectForKey:@"cId"]]])
        {
            [offers removeObjectAtIndex:i];
            [offersIds removeObjectAtIndex:i];
            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:offers forKey:@"Campaigns"];
    [[NSUserDefaults standardUserDefaults] setObject:offersIds forKey:@"CampaignsId"];
    
    
    
    [self.arrayOfCampaigns removeObjectAtIndex:offerToBeDeleted];
    [self.offersTableView reloadData];
    
    if (self.arrayOfCampaigns.count==0) {
        self.statusLabel.hidden=NO;
        self.offersTableView.hidden=YES;
    }
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[self.arrayOfCampaigns objectAtIndex:indexPath.row ]objectForKey:@"cId"] isEqualToString:@"16"]) {
        FeedBackViewController *modalVC = [[FeedBackViewController alloc] initWithNibName:@"FeedBackViewController" bundle:nil];
        modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        //  modalVC.objectFromParent=self.fromParent;
        [self presentViewController:modalVC animated:YES completion:NULL];
        
    }
    else{
        SourceUrlViewController *modalVC = [[SourceUrlViewController alloc] initWithNibName:@"SourceUrlViewController" bundle:nil];
        modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        modalVC.objectFromParent=[self.arrayOfCampaigns objectAtIndex:indexPath.row ];
        [self presentViewController:modalVC animated:YES completion:NULL];
    }

    
}


//Returning Height for cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 280.0f;
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

@end
