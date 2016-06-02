//
//  UsersViewController.m
//  Telstra Chat
//
//  Created by Admin on 5/23/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "UsersViewController.h"
#import "UsersTableViewCell.h"
#import "ChatViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface UsersViewController (){
    NSDictionary *userData;
    NSString *username,*password;
}

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"CHAT";
    
    [ self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-blue-wallpaper.png"]]];
    [self.usersTable setBackgroundColor:[UIColor clearColor]];
    
    
    // Do any additional setup after loading the view from its nib.
    
    username = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userName];
    password = @"aA@12345";
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    NSDictionary *user1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user1",@"userID",@"Kate Mckenzie",@"userName",@"infytest111@gmail.com",@"emailID",@"Kate Mckenzie.png",@"userImage", nil];
    NSDictionary *user2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user2",@"userID",@"Brian Harcourt",@"userName",@"infytest222@gmail.com",@"emailID",@"Brian Harcourt.png",@"userImage", nil];
    NSDictionary *user3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user3",@"userID",@"Craig Hancock",@"userName",@"infytest333@gmail.com",@"emailID",@"Craig Hancock.png",@"userImage", nil];
    NSDictionary *user4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user4",@"userID",@"Merren Armour",@"userName",@"infytest444@gmail.com",@"emailID",@"Merren Armour.png",@"userImage", nil];
    NSDictionary *user5 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user5",@"userID",@"Mike Wright",@"userName",@"infytest555@gmail.com",@"emailID",@"Mike Wright.png",@"userImage", nil];
    NSDictionary *user6 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user6",@"userID",@"Peter Corrigan",@"userName",@"infytest666@gmail.com",@"emailID",@"Peter Corrigan.png",@"userImage", nil];
    NSDictionary *user7 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user7",@"userID",@"Upendra Kohli",@"userName",@"infytest777@gmail.com",@"emailID",@"Upendra Kohli.png",@"userImage", nil];
     NSDictionary *user8 = [[NSDictionary alloc] initWithObjectsAndKeys:@"user8",@"userID",@"Kunal Shrivastava",@"userName",@"infytest888@gmail.com",@"emailID",@"Kunal Shrivastava.png",@"userImage", nil];
    
    self.users = [[NSMutableArray alloc] initWithObjects:user1,user2,user3,user4,user5,user6,user7,user8, nil];
    
    for (int i=0; i<self.users.count;i++) {
        if ([[[self.users objectAtIndex:i] valueForKey:@"emailID"] isEqualToString:username]) {
            [self.users removeObjectAtIndex:i];
        }
    }
    
    [self.usersTable registerNib:[UINib nibWithNibName:@"UsersTableViewCell" bundle:nil] forCellReuseIdentifier:@"userCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"ReloadTable"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [_usersTable reloadData];
}

- (void) reloadTable:(NSNotification *) notification{
    [_usersTable reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    cell.userName.text = [[self.users objectAtIndex:indexPath.row] valueForKey:@"userName"];
    cell.userImage.image=[UIImage imageNamed:[[self.users objectAtIndex:indexPath.row] valueForKey:@"userImage"]];
    cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2;
     cell.unreadMessages.layer.cornerRadius = cell.unreadMessages.frame.size.width/2;
    cell.unreadMessages.layer.borderColor = [UIColor greenColor].CGColor;
    cell.unreadMessages.layer.borderWidth = 1.5;
    cell.unreadMessages.clipsToBounds = YES;
    cell.userImage.clipsToBounds = YES;
    NSArray *unreadMessages = [[NSUserDefaults standardUserDefaults] valueForKey:@"unreadMessages"];
    int count = 0;
    if (unreadMessages) {
        for (NSDictionary *message in unreadMessages) {
            if ([[message objectForKey:@"from"] isEqualToString:[[_users objectAtIndex:indexPath.row] objectForKey:@"emailID"]]) {
                count++;
            }
        }
    }
    if (count!=0) {
        cell.unreadMessages.hidden = NO;
        cell.unreadMessages.text = [NSString stringWithFormat:@"%i",count];
    }else{
        cell.unreadMessages.hidden = YES;
    }
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 111;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    userData = [self.users objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showChatWindow" sender:self];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showChatWindow"]) {
        ChatViewController *view = [segue destinationViewController];
        view.userData = userData;
    }
}

@end
