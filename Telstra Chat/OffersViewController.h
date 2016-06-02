//
//  OffersViewController.h
//  Telstra Chat
//
//  Created by admin on 5/26/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OffersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *offersTableView;
@property (strong , nonatomic) NSMutableArray *arrayOfCampaigns;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end
