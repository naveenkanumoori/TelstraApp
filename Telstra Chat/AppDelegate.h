//
//  AppDelegate.h
//  Telstra Chat
//
//  Created by Admin on 5/20/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ProximitySDK.h"
#import "AdPopUpLaunchViewController_iPad.h"ß


@import Firebase;
@import FirebaseAuth;
@class RootTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) AdPopUpLaunchViewController_iPad *modalVC;
@property (nonatomic , strong) RootTabBarController *rootView;
@property (nonatomic,strong) ProximitySDK *proxisdk;
@property (nonatomic) NSMutableArray *AssociatedCampDetails;
@property NSString *userName;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@property (strong,nonatomic) UIView *statusBarview;


- (void)sendMessageToServer:(NSDictionary *)data toUser:(NSString *)to;
@end

