//
//  AppDelegate.m
//  Telstra Chat
//
//  Created by Admin on 5/20/16.
//  Copyright © 2016 infosys. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "UsersViewController.h"
#import "RootTabBarController.h"
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate ()<WebserviceDelegate>{
    NSString *username,*password;
    int _msglength;
    FIRDatabaseHandle _refHandle;
    NSDictionary *userData;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *messages;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:75.0f/255.0f green:0.0f/255.0f blue:130.0f/255.0f alpha:1]];
//    [[UINavigationBar appearance] setTranslucent:NO];
   // [[UIApplication sharedApplication]cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CampaignsId"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Campaigns"];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:137.0/255.0f green:0.0/255.0f blue:137.0/255.0f alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"System" size:18.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setOpaque:NO];
    self.statusBarview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];
    self.statusBarview.backgroundColor=[UIColor colorWithRed:137.0/255.0f green:0.0/255.0f blue:137.0/255.0f alpha:1.0];
    
    self.proxisdk=[[ProximitySDK alloc]init];
    self.proxisdk.delegate=self;
    //
    //    UIImage *temp=[UIImage imageNamed:@"telstra.png"];
    //
    //    float aspectRatio=[UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    //    float screenWidth=temp.size.width;
    //    //return temp.size.height+10;
    //  self.heightConstraint.constant= screenWidth/aspectRatio;
    [self.proxisdk checkUuidList];

   ///[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"storedMessages"];
    [FIRApp configure];
    
    username = @"infytest222@gmail.com";
    password = @"aA@12345";
    self.userName = username;
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            [[FIRAuth auth] signInWithEmail:username password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                    return;
                }
                [self signedIn:user];
            }];
        }
    }];
    
    //Notifications
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                             UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeBadge:)
                                                 name:@"changeBadge"
                                               object:nil];
    
    
    
    return YES;
}

-(void)changeBadge:(NSNotification *)notification{
    if (((NSArray *)notification.object).count==0) {
        [[[[self.rootView tabBar] items] objectAtIndex:2] setBadgeValue:NULL];
    }
    else{
    [[[[self.rootView tabBar] items] objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%lu", ((NSArray *)notification.object).count]];
    }
    
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    
}
-(void)applicationDidEnterBackground:(UIApplication *)application{
    [self initializeListeners];
}



-(void)didStartedScanning:(NSData *)data :(NSString *)type
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError==nil)
    {
        NSString * result= [resultDictionary objectForKey:@"status"];
        
        if([result isEqualToString:@"success"])
        {
            //do nothing
        }
        else
        {
            //debug the problem
        }
        
    }
    else
    {
        //debug the problem
    }
}
-(void)didGetCampaign:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:resultDictionary, nil];
    
    if (myError==nil)
    {
        NSMutableArray *arrayCamp=[[NSMutableArray alloc]init];
        arrayCamp =[resultDictionary objectForKey:@"description"];
        if ([self isKindOfClass:[AdPopUpLaunchViewController_iPad class]])
        {
            //Pop is still in there
        }
        else
        {
            self.modalVC = [[AdPopUpLaunchViewController_iPad alloc] initWithNibName:@"AdPopUpLaunchViewController_iPad" bundle:nil];
            self.modalVC.adFeeds=arrayCamp;
            
            self.modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.modalVC.view.backgroundColor = [UIColor clearColor];
            
            if ([[array firstObject]allKeys].count!=0) {
                [self.rootView presentViewController:self.modalVC animated:YES completion:NULL];
            }
            
        }
    }
    
    
    
    
    
    
    
    
}




#pragma mark - Firebase Required
- (void)setDisplayName:(FIRUser *)user {
    FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
    // Use first part of email as the default display name
    changeRequest.displayName = [[user.email componentsSeparatedByString:@"@"] objectAtIndex:0];
    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        [self signedIn:[FIRAuth auth].currentUser];
    }];
}

- (void)signedIn:(FIRUser *)user {
    NSLog(@"Signed In");
    if (!user.displayName) {
        [self setDisplayName:user];
    }
    [self configureDatabase];
}

-(void)configureDatabase{
    _ref = [[FIRDatabase database] reference];
    _msglength = 10;
    _messages = [[NSMutableArray alloc] init];
    
    
   
    
    [self initializeListeners];
}

-(void)initializeListeners{
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive || state==UIApplicationStateActive)
    {
        
    NSString *listenId = [[[FIRAuth auth].currentUser.email componentsSeparatedByString:@"@"] firstObject];
    _refHandle = [[_ref child:[NSString stringWithFormat:@"messages/%@",listenId]] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
                {
        [self createNotification];
                }
        AudioServicesPlaySystemSound(1111);
        [self parseData:(FIRDataSnapshot *)snapshot];
    }];
    }
    
}

-(void)parseData:(FIRDataSnapshot *)snapshot{
    NSString *listenId = [[[FIRAuth auth].currentUser.email componentsSeparatedByString:@"@"] firstObject];
    NSDictionary *message = snapshot.value;
    NSMutableArray *storedMessages = nil;
    NSMutableArray *unreadMessages = nil;
    
    
    NSMutableDictionary *dict  = [message mutableCopy];
    [dict setObject:snapshot.key forKey:@"messageID"];
    
    //Initializing unread messages
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"unreadMessages"]) {
        unreadMessages = [[NSMutableArray alloc]initWithArray: [[NSUserDefaults standardUserDefaults] valueForKey:@"unreadMessages"]];
    }else{
        unreadMessages = [[NSMutableArray alloc] init];
    }
    
    //Unread Messages
    if (![unreadMessages containsObject:dict]) {
        [unreadMessages addObject:dict];
        [[[[self.rootView tabBar] items] objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)unreadMessages.count]];
        [[NSUserDefaults standardUserDefaults] setObject:unreadMessages forKey:@"unreadMessages"];
    }
    
    //Initializing local stored messages
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"storedMessages"]) {
        storedMessages = [[NSMutableArray alloc]initWithArray: [[NSUserDefaults standardUserDefaults] valueForKey:@"storedMessages"]];
    }else{
        storedMessages = [[NSMutableArray alloc] init];
    }
    
    //Store in local database
    if (![storedMessages containsObject:dict]) {
        [storedMessages addObject:dict];
        [[NSUserDefaults standardUserDefaults] setObject:storedMessages forKey:@"storedMessages"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:self];
    }
    
   
    
    //Removing from online database
    [[_ref child:[NSString stringWithFormat:@"messages/%@/%@",listenId,snapshot.key]] removeValue];
}

- (void)sendMessageToServer:(NSDictionary *)data toUser:(NSString *)to{
    [[[[_ref child:@"messages"] child:to] childByAutoId] setValue:data];
    
    NSMutableArray *storedMessages = nil;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"storedMessages"]) {
        storedMessages = [[NSMutableArray alloc]initWithArray: [[NSUserDefaults standardUserDefaults] valueForKey:@"storedMessages"]];
    }else{
        storedMessages = [[NSMutableArray alloc] init];
    }
    
    [storedMessages addObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:storedMessages forKey:@"storedMessages"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:self];

}

-(void)createNotification{
    UIApplication *application = [UIApplication sharedApplication];
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:@"New message received"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
     notification.applicationIconBadgeNumber=1;
    [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    app.applicationIconBadgeNumber =0;
    
    notif.soundName = UILocalNotificationDefaultSoundName;
    
   // [self _showAlert:[NSString stringWithFormat:@"%@",Your msg withTitle:@"Title"];
     
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.infosys.Telstra_Chat" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Telstra_Chat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Telstra_Chat.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
