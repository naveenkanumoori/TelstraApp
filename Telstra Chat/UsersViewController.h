//
//  UsersViewController.h
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSMutableArray *users;
@property (weak, nonatomic) IBOutlet UITableView *usersTable;

@end
