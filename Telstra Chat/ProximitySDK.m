//
//  ProximitySDK.m
//  ProximitySDK
//
//  Created by Arunkavi on 03/03/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import "ProximitySDK.h"
#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define SERVERFAILMESSAGE @"Server Failed Temporarly"
#define STRINGSUCCESS @"success"
#define STRINGSTATUS @"status"
#define STRINGFAIL @"fail"
#define STRINGDESCRIPTION @"description"
#define STRINGEMPTYKEY @"Key/Secret is empty"
#define STRINGSEARCHING @"Searching for iBeacons..."
#define STRINGINVALIDKEY @"Invalid key/secret"
#define BEACON_IDENTIFIER @"BeaconRegion"



@interface ProximitySDK ()<NSURLConnectionDelegate,CBCentralManagerDelegate,CLLocationManagerDelegate>

{
    
@private
    
    NSString *localFlag;
    NSArray *savedUuidList;
    NSDictionary *savedUuidMajorList;
    NSURLConnection *connect;
    NSMutableData *responseData;
    NSString *statusCode;
    BOOL secondPost;
    NSString *descriptionMessage;
    NSString *authenticationMesasge;
    BOOL authorized;
    NSString *vmdspid;
    NSString *scanType;
    NSString *appId;
    NSString *deviceName;
    //Not Checked
    NSMutableDictionary *postData;
    NSMutableDictionary *postKeySecret;
    NSMutableDictionary *postHeader;
    
    int count_beacon_detect_frequency;
    int count_beacon_remove_frequency;
    CLBeacon  *beacon_waiting_for_consistency;
    
}

@property (nonatomic,strong) NSString *savedKey;
@property (nonatomic,strong) NSString *savedSecret;
@property (nonatomic,strong) NSString *savedImei;
@property (nonatomic,strong) NSString *entryType;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSDate  *sentTime;
@property (nonatomic, strong) CLBeacon *beacon_old;
@property (nonatomic, strong) CLBeaconRegion *beacon_old_region;
@property (nonatomic, strong) NSString *beacon_current;
@property (nonatomic,strong) NSDictionary *savedCampDetails;
@property (nonatomic,strong) NSMutableDictionary *campaignPolicy;
@property (nonatomic,strong) NSMutableDictionary *lastShownCampaignDetails;
@property (nonatomic,strong) NSMutableArray *lastShownCampaignIds;
@property (nonatomic,strong) NSMutableDictionary *lastShownTicketDetails;
@property (nonatomic,strong) NSData *currentRequestToServer;

//save initilized beacon regions for uuid/major level in array so that it would be easy to unmoniter
@property (nonatomic,strong) NSMutableArray *uuidBeaconRegions;
@property (nonatomic,strong) NSMutableArray *majorBeaconRegions;

//Not checked
@property (nonatomic,strong) NSDictionary *uuidMinorMajorDictionary;
@property (nonatomic,strong) NSString *uuidMinorMajor;

//Server Call
-(void)connectToAuthenticationServer:(NSString *)key :(NSString *)secret;
-(void)connectToLocationServer:(NSData *)data;

//Parsing
-(void)parseAuthenticateResponse:(NSData *)data;
-(void)parseLocationResponse:(NSData *)data;

//Beacon
-(void)initRegion :(NSString *)uuid :(NSString *)name;
-(void)initMajorLevelRegion :(NSString *)uuid :(NSString *)major :(NSString *)name;

//Encryption
-(NSString *)hmac:(NSString *)key withData:(NSString *)data;
-(NSString *)md5:(NSString *) input;
-(NSString *)sha256:(NSString *) input;

@end

@implementation ProximitySDK
@synthesize savedKey,savedSecret,uuidMinorMajor,savedImei,entryType,beacon_current,sentTime,beacon_old,beacon_old_region,campaignPolicy;

int CONSISTENCY_COUNT = 1;
int CONSISTENCY_COUNT_REMOVAL = 0;
int PRESENCE_INTERVAL=60;

-(id)init
{
    savedKey=[[NSString alloc]init];
    savedSecret=[[NSString alloc]init];
    savedUuidList=[[NSArray alloc]init];
    savedUuidList=nil;
    self.uuidMinorMajorDictionary=[[NSDictionary alloc]init];
    savedUuidMajorList=[[NSDictionary alloc]init];
    savedUuidMajorList=nil;
    self.savedCampDetails=[[NSDictionary alloc] init];
    self.savedCampDetails=nil;
    self.currentRequestToServer=[[NSData alloc]init];
    self.currentRequestToServer=nil;
    connect =[[NSURLConnection alloc]init];
    connect=nil;
    statusCode=[[NSString alloc]init];
    localFlag=[[NSString alloc]init];
    localFlag=nil;
    secondPost=NO;
    descriptionMessage=[[NSString alloc]init];
    authenticationMesasge=[[NSString alloc]init];
    descriptionMessage=nil;
    authenticationMesasge=nil;
    authorized=NO;
    entryType=[[NSString alloc]init];
    entryType=nil;
    vmdspid=[[NSString alloc]init];
    savedImei=[[NSString alloc]init];
    savedImei=@"Unknown";
    scanType=[[NSString alloc]init];
    scanType=@"Unknown";
    self.beaconsArray=[[NSArray alloc]init];
    appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    deviceName =[[UIDevice currentDevice]name];
    
    self.uuidBeaconRegions=[[NSMutableArray alloc]init];
    self.majorBeaconRegions=[[NSMutableArray alloc]init];
    
    count_beacon_detect_frequency=0;
    count_beacon_remove_frequency=0;
    //
    postData=[[NSMutableDictionary alloc]init];
    postHeader=[[NSMutableDictionary alloc]init];
    postKeySecret=[[NSMutableDictionary alloc]init];
    self.lastShownCampaignDetails=[[NSMutableDictionary alloc]init];
    self.lastShownCampaignIds=[[NSMutableArray alloc]init];
    self.lastShownTicketDetails=[[NSMutableDictionary alloc]init];
    
    uuidMinorMajor=[[NSString alloc]init];
    
    beacon_current = [[NSString alloc]init];
    sentTime = [NSDate date];
    beacon_current=nil;
    campaignPolicy=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"multipleAds",@"NO",@"rotateAds",@"YES",@"presentOnReentry",@"10",@"reentryTimer",@"NO",@"presentOnPresence",@"30",@"presenceTimer",@"2",@"waitForConsistency",@"NO",@"CampIdRePresent", nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
     self.bluetoothManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return self;
}
-(void)appInForeground : (NSNotification *) object
{
    if (self.locationManager)
    {
        if ([scanType isEqualToString:@"UUID"])
        {
            //NSLog(@"!!! Start All UUID Ranging alone with %@ ",savedUuidList);
            if (savedUuidList!=nil)
            {
                for (int i=0; i<savedUuidList.count; i++)
                {
                    NSString *uuid=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"uuid"]];
                    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
                    NSString *name=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"name"]];
                    CLBeaconRegion *newRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid identifier:name];
                    [self.locationManager startRangingBeaconsInRegion:newRegion];
                }
            }
            
        }
        else if ([scanType isEqualToString:@"MAJOR"])
        {
            //NSLog(@"!!! Start All MAJOR Ranging alone with %@ ",savedUuidList);
            
            NSArray *localMajorIds=[savedUuidMajorList objectForKey:@"majorDetails"];
            if (localMajorIds.count>0)
            {
                NSString *localUuid=[[savedUuidMajorList objectForKey:@"uuid"] objectForKey:@"uuid"];
                for (int i=0; i<localMajorIds.count; i++)
                {
                    
                    NSString *uuid=[NSString stringWithFormat:@"%@",localUuid];
                    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
                    NSString *major=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"major"]];
                    int newMajor=[major intValue];
                    uint16_t majorNumber = (uint16_t)newMajor;
                    NSString *name=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"name"]];
                    CLBeaconRegion *newRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid major:majorNumber identifier:name];
                    [self.locationManager startRangingBeaconsInRegion:newRegion];
                    
                }
            }
        }
        
    }
    
}
-(void)appWillResignActive :(NSNotification *) object
{
    
    if (self.locationManager)
    {
        if ([scanType isEqualToString:@"UUID"])
        {
            //NSLog(@"!!! Stop All UUID Ranging alone with %@ ",savedUuidList);
            if (savedUuidList!=nil)
            {
                for (int i=0; i<savedUuidList.count; i++)
                {
                    NSString *uuid=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"uuid"]];
                    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
                    NSString *name=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"name"]];
                    CLBeaconRegion *newRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid identifier:name];
                    [self.locationManager stopRangingBeaconsInRegion:newRegion];
                }
            }
            
        }
        else if ([scanType isEqualToString:@"MAJOR"])
        {
            //NSLog(@"!!! Stop All MAJOR Ranging alone with %@ ",savedUuidList);
            
            NSArray *localMajorIds=[savedUuidMajorList objectForKey:@"majorDetails"];
            if (localMajorIds.count>0)
            {
                NSString *localUuid=[[savedUuidMajorList objectForKey:@"uuid"] objectForKey:@"uuid"];
                for (int i=0; i<localMajorIds.count; i++)
                {
                    
                    NSString *uuid=[NSString stringWithFormat:@"%@",localUuid];
                    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
                    NSString *major=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"major"]];
                    int newMajor=[major intValue];
                    uint16_t majorNumber = (uint16_t)newMajor;
                    NSString *name=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"name"]];
                    CLBeaconRegion *newRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid major:majorNumber identifier:name];
                    [self.locationManager stopRangingBeaconsInRegion:newRegion];
                    
                }
            }
        }
        
    }
    
}
-(void)setUserCampaignPolicy:(NSMutableDictionary *)policy
{
    campaignPolicy=[policy mutableCopy];
}
-(void)initilizeSDK:(NSString *)key :(NSString *)secret
{
    if (key.length==0 || secret.length==0 || (key == nil) || (secret == nil))
    {
        if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=STRINGEMPTYKEY;
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:STRINGFAIL,STRINGSTATUS,STRINGEMPTYKEY,STRINGDESCRIPTION, nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            [self.delegate didInitilizedSDK:jsonData];
        }
        
    }
    else
    {
        
        localFlag=@"Authenticate";
        savedKey=key;
        savedSecret=secret;
        
        //[self pullCampaign];
        //////////
        //
        //                        NSDictionary *uuidRegion=[[NSDictionary alloc]initWithObjectsAndKeys:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6",@"uuid",@"Wells",@"name", nil];
        //                        savedUuidList=[NSArray arrayWithObjects:uuidRegion, nil];
        //
        //                        scanType=@"UUID";
        //                        authorized=YES;
        //
        //                NSDictionary *uuidAlone=[[NSDictionary alloc]initWithObjectsAndKeys:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6",@"uuid",@"Wells",@"name", nil];
        //                NSDictionary *uuidRegion1=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"major",@"Wells One",@"name", nil];
        //                NSDictionary *uuidRegion3=[[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"major",@"Wells Two",@"name", nil];
        //                NSDictionary *uuidRegion4=[[NSDictionary alloc]initWithObjectsAndKeys:@"3",@"major",@"Wells Three",@"name", nil];
        //                NSDictionary *uuidRegion5=[[NSDictionary alloc]initWithObjectsAndKeys:@"4",@"major",@"Wells Four",@"name", nil];
        //                NSDictionary *uuidRegion6=[[NSDictionary alloc]initWithObjectsAndKeys:@"5",@"major",@"Wells Five",@"name", nil];
        //                NSDictionary *uuidRegion7=[[NSDictionary alloc]initWithObjectsAndKeys:@"6",@"major",@"Wells Six",@"name", nil];
        //                NSDictionary *uuidRegion8=[[NSDictionary alloc]initWithObjectsAndKeys:@"7",@"major",@"Wells Seven",@"name", nil];
        //                NSDictionary *uuidRegion9=[[NSDictionary alloc]initWithObjectsAndKeys:@"8",@"major",@"Wells Eight",@"name", nil];
        //                NSDictionary *uuidRegion10=[[NSDictionary alloc]initWithObjectsAndKeys:@"9",@"major",@"Wells Nine",@"name", nil];
        //                NSDictionary *uuidRegion11=[[NSDictionary alloc]initWithObjectsAndKeys:@"11",@"major",@"Wells Eleven",@"name", nil];
        //                NSDictionary *uuidRegion12=[[NSDictionary alloc]initWithObjectsAndKeys:@"910",@"major",@"Wells 910",@"name", nil];
        //                NSDictionary *uuidRegion13=[[NSDictionary alloc]initWithObjectsAndKeys:@"601",@"major",@"Wells 601",@"name", nil];
        //                NSDictionary *uuidRegion14=[[NSDictionary alloc]initWithObjectsAndKeys:@"701",@"major",@"Wells 701",@"name", nil];
        //                NSDictionary *uuidRegion15=[[NSDictionary alloc]initWithObjectsAndKeys:@"906",@"major",@"Wells 906",@"name", nil];
        //                NSDictionary *uuidRegion16=[[NSDictionary alloc]initWithObjectsAndKeys:@"907",@"major",@"Wells 907",@"name", nil];
        //
        //                NSArray *majorLevel=[[NSArray alloc] initWithObjects:uuidRegion1,uuidRegion3,uuidRegion4,uuidRegion5,uuidRegion6,uuidRegion7,uuidRegion8,uuidRegion9,uuidRegion10,uuidRegion11,uuidRegion12,uuidRegion13,uuidRegion14,uuidRegion15,uuidRegion16, nil];
        //
        //                savedUuidMajorList=[[NSDictionary alloc]initWithObjectsAndKeys:uuidAlone,@"uuid",majorLevel,@"majorDetails", nil];
        //
        //                scanType=@"MAJOR";
        //                authorized=YES;
        //                         //NSLog(@"!!! sacn type %@ with %@",scanType,savedUuidMajorList);
        
        //
       
        //Call delegate method to return values
        //                        if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
        //                        {
        //
        //                            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:STRINGSUCCESS,@"status",STRINGSEARCHING,@"description", nil ];
        //                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
        //
        //                            [self.delegate didInitilizedSDK:jsonData];
        //                        }
        /////////
        
        [self connectToAuthenticationServer:key :secret];
        
    }
}
-(void)startScan:(NSDictionary *)input
{
    NSString *localKey=[input objectForKey:@"key"];
    NSString *localSecret=[input objectForKey:@"secret"];
    NSString *localImei=[input objectForKey:@"imei"];
    NSString *localVmdspid=[input objectForKey:@"vmdspid"];
    
    if (localKey.length==0 || localSecret.length==0 || localImei.length==0  || (localKey==nil) || (localSecret == nil) || (localImei == nil) || localVmdspid.length==0)
    {
        authenticationMesasge=@"filter";
        descriptionMessage=@"Key/Secret/imei/vmdspid is empty";
        
        if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
        {
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            [self.delegate didStartedScanning:jsonData:@"Not Found"];
        }
        
    }
    else{
        
        if (authorized)
        {
            //NSLog(@"!!! started scanning and Auth success");
            savedImei=[input objectForKey:@"imei"];
            savedKey=[input objectForKey:@"key"];
            savedSecret=[input objectForKey:@"secret"];
            vmdspid=[input objectForKey:@"vmdspid"];
            
            [self checkUuidList];
        }
        
        
        else
        {
            
            authenticationMesasge=@"filter";
            descriptionMessage=@"You are not authorized";
            
            if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
            {
                NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
                [self.delegate didStartedScanning:jsonData:entryType];
            }
        }
        
        
    }
    
}
-(void)checkUuidList
{
    //if location is not initilized then initilize
    scanType=@"UUID";
    
    NSMutableDictionary *uuids=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6",@"uuid",@"beacon1",@"name", nil];
    
    savedUuidList=[[NSArray alloc]initWithObjects:uuids, nil];
    
    if (!self.locationManager)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    if([CLLocationManager locationServicesEnabled])
    {
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
        {
            authenticationMesasge=@"location";
            descriptionMessage=@"Permission Denied for this App to use location";
            
            if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
            {
                NSMutableDictionary *temp=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:kNilOptions error:nil];
                [self.delegate didStartedScanning:jsonData:entryType];
            }
        }
        else
        {

            //-- Check for OS
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                //NEED to look for permissions
                //        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
                //        if(authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || authorizationStatus == kCLAuthorizationStatusAuthorizedAlways){}
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
            
            //NSLog(@"!!! Permission granted by user , for type %@ ",scanType);
            
            if ([scanType isEqualToString:@"UUID"])
            {
                //NSLog(@"!!! Its UUID level %@ ",savedUuidList);
                if (savedUuidList.count>0)
                {
                    for (int i=0; i<savedUuidList.count; i++)
                    {
                        NSString *uuid=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"uuid"]];
                        NSString *name=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"name"]];
                        [self initRegion :uuid :name];
                        
                    }
                }
                else
                {
                    authenticationMesasge=STRINGFAIL;
                    descriptionMessage=@"Update iBeacon type in portal";
                    
                    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
                    {
                        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
                        [self.delegate didStartedScanning:jsonData:@"Not Found"];
                    }
                }
                
                
            }
            else if ([scanType isEqualToString:@"MAJOR"])
            {
                //NSLog(@"!!! Its MAJOR level %@ ",savedUuidMajorList);
                
                NSArray *localMajorIds=[savedUuidMajorList objectForKey:@"majorDetails"];
                if (localMajorIds.count>0)
                {
                    NSString *localUuid=[[savedUuidMajorList objectForKey:@"uuid"] objectForKey:@"uuid"];
                    for (int i=0; i<localMajorIds.count; i++)
                    {
                        NSString *uuid=[NSString stringWithFormat:@"%@",localUuid];
                        NSString *major=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"major"]];
                        NSString *name=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"name"]];
                        [self initMajorLevelRegion :uuid :major :name];
                        
                    }
                }
                else
                {
                    authenticationMesasge=STRINGFAIL;
                    descriptionMessage=@"Update iBeacon type in portal";
                    
                    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
                    {
                        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
                        [self.delegate didStartedScanning:jsonData:@"Not Found"];
                    }
                }
                
            }
            else
            {
                //Minor level scanning
            }
            
        }
    }
    else
    {
        authenticationMesasge=@"location";
        descriptionMessage=@"Location services disabled";
        
        if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
        {
            NSMutableDictionary *temp=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:kNilOptions error:nil];
            [self.delegate didStartedScanning:jsonData:entryType];
        }
    }
    
    
    
    
    
}

-(void)stopScan
{
    @try
    {
        [connect cancel];
        connect=nil;
        
        if (self.locationManager)
        {
            if ([scanType isEqualToString:@"UUID"])
            {
                //NSLog(@"!!! Stop All UUID Monetring with %@ ",self.uuidBeaconRegions);
                
                for (int i=0; i<self.uuidBeaconRegions.count; i++)
                {
                    CLBeaconRegion *newRegion = [self.uuidBeaconRegions objectAtIndex:i];
                    [self.locationManager stopMonitoringForRegion:newRegion];
                    [self.locationManager stopRangingBeaconsInRegion:newRegion];
                }
                
                [self.uuidBeaconRegions removeAllObjects];
            }
            else if ([scanType isEqualToString:@"MAJOR"])
            {
                //NSLog(@"!!! Stop All MAJOR Monetring with %@ ",self.majorBeaconRegions);
                
                
                for (int i=0; i<self.majorBeaconRegions.count; i++)
                {
                    CLBeaconRegion *newRegion = [self.majorBeaconRegions objectAtIndex:i];
                    [self.locationManager stopMonitoringForRegion:newRegion];
                    [self.locationManager stopRangingBeaconsInRegion:newRegion];
                    
                }
                
                [self.majorBeaconRegions removeAllObjects];
            }
            
        }
        
    }
    @catch (NSException *exception)
    {
        //NSLog(@"%@",exception);
    }
}
-(void)stopRanging:(CLRegion *)input
{
    @try
    {
        if (self.locationManager)
        {
            [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)input];
        }
        
    }
    @catch (NSException *exception)
    {
        //NSLog(@"%@",exception);
    }
}
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    NSString *stateString = nil;
    
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            stateString = @"Unknown";
            break;
            
        case CBCentralManagerStateResetting:
            stateString = @"Resetting";
            break;
            
        case CBCentralManagerStateUnsupported:
            stateString = @"Unsupported";
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateString = @"Unauthorized";
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateString = @"Powered Off";
            break;
            
        case CBCentralManagerStatePoweredOn:
            stateString = @"Powered On";
            break;
    }
    
    if ([stateString isEqualToString:@"Powered Off"])
    {
        [self performSelector:@selector(manualExitEvent) withObject:nil afterDelay:1];
        
    }
    
}
-(void)manualExitEvent
{
    if (self.uuidMinorMajorDictionary!=nil && self.uuidMinorMajorDictionary.count>0)
    {
        beacon_old=nil;
        secondPost=NO;
        entryType=@"EXIT";
        NSMutableDictionary *onlyForExit=[self.uuidMinorMajorDictionary mutableCopy];
        [onlyForExit removeObjectForKey:@"entry"];
        [onlyForExit setValue:entryType forKey:@"entry"];
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:onlyForExit options:kNilOptions error:nil];
        localFlag=@"Location";
        
        NSLog(@"manual exit %@",onlyForExit);
        //Connect to Server
        [self connectToLocationServer :jsonData2];
        self.uuidMinorMajorDictionary=nil;
    }
}

#pragma mark - Server call

//-(void)pullCampaign
//{
//
//    NSDictionary *postBodyMessage=[NSDictionary dictionaryWithObjectsAndKeys:@"AIzaSyCrc1dqczy4oNYrr6frVfjI00v5mc9pGBk",@"key", nil ];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBodyMessage options:kNilOptions error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    NSString *random=[self shuffledAlphabet];
//    localFlag=@"Camp";
//    NSMutableString *finalString=[[NSMutableString alloc]initWithFormat:@"%@GET%@",random,jsonString];
//
//    NSString *md5Value=[self md5:finalString];
//
//    NSString *HmacValue=[self hmac:@"AIzaSyCrc1dqczy4oNYrr6frVfjI00v5mc9pGBk" withData:md5Value];
//    NSDictionary *postHeaderMessage=[NSDictionary dictionaryWithObjectsAndKeys:@"AIzaSyCrc1dqczy4oNYrr6frVfjI00v5mc9pGBk",@"Apikey",HmacValue,@"Hmac",md5Value,@"Content-MD5",random,@"nonce",nil ];
//    NSURL *myURL = [NSURL URLWithString:@"http://96.119.2.154:8080/Proximity/rest/campaigns/"];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
//    [request setHTTPMethod:@"GET"];
//    [request setAllHTTPHeaderFields:postHeaderMessage];
//    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
//    NSURLConnection *newConnect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
//
//    if(newConnect)
//    {
//        responseData=[[NSMutableData alloc] init];
//    }
//
//
//}

-(void)connectToAuthenticationServer:(NSString *)key :(NSString *)secret
{
    //Cancel connection
    [connect cancel];
    connect=nil;
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSRange match = [langID rangeOfString:@"-"];
    
    if(match.location != NSNotFound)
    {
        NSArray *langArray = [langID componentsSeparatedByString:@"-"];
        langID = [langArray objectAtIndex:0];
    }
    
    NSDictionary *postBodyMessage=[NSDictionary dictionaryWithObjectsAndKeys:key,@"key", nil ];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBodyMessage options:kNilOptions error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *random=[self shuffledAlphabet];
    
    NSMutableString *finalString=[[NSMutableString alloc]initWithFormat:@"%@GET",random];
    
    NSString *md5Value=[self md5:finalString];
    
    NSString *HmacValue=[self hmac:secret withData:md5Value];
    NSDictionary *postHeaderMessage=[NSDictionary dictionaryWithObjectsAndKeys:key,@"Apikey",HmacValue,@"Hmac",md5Value,@"Content-MD5",random,@"nonce",langID,@"langId", nil ];
    NSURL *myURL = [NSURL URLWithString:@"http://mdsp.g.comcast.net/ProximityEvents/sdkauthenticate"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:postHeaderMessage];
    //[request setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]] ;
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    connect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connect)
    {
        responseData=[[NSMutableData alloc] init];
    }
}

-(void)connectToLocationServer:(NSData *) data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    //NSLog(@"!!! Connecting to server with %@",result);
    
    if (myError==nil)
    {
        NSString * tempEntry= [result objectForKey:@"entry"];
        NSString * tempUuid= [[result objectForKey:@"uuid"]lowercaseString];
        NSString * tempMinor= [result objectForKey:@"minor"];
        NSString * tempMajor= [result objectForKey:@"major"];
        [self.locationManager startUpdatingLocation];
        CLLocation *newLocation=[self.locationManager location];
        
//        NSString *newLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
//        NSString *newLongtitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        
        //        NSString *newLatitude=@"0.0";
        //        NSString *newLongtitude=@"0.0";
        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSRange match = [langID rangeOfString:@"-"];
        
        if(match.location != NSNotFound)
        {
            NSArray *langArray = [langID componentsSeparatedByString:@"-"];
            langID = [langArray objectAtIndex:0];
        }
        
        
        if ([tempEntry isEqualToString:@"storeEntry"])
        {
            NSData *dataOnly=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
            if(dataOnly!=nil)
            {
                //Parse the data
                NSError *myError = nil;
                NSMutableDictionary *dataStored = [NSJSONSerialization JSONObjectWithData:dataOnly options:NSJSONReadingMutableLeaves error:&myError];
                
                
                if (dataStored!=nil && dataStored.count>0)
                {
                    NSString *availableVersion=[[dataStored objectForKey:@"data"] objectForKey:@"message"];
                    if (availableVersion!=nil && availableVersion!=(id)[NSNull null] && [availableVersion caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                    {
                        NSString *isVersion=[[dataStored objectForKey:@"data"] objectForKey:@"version"];
                        postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempUuid,@"uuid",@"",@"vMDSPId",tempMinor,@"minor",@"",@"deviceId",tempMajor,@"major",tempEntry,@"eventType",isVersion,@"version",@"0", @"dvVersion",nil ];
                        
                        
                    }
                    else
                    {
                        postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempUuid,@"uuid",@"",@"vMDSPId",tempMinor,@"minor",@"",@"deviceId",tempMajor,@"major",tempEntry,@"eventType",@"0",@"version",@"0", @"dvVersion",nil ];
                    }
                    
                }
                else
                {
                   postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempUuid,@"uuid",@"",@"vMDSPId",tempMinor,@"minor",@"",@"deviceId",tempMajor,@"major",tempEntry,@"eventType",@"0",@"version",@"0", @"dvVersion",nil ];                }}
            else
            {
               postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempUuid,@"uuid",@"",@"vMDSPId",tempMinor,@"minor",@"",@"deviceId",tempMajor,@"major",tempEntry,@"eventType",@"0",@"version",@"0", @"dvVersion",nil ];
            }
            
        }
        else
        {
            postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:tempUuid,@"uuid",@"3",@"vMDSPId",tempMinor,@"minor",@"234656",@"deviceId",tempMajor,@"major",tempEntry,@"eventType",@"0",@"version",@"0", @"dvVersion",nil ];
        }
        //NSLog(@"%@",postData);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSString *random=[self shuffledAlphabet];
//        
//        NSMutableString *finalString=[[NSMutableString alloc]initWithFormat:@"%@POST%@",random,jsonString];
//        
//        NSString *md5Value=[self md5:finalString];
//        NSString *HmacValue=[self hmac:savedSecret withData:md5Value];
        
        postHeader=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"e5b7a59a-4d09-475f-9d72-6245b58218e1",@"appKey", nil ];
        
        //NSURL *myURL = [NSURL URLWithString:@"http://10.68.168.75:8080/Dashboard/rest/events/"];
        NSURL *myURL = [NSURL URLWithString:@"http://10.10.10.174:8080/ConfluencePlatformEvents/platform/events"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setAllHTTPHeaderFields:postHeader];
        [request setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        NSURLConnection *newConnect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if(newConnect)
        {
            responseData=[[NSMutableData alloc] init];
            
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    statusCode=[NSString stringWithFormat:@"%ld",(long)httpResponse.statusCode];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(@"!!! Connecting to server failed : %@",error.localizedDescription);
    if (secondPost==NO)
    {
        if ([localFlag isEqualToString:@"Authenticate"])
        {
            
            localFlag=nil;
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=[NSString stringWithFormat:@"%@",error.localizedDescription];
            
            //Call delegate method to return values
            if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
            {
                NSMutableDictionary *temp=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:kNilOptions error:nil];
                
                [self.delegate didInitilizedSDK:jsonData];
            }
            
        }
        else if ([localFlag isEqualToString:@"Location"])
        {
            localFlag=nil;
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=[NSString stringWithFormat:@"%@",error.localizedDescription];
            
            if (self.currentRequestToServer!=nil)
            {
                @try {
                    //Parse the data
                    NSError *myError = nil;
                    NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:self.currentRequestToServer options:NSJSONReadingMutableLeaves error:&myError];
                    if (myError==nil)
                    {
                        if (result!=nil && result.count>0)
                        {
                            if ([[result objectForKey:@"entry"] caseInsensitiveCompare:@"ENTRY"]==NSOrderedSame)
                            {
                                NSData *dataStored=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
                                if (dataStored !=nil)
                                {
                                    //Parse the data
                                    NSError *myError = nil;
                                    NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:dataStored options:NSJSONReadingMutableLeaves error:&myError];
                                    if (dictinaryFromData!=nil && dictinaryFromData.count>0)
                                    {
                                        self.savedCampDetails = [dictinaryFromData objectForKey:@"data"];
                                        NSData *newData=[[NSData alloc]initWithData:self.currentRequestToServer];
                                        [self checkCampaignForBeacons:newData];
                                        self.currentRequestToServer=nil;
                                    }
                                }
                                
                                
                            }
                            
                        }
                    }
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"Exception");
                    self.currentRequestToServer=nil;
                }
                
                
            }
            else
            {
                //Call delegate method to return values
                if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
                {
                    NSMutableDictionary *temp=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp options:kNilOptions error:nil];
                    
                    [self.delegate didStartedScanning:jsonData:entryType];
                }
            }

        }
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (secondPost==NO)
    {
        if ([localFlag isEqualToString:@"Authenticate"])
        {
            @try
            {
                localFlag=nil;
                
                [self parseAuthenticateResponse:responseData];
            }
            @catch (NSException * exception)
            {
                //Need to report to server
            }
            
            
        }
        else if ([localFlag isEqualToString:@"Location"])
        {
            @try
            {
                localFlag=nil;
                [self parseLocationResponse:responseData];
            }
            @catch (NSException * exception)
            {
                //Need to report to server
            }
            
        }
        else if ([localFlag isEqualToString:@"Camp"])
        {
            @try
            {
                localFlag=nil;
                [self parseCapmResponse:responseData];
            }
            @catch (NSException * exception)
            {
                //Need to report to server
            }
            
        }
        
    }
    
}

#pragma mark - Parsing
-(void)parseCapmResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    NSString *availableMessage=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"Message"];
    //NSLog(@"!!! Version available %@",availableMessage);
    
    if (self.savedCampDetails.count>0)
    {
        //NSLog(@"!!! Locally stored capaigns are already there");
        if ([availableMessage caseInsensitiveCompare:@"yes"]==NSOrderedSame)
        {
            //NSLog(@"!!! Locally stored capaigns are already and NEW VERSION available");
            self.savedCampDetails=[dictinaryFromData objectForKey:@"data"];
            //NSLog(@"!!! Check for Beacon Details in %@",dictinaryFromData);
            [[NSUserDefaults standardUserDefaults] setObject:data  forKey:@"SAVEDCAMPVERSION"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *localEntryType=[[dictinaryFromData objectForKey:@"data"]  objectForKey:@"EventType"];
            //Check policy for Present On Presence near the same beacon
            NSString *presencePolicy=[self.campaignPolicy objectForKey:@"presentOnPresence"];
            
            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[dictinaryFromData objectForKey:@"data"] objectForKey:@"eventType"],@"entry",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"Major"],@"major",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"minor"],@"Minor",nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
            
            //Check for ENTRY or Presence (based on policy)
            if ([localEntryType isEqualToString:@"ENTRY"] || ([presencePolicy caseInsensitiveCompare:@"YES"] == NSOrderedSame && [localEntryType isEqualToString:@"StoreEntry"]))
            {
                [self checkCampaignForBeacons:jsonData];
            }
            
        }
        else
        {
            //NSLog(@"!!! Locally stored capaigns are already and NEW VERSION NOT available");
            NSData *dataStored=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
            //Parse the data
            NSError *myError = nil;
            NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:dataStored options:NSJSONReadingMutableLeaves error:&myError];
            if (dictinaryFromData!=nil && dictinaryFromData.count>0)
            {
                self.savedCampDetails = [dictinaryFromData objectForKey:@"data"];;
            }
            
        }
    }
    else
    {
        //NSLog(@"!!! Locally stored capaigns are not available");
        if ([availableMessage caseInsensitiveCompare:@"yes"]==NSOrderedSame)
        {
            NSDictionary *checkBeforeAdding=[dictinaryFromData objectForKey:@"data"];
            if (checkBeforeAdding!=nil && checkBeforeAdding.count>0)
            {
                self.savedCampDetails=[dictinaryFromData objectForKey:@"data"];
                
                [[NSUserDefaults standardUserDefaults] setObject:data  forKey:@"SAVEDCAMPVERSION"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            
        }
        else
        {
            
            NSData *dataStored=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
            //Parse the data
            NSError *myError = nil;
            NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:dataStored options:NSJSONReadingMutableLeaves error:&myError];
            if (dictinaryFromData!=nil && dictinaryFromData.count>0)
            {
                self.savedCampDetails = [dictinaryFromData objectForKey:@"data"];;
                
                //NSLog(@"!!! Stored Camp Details %@",self.savedCampDetails);
            }
            
            
        }
        if(self.savedCampDetails!=nil &&  self.savedCampDetails.count>0)
        {
            NSString *localEntryType=[[dictinaryFromData objectForKey:@"data"]  objectForKey:@"EventType"];
            //Check policy for Present On Presence near the same beacon
            NSString *presencePolicy=[self.campaignPolicy objectForKey:@"presentOnPresence"];
            
            //Check for ENTRY or Presence (based on policy)
            if ([localEntryType isEqualToString:@"ENTRY"] || ([presencePolicy caseInsensitiveCompare:@"YES"] == NSOrderedSame && [localEntryType caseInsensitiveCompare:@"PRESENCE"]==NSOrderedSame))
            {
                NSDictionary *tempDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[[dictinaryFromData objectForKey:@"data"]  objectForKey:@"EventType"],@"entry",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"Major"],@"major",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"Minor"],@"minor",nil ];
                
                NSData *tempJsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
                [self checkCampaignForBeacons:tempJsonData];
            }
        }
        
    }
    
    NSArray *checkForMajor=[[self.savedCampDetails objectForKey:@"campaigns"] objectForKey:@"majordetails"];
    
    //NSLog(@"!!! Major count %lu and current scan type %@",(unsigned long)checkForMajor.count,scanType);
    if ([scanType caseInsensitiveCompare:@"UUID"]==NSOrderedSame && (checkForMajor.count>0))
    {
        //NSLog(@"!!! Have to unmonitor and re monitor for Major level");
        [self stopScan];
        NSArray *checkForUUid=[[self.savedCampDetails objectForKey:@"campaigns"] objectForKey:@"venuedetails"];
        
        NSMutableArray *constructMajors=[[NSMutableArray alloc]init];
        if (checkForUUid.count>0)
        {
            //NSLog(@"!!!Re monitor for Major level with uuid found");
            NSDictionary *uuidAlone=[[NSDictionary alloc]initWithObjectsAndKeys:[[checkForUUid objectAtIndex:0] objectForKey:@"venueUUID"],@"uuid",[[checkForUUid objectAtIndex:0] objectForKey:@"vName"],@"name", nil];
            //NSLog(@"!!! New uuid details %@ from %@",uuidAlone,self.savedCampDetails);
            for (int i=0; i<checkForMajor.count; i++)
            {
                NSString *localMajor=[NSString stringWithFormat:@"%@",[[checkForMajor objectAtIndex:i] objectForKey:@"major"]];
                NSDictionary *localDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:localMajor,@"major",[[checkForMajor objectAtIndex:i] objectForKey:@"gfName"],@"name", nil];
                [constructMajors addObject:localDictionary];
            }
            //NSLog(@"!!! New major details %@",constructMajors);
            savedUuidMajorList=[[NSDictionary alloc]initWithObjectsAndKeys:uuidAlone,@"uuid",constructMajors,@"majorDetails", nil];
            scanType=@"MAJOR";
            authorized=YES;
            //NSLog(@"!!! New sacn type %@ with %@",scanType,savedUuidMajorList);
            [self checkUuidList];
        }
        
    }
    
}
-(void)parseAuthenticateResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError==nil)
    {
        NSString * resultString= [dictinaryFromData objectForKey:@"statusMsg"];
        
        if([resultString isEqualToString:@"success"])
        {
            NSString *type=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"type"];
            if ([type caseInsensitiveCompare:@"venue"]==NSOrderedSame)
            {
                savedUuidList=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"venuedetails"];
                
                scanType=@"UUID";
                authorized=YES;
            }
            else if ([type caseInsensitiveCompare:@"geofence"]==NSOrderedSame)
            {
                NSDictionary *venueUuid = [[dictinaryFromData objectForKey:@"data"] objectForKey:@"venuedetails"];
                NSArray *majorLevel= [[dictinaryFromData objectForKey:@"data"] objectForKey:@"majordetails"];
                
                savedUuidMajorList=[[NSDictionary alloc]initWithObjectsAndKeys:venueUuid,@"uuid",majorLevel,@"majorDetails", nil];
                
                scanType=@"MAJOR";
                authorized=YES;
                
            }
            
            if(savedUuidList.count==0)
            {
                authenticationMesasge=STRINGFAIL;
                descriptionMessage=@"Update iBeacon type in portal";
                
            }
            else
            {
                authenticationMesasge=STRINGSUCCESS;
                descriptionMessage=STRINGSEARCHING;
            }
            
            
        }
        else if([resultString isEqualToString:@"filter"])
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=STRINGINVALIDKEY;
        }
        else
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=SERVERFAILMESSAGE;
        }
        
    }
    else
    {
        authenticationMesasge=STRINGFAIL;
        descriptionMessage=SERVERFAILMESSAGE;
        
    }
    
    //Call delegate method to return values
    if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
    {
        
        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
        [self.delegate didInitilizedSDK:jsonData];
    }
    
}
-(void)parseLocationResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    //NSLog(@"!!! Response from the server %@",res);
    
//    NSMutableDictionary *tempLocationDict=[[NSMutableDictionary alloc]init];
//    NSData *jsonData = [[NSData alloc]init];
    
    if (myError==nil)
    {
        
       [self parseCapmResponse:data];
        
    }
//        NSString * result= [res objectForKey:STRINGSTATUS];
//        
//        if([result isEqualToString:@"filter"])
//        {
//            
//            authenticationMesasge=@"filter";
//            descriptionMessage=@"Invalid key/secret";
//            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
//            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
//        }
//        else if([result isEqualToString:@"serviceError"])
//        {
//            authenticationMesasge=@"fail";
//            descriptionMessage=@"Server Failed";
//            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
//            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
//        }
//        else
//        {
//            authenticationMesasge=@"success";
//            descriptionMessage=@"Users loaction reported to server";
//            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
//            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
//            [self parseCapmResponse:data];
//        }
//        
//    }
//    else
//    {
//        authenticationMesasge=@"fail";
//        descriptionMessage=@"Server Failed";
//        tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
//        jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
//    }
//    
//    //    //Call delegate method for testing
//    //    if([self.delegate respondsToSelector:@selector(didGetUuid:)])
//    //    {
//    //        [self.delegate didGetUuid:uuidMinorMajor];
//    //    }
//    
//    //Call delegate method to return values
//    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
//    {
//        [self.delegate didStartedScanning:jsonData:entryType];
//    }
    
}

#pragma mark - Encryption

-(NSString *)hmac:(NSString *)key withData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    return HMAC;
    
}
- (NSString *)shuffledAlphabet
{
    NSUInteger NUMBER_OF_CHARS = 7;
    char data[NUMBER_OF_CHARS];
    for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
}
- (NSString *) md5:(NSString *) input
{
    
    // Now create the MD5 hashs
    const char *ptr = [input UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}
- (NSString *)sha256:(NSString *) input
{
    const char *s=[input cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}


#pragma mark - Native Api

- (void)initRegion :(NSString *)uuid :(NSString *)name
{
    //NSLog(@"!!! Started for UUID level with %@ %@ ",uuid,name);
    
    
    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid identifier:name];
    [self.uuidBeaconRegions addObject:self.beaconRegion];
    
    self.beaconRegion.notifyOnEntry=YES;
    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        
    }
    else
    {
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

-(void)initMajorLevelRegion :(NSString *)uuid :(NSString *)major :(NSString *)name
{
    //NSLog(@"!!! Started for MAJOR level with %@ %@ %@",uuid,major,name);
    
    
    NSUUID *tempUuid = [[NSUUID alloc] initWithUUIDString:uuid];
    int newMajor=[major intValue];
    uint16_t majorNumber = (uint16_t)newMajor;
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:tempUuid major:majorNumber identifier:name];
    [self.majorBeaconRegions addObject:self.beaconRegion];
    
    self.beaconRegion.notifyOnEntry=YES;
    self.beaconRegion.notifyOnExit=YES;
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        
    }
    else
    {
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"Started Monitering for %@",region.identifier);
    [self.locationManager requestStateForRegion:region];
    
}
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state==CLRegionStateInside) {
        //NSLog(@"didDetermineState for %@ INSIDE REGION",region.identifier);
        [self reportEntryOrPresenceInRegion:region];
    }
    else{
        //NSLog(@"didDetermineState for %@ UNKNOWN OR OUTSIDE REGION",region.identifier);
        //[self stopRanging:region];
    }
}
-(void)reportEntryOrPresenceInRegion:(CLRegion *)region{
    
    CLBeaconRegion *reg=(CLBeaconRegion *)region;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        
        //[self stopRanging:region];
        
        //        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        //        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        //        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //        localNotification.alertBody = [NSString stringWithFormat:@"You have Entered the Region %@",region.identifier];
        //        localNotification.soundName = UILocalNotificationDefaultSoundName;
        //        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        if ([scanType isEqualToString:@"UUID"])
        {
            NSLog(@"Entered UUID Region :  %@ (Background)",region);
            
        }
        else if ([scanType isEqualToString:@"MAJOR"])
        {
            NSLog(@"Entered MAJOR Region :  %@ (Background)",region);
        }
        
        NSUUID *oriName=reg.proximityUUID;
        NSString *name=[oriName UUIDString];
        NSString *major =@"none";
        NSString *minor = @"none";
        
        if (reg.major!=nil)
        {
            major=[NSString stringWithFormat:@"%@",reg.major];
        }
        if (reg.minor!=nil)
        {
            minor=[NSString stringWithFormat:@"%@",reg.minor];
        }
        
        
        NSMutableDictionary *serverMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ENTRY",@"entry",name,@"uuid",major,@"major",minor,@"minor",nil ];
        self.uuidMinorMajorDictionary=serverMessage;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverMessage options:kNilOptions error:nil];
        self.currentRequestToServer=jsonData;
        localFlag=@"Location";
        
        //Connect to Server
        [self connectToLocationServer :jsonData];
        if (self.savedCampDetails.count>0)
        {
            [self checkCampaignForBeacons:jsonData];
        }
        
    }
    if (state == UIApplicationStateActive)
    {
        //NSLog(@"Entered Region :  %@ (Foreground)",region);
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //NSLog(@"!!! Inside DidEnterRegion for %@",region);
    [self reportEntryOrPresenceInRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //If we are exiting the region that we last used lets reset all
    if ([beacon_old_region isEqual:region]) {
        beacon_old_region = nil;
        beacon_old = nil;
    }
    //    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    //    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    //    {
    
    //[self stopRanging:region];
    //Do checking here.
    //        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    //        localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //        localNotification.alertBody = [NSString stringWithFormat:@"You have Exited the Region %@",region.identifier];
    //        localNotification.soundName = UILocalNotificationDefaultSoundName;
    //        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    CLBeaconRegion *reg=(CLBeaconRegion *)region;
    NSUUID *oriName=reg.proximityUUID;
    NSString *name=[oriName UUIDString];
    NSString *major =@"none";
    NSString *minor = @"none";
    
    if ([scanType isEqualToString:@"UUID"])
    {
        NSLog(@"Exited UUID Region :  %@ (Background)",region);
        
    }
    else if ([scanType isEqualToString:@"MAJOR"])
    {
        NSLog(@"Exited MAJOR Region :  %@ (Background)",region);
    }
    
    if (reg.major!=nil)
    {
        major=[NSString stringWithFormat:@"%@",reg.major];
    }
    if (reg.minor!=nil)
    {
        minor=[NSString stringWithFormat:@"%@",reg.minor];
    }
    
    
    NSMutableDictionary *serverMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"EXIT",@"entry",name,@"uuid",major,@"major",minor,@"minor",nil ];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverMessage options:kNilOptions error:nil];
    localFlag=@"Location";
    
    //Connect to Server
    [self connectToLocationServer :jsonData];
    
    //    if ([scanType isEqualToString:@"UUID"])
    //    {
    //        NSLog(@"EXITED UUID Region : %@ (Background)",region);
    //
    //        for (int i=0; i<savedUuidList.count; i++)
    //        {
    //            NSString *name=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"name"]];
    //            if ([name isEqualToString:region.identifier])
    //            {
    //                NSString *uuid=[NSString stringWithFormat:@"%@",[[savedUuidList objectAtIndex:i] objectForKey:@"uuid"]];
    //
    //                NSMutableDictionary *tempDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"EXIT",@"entry",uuid,@"uuid",@"none",@"major",@"none",@"minor",nil ];
    //                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDict1 options:kNilOptions error:nil];
    //                localFlag=@"Location";
    //
    //                //Connect to Server
    //                [self connectToLocationServer :jsonData];
    //                break;
    //
    //            }
    //
    //        }
    //
    //    }
    //    else if ([scanType isEqualToString:@"MAJOR"])
    //    {
    //        NSLog(@"EXITED MAJOR Region :  %@ (Background)",region);
    //
    //        NSArray *localMajorIds=[savedUuidMajorList objectForKey:@"majorDetails"];
    //        if (localMajorIds.count>0)
    //        {
    //            for (int i=0; i<localMajorIds.count; i++)
    //            {
    //                NSString *name=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"name"]];
    //                if ([name isEqualToString:region.identifier])
    //                {
    //                    NSString *uuid=[NSString stringWithFormat:@"%@",[[savedUuidMajorList objectForKey:@"uuid"] objectForKey:@"uuid"]];
    //                    NSString *major=[NSString stringWithFormat:@"%@",[[localMajorIds objectAtIndex:i] objectForKey:@"major"]];
    //
    //                    NSMutableDictionary *serverMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"EXIT",@"entry",uuid,@"uuid",major,@"major",@"none",@"minor",nil ];
    //                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverMessage options:kNilOptions error:nil];
    //                    localFlag=@"Location";
    //
    //                    //Connect to Server
    //                    [self connectToLocationServer :jsonData];
    //                    break;
    //
    //                }
    //
    //
    //            }
    //        }
    //
    //    }
    
    
    //    }
    //    if (state == UIApplicationStateActive)
    //    {
    //         NSLog(@"Left Region : %@ (Foreground)",region);
    //        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    //    }
    
}
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    
    //NSLog(@"!!! Failed to range beacons ");
    authenticationMesasge=@"SDK-BLE-Error";
    descriptionMessage=error.localizedDescription;
    
    //Call delegate method to return values
    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
    {
        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
        [self.delegate didStartedScanning:jsonData:entryType];
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"!!! Failed to scan for beacons");
    authenticationMesasge=@"SDK-BLE-Error";
    descriptionMessage=error.localizedDescription;
    
    //Call delegate method to return values
    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
    {
        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
        [self.delegate didStartedScanning:jsonData:entryType];
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //NSLog(@"!!! Ranging beacons for %@ and found %@",region.identifier,beacons);
    self.beaconsArray = beacons;
    
    if (self.beaconsArray.count>0)
    {
        
        NSMutableArray *numbers = [[NSMutableArray alloc]init];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        for (int i =0; i<[self.beaconsArray count];i++)
        {
            CLBeacon *beacon = [self.beaconsArray objectAtIndex:i];
            [numbers addObject:[NSString stringWithFormat:@"%ld",(long)beacon.rssi]];
            [dictionary setObject:beacon forKey:[NSString stringWithFormat:@"%ld",(long)beacon.rssi]];
        }
        
        NSArray *numbers_all = (NSArray *)numbers;
        numbers_all = [numbers_all sortedArrayUsingSelector:@selector(compare:)];
        
        //The closest beacon in this region is the first in the array
        CLBeacon *beacon_new = [dictionary objectForKey:numbers_all[0]];
        
        //        self.uuidMinorMajorDictionary =[[NSDictionary alloc]initWithObjectsAndKeys:beacon_new.proximityUUID.UUIDString,@"uuid",[beacon_new.major stringValue],@"major",[beacon_new.minor stringValue],@"minor",nil ];
        
        NSDate *currentDate1 = [NSDate date];
        NSTimeInterval timeDiff1=[currentDate1 timeIntervalSinceDate:sentTime];
        
        
        //First time we are detecting a a beacon. No old beacon so lets report this to our platform
        if(beacon_old == nil && timeDiff1>1)
        {
            beacon_old = beacon_new;
            beacon_old_region = region;
            sentTime = [NSDate date];
            
            
            entryType=@"ENTRY";
            secondPost=NO;
            
            localFlag=@"Location";
            
            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:entryType,@"entry",beacon_new.proximityUUID.UUIDString,@"uuid",[beacon_new.major stringValue],@"major",[beacon_new.minor stringValue],@"minor",nil ];
            self.uuidMinorMajorDictionary=tempDictionary;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
            //NSLog(@"!!! DidRange campaigns count %lu",(unsigned long)self.savedCampDetails.count);
//            if (self.savedCampDetails.count>0)
//            {
                [self checkCampaignForBeacons:jsonData];
          //  }
            //NSLog(@"!!! DidRange connect to server");
            //Connect to Server
          //  [self connectToLocationServer :jsonData];
            
        }
        
        //Check if the new closest beacon is different from the last one we reported
        
        //Region is same so lets make the switch if the id is different
        else if (![[NSString stringWithFormat:@"%@%d%d",beacon_old.proximityUUID.UUIDString, beacon_old.major.intValue,beacon_old.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]]){
            
            if([beacon_old_region isEqual:region] ){
                //Closest beacon changed with in the region. Lets wait for consitency
                if(beacon_waiting_for_consistency==nil || (![[NSString stringWithFormat:@"%@%d%d",beacon_waiting_for_consistency.proximityUUID.UUIDString, beacon_waiting_for_consistency.major.intValue,beacon_waiting_for_consistency.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]])){
                    beacon_waiting_for_consistency = beacon_new;
                    count_beacon_detect_frequency=0;
                }
                else if([[NSString stringWithFormat:@"%@%d%d",beacon_waiting_for_consistency.proximityUUID.UUIDString, beacon_waiting_for_consistency.major.intValue,beacon_waiting_for_consistency.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]]){
                    count_beacon_detect_frequency++;
                }
            } else {
                //This may be an immediate call for another region when we are ranging for multiple regions at the same time
                //We need to compare the rssi (Only difference here is the checking of rssi)
                //NSLog(@"!!! old rssi %ld new rssi %ld",(long)beacon_old.rssi,(long)beacon_new.rssi);
                if (beacon_new.rssi !=0 && (beacon_old.rssi < beacon_new.rssi)) {
                    //Closest beacon changed with in the region. Lets wait for consitency
                    if((beacon_waiting_for_consistency==nil) || (![[NSString stringWithFormat:@"%@%d%d",beacon_waiting_for_consistency.proximityUUID.UUIDString, beacon_waiting_for_consistency.major.intValue,beacon_waiting_for_consistency.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]]))
                    {
                        
                        beacon_waiting_for_consistency = beacon_new;
                        count_beacon_detect_frequency=0;
                    }
                    else if([[NSString stringWithFormat:@"%@%d%d",beacon_waiting_for_consistency.proximityUUID.UUIDString, beacon_waiting_for_consistency.major.intValue,beacon_waiting_for_consistency.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]]){
                        count_beacon_detect_frequency++;
                    }
                }
            }
            
            if (count_beacon_detect_frequency>=CONSISTENCY_COUNT) {
                count_beacon_detect_frequency=0;
                //Now are are sure we are closest to the new beacon after a consistency count, so lets reset the beacon_old and
                //unset the consistency waiting beacon
                beacon_waiting_for_consistency = nil;
                beacon_old = beacon_new;
                sentTime = [NSDate date];
                //uuidMinorMajor=beacon_old;
                
                entryType=@"ENTRY";
                secondPost=NO;
                
                localFlag=@"Location";
                
                NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:entryType,@"entry",beacon_new.proximityUUID.UUIDString,@"uuid",[beacon_new.major stringValue],@"major",[beacon_new.minor stringValue],@"minor",nil ];
                self.uuidMinorMajorDictionary=tempDictionary;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
                
//                if (self.savedCampDetails.count>0)
//                {
                    [self checkCampaignForBeacons:jsonData];
//                }
//                //Connect to Server
//                [self connectToLocationServer :jsonData];
                
                
            }
        }
        
//        else if([[NSString stringWithFormat:@"%@%d%d",beacon_old.proximityUUID.UUIDString, beacon_old.major.intValue,beacon_old.minor.intValue] isEqualToString:[NSString stringWithFormat:@"%@%d%d",beacon_new.proximityUUID.UUIDString, beacon_new.major.intValue,beacon_new.minor.intValue]] && timeDiff1 >30 )
//        {
//            //Closest beacon remains same for the presence period
//            sentTime = [NSDate date];
//            //uuidMinorMajor=beacon_old;
//            //self.uuidMinorMajorDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:beacon.proximityUUID.UUIDString,@"uuid",[beacon.major stringValue],@"major",[beacon.minor stringValue],@"minor",nil ];
//            entryType=@"PRESENCE";
//            if (self.savedCampDetails.count==0) {
//                entryType=@"ENTRY";
//            }
//            secondPost=NO;
//            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:entryType,@"entry",beacon_new.proximityUUID.UUIDString,@"uuid",[beacon_new.major stringValue],@"major",[beacon_new.minor stringValue],@"minor",nil ];
//            self.uuidMinorMajorDictionary=tempDictionary;
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
//            localFlag=@"Location";
//            
//            //Connect to Server
//            
//            [self connectToLocationServer :jsonData];
//            
//        }
        
    }
    else
    {
        if (beacon_old!=nil)
        {
            NSString *oldbeaconInRegion = [NSString stringWithFormat:@"%@%d",beacon_old.proximityUUID.UUIDString, beacon_old.major.intValue];
            NSString *currentRegion = [NSString stringWithFormat:@"%@%d",region.proximityUUID.UUIDString, region.major.intValue];
            if ([oldbeaconInRegion caseInsensitiveCompare:currentRegion]==NSOrderedSame)
            {
                if (count_beacon_remove_frequency>=CONSISTENCY_COUNT_REMOVAL)
                {
                    //NSLog(@"old beacon is removed if the beacon is no more found in the region");
                    beacon_old=nil;
                    count_beacon_remove_frequency=0;
                }
                else
                {
                    count_beacon_remove_frequency++;
                }
            }
            
        }
    }
    
}

-(void)checkCampaignForBeacons :(NSData *) input
{
    //Parse the data
    NSError *myError = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:input options:NSJSONReadingMutableLeaves error:&myError];
    //NSLog(@"!!! Checking campaign for beacons : %@",result);
    NSString* uuidDevice = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (myError==nil)
    {
        
        NSMutableDictionary *finalCamp=[[NSMutableDictionary alloc]init];
        if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"1"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"]) {
            //hard code values and populate the final camp
            if ([uuidDevice isEqualToString:@"951A5694-088E-4F8B-8DC4-4F794C395554"]) {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Kate !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"kate.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"1" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                 [self sendCampDetailsToApplication:arrayCamp :input];
            }
            
            else if ([uuidDevice isEqualToString:@"49A13A19-9129-4DCE-8C5F-94CE240DBC45"])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Brian !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Brian Harcourt.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"2" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];

            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Craig !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Craig Hancock.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"3" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Merren !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Merren Armour.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"4" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Mike !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Mike Wright.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"5" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Peter !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Peter Corrigan.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"6" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Upendra !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Upendra Kohli.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"7" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }
            else if ([uuidDevice isEqualToString:@""])
            {
                [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
                [finalCamp setValue:@"Welcome Kunal !" forKey:@"campaignTitle"];
                [finalCamp setValue:@"Kunal Shrivastava.png" forKey:@"cImage"];
                [finalCamp setValue:@"" forKey:@"cImgURL"];
                
                [finalCamp setValue:@"" forKey:@"cBrandLogo"];
                [finalCamp setValue:@"8" forKey:@"cId"];
                [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
                
                NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
                [self sendCampDetailsToApplication:arrayCamp :input];
                
            }






            
            
           
            
            NSLog(@"%@",finalCamp);
            
            
            
            
            //  [finalCamp removeAllObjects];
            
           
            
            
            
            
            
            
        }
        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"2"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
        {
            //hard code values and populate the final camp
            [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp setValue:@"Agenda" forKey:@"campaignTitle"];
            [finalCamp setValue:@"AgendaPopup.png" forKey:@"cImage"];
            [finalCamp setValue:@"" forKey:@"cImgURL"];
            [finalCamp setValue:@"" forKey:@"cBrandLogo"];
            
             [finalCamp setValue:@"Agenda.png" forKey:@"cDetailImage"];
            [finalCamp setValue:@"9" forKey:@"cId"];
            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
            
            NSLog(@"%@",finalCamp);
            
            
            // [finalCamp removeAllObjects];
            
            [self sendCampDetailsToApplication:arrayCamp :input];
            
            
            
        }
        
        
//        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"3"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
//        {
//            //hard code values and populate the final camp
//            [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
//            [finalCamp setValue:@"Stall Layout" forKey:@"campaignTitle"];
//            [finalCamp setValue:@"stallLayout.png" forKey:@"cImage"];
//            [finalCamp setValue:@"" forKey:@"cImgURL"];
//            [finalCamp setValue:@"" forKey:@"cBrandLogo"];
//            
//            [finalCamp setValue:@"Lamb Cakes are $29.95 each and available until Easter Sunday. Please call the day before you want one to order, so we can have time to make what you'd like!   Our custom cookies are sure to make anyone smile. Our rabbit and chick cookies are a staple that we make every year. Rabbit and chick iced butter cookies are $2.69. Available until Easter Sunday." forKey:@"cDesc"];
//            [finalCamp setValue:@"3" forKey:@"cId"];
//            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
//            
//            NSLog(@"%@",finalCamp);
//            
//            
//            // [finalCamp removeAllObjects];
//            
//            [self sendCampDetailsToApplication:arrayCamp :input];
//            
//            
//            
//        }
        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"3"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
        {
            //hard code values and populate the final camp
            [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp setValue:@"Theme of the Tech Stall" forKey:@"campaignTitle"];
            [finalCamp setValue:@"theme.png" forKey:@"cImage"];
            [finalCamp setValue:@"" forKey:@"cImgURL"];
            [finalCamp setValue:@"" forKey:@"cBrandLogo"];
            
            [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
            [finalCamp setValue:@"10" forKey:@"cId"];
            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
            
            NSLog(@"%@",finalCamp);
            
            
            // [finalCamp removeAllObjects];
            
            [self sendCampDetailsToApplication:arrayCamp :input];
            
            
            
        }
        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"4"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
        {
            //hard code values and populate the final camp
            
            NSMutableDictionary *finalCamp1=[[NSMutableDictionary alloc]init];
             NSMutableDictionary *finalCamp2=[[NSMutableDictionary alloc]init];
             NSMutableDictionary *finalCamp3=[[NSMutableDictionary alloc]init];
             NSMutableDictionary *finalCamp4=[[NSMutableDictionary alloc]init];
             NSMutableDictionary *finalCamp5=[[NSMutableDictionary alloc]init];
            
            [finalCamp1 setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp1 setValue:@"Stall 1" forKey:@"campaignTitle"];
            [finalCamp1 setValue:@"Camp1.png" forKey:@"cImage"];
            [finalCamp1 setValue:@"" forKey:@"cImgURL"];
            [finalCamp1 setValue:@"" forKey:@"cBrandLogo"];
            
            [finalCamp1 setValue:@"camp1Detail.png" forKey:@"cDetailImage"];
            [finalCamp1 setValue:@"11" forKey:@"cId"];
            
            
            
            [finalCamp2 setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp2 setValue:@"Stall 2" forKey:@"campaignTitle"];
            [finalCamp2 setValue:@"Camp2.png" forKey:@"cImage"];
            [finalCamp2 setValue:@"" forKey:@"cImgURL"];
            [finalCamp2 setValue:@"" forKey:@"cBrandLogo"];
            
           [finalCamp1 setValue:@"camp2Detail.png" forKey:@"cDetailImage"];
            [finalCamp2 setValue:@"12" forKey:@"cId"];
            
            
            
            [finalCamp3 setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp3 setValue:@"Stall 3" forKey:@"campaignTitle"];
            [finalCamp3 setValue:@"Camp3.png" forKey:@"cImage"];
            [finalCamp3 setValue:@"" forKey:@"cImgURL"];
            [finalCamp3 setValue:@"" forKey:@"cBrandLogo"];
            
            [finalCamp1 setValue:@"camp3Detail.png" forKey:@"cDetailImage"];
            [finalCamp3 setValue:@"13" forKey:@"cId"];

            
            
            [finalCamp4 setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp4 setValue:@"Stall 4" forKey:@"campaignTitle"];
            [finalCamp4 setValue:@"Camp4.png" forKey:@"cImage"];
            [finalCamp4 setValue:@"" forKey:@"cImgURL"];
            [finalCamp4 setValue:@"" forKey:@"cBrandLogo"];
            
           [finalCamp1 setValue:@"camp4Detail.png" forKey:@"cDetailImage"];
            [finalCamp4 setValue:@"14" forKey:@"cId"];
            
            
            
            
            [finalCamp5 setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp5 setValue:@"Stall 5" forKey:@"campaignTitle"];
            [finalCamp5 setValue:@"Camp5.png" forKey:@"cImage"];
            [finalCamp5 setValue:@"" forKey:@"cImgURL"];
            [finalCamp5 setValue:@"" forKey:@"cBrandLogo"];
            
          [finalCamp1 setValue:@"camp5Detail.png" forKey:@"cDetailImage"];
            [finalCamp5 setValue:@"15" forKey:@"cId"];


            
            
            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp1,finalCamp2,finalCamp3,finalCamp4,finalCamp5 ,nil];
            
          
            
            
            // [finalCamp removeAllObjects];
            
            [self sendCampDetailsToApplication:arrayCamp :input];
            
            
            
        }
        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"5"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
        {
            //hard code values and populate the final camp
            [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp setValue:@"Please provide Feedback" forKey:@"campaignTitle"];
            [finalCamp setValue:@"feedBack.png" forKey:@"cImage"];
            [finalCamp setValue:@"" forKey:@"cImgURL"];
            [finalCamp setValue:@"" forKey:@"cBrandLogo"];
            
            [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
            [finalCamp setValue:@"16" forKey:@"cId"];
            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
            
            NSLog(@"%@",finalCamp);
            
            
            // [finalCamp removeAllObjects];
            
            [self sendCampDetailsToApplication:arrayCamp :input];
            
            
            
        }
        else if ([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"6"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"])
        {
            //hard code values and populate the final camp
            [finalCamp setValue:@"Image" forKey:@"campaignContentType"];
            [finalCamp setValue:@"Thank you!!!!" forKey:@"campaignTitle"];
            [finalCamp setValue:@"Thank-You.png" forKey:@"cImage"];
            [finalCamp setValue:@"" forKey:@"cImgURL"];
            [finalCamp setValue:@"" forKey:@"cBrandLogo"];
            
             [finalCamp setValue:@"LauchOne.png" forKey:@"cDetailImage"];
            [finalCamp setValue:@"17" forKey:@"cId"];
            NSMutableArray *arrayCamp=[[NSMutableArray alloc]initWithObjects:finalCamp, nil];
            
            NSLog(@"%@",finalCamp);
            
            
            // [finalCamp removeAllObjects];
            
            [self sendCampDetailsToApplication:arrayCamp :input];
            
            
            
        }
        else{
            
        }





        
//        else if([[result objectForKey:@"major"] isEqualToString:@"1"]  && [[result objectForKey:@"minor"] isEqualToString:@"8"] && [[result objectForKey:@"uuid"] isEqualToString:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"]){
//            
//            //hard code values and populate the final camp  and call server
//            
//            NSString *version=[[NSString alloc]init];
//            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"campaignVersion"]) {
//                version=[[NSUserDefaults standardUserDefaults]objectForKey:@"campaignVersion"];
//            }
//            else {
//                version=@"0";
//            }
//            
//            
//            NSMutableDictionary *campDict = [[NSMutableDictionary alloc]init];
//            
//            
//            
//            [campDict setObject:version forKey:@"version"];
//            [campDict setObject:@"00:0f:cc:6e:c1:bc" forKey:@"bssid"];
//            [campDict setObject:@"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6" forKey:@"uuid"];
//            [campDict setObject:@"1" forKey:@"major"];
//            [campDict setObject:@"8" forKey:@"minor"];
//            //[campDict setObject:@"1f00efec-c221-49c7-b513-7534819f93c5" forKey:@"appKey"];
//            //need to add more fields if required
//            
//            
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:campDict options:kNilOptions error:nil];
//            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            
//            NSDictionary *requestDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:@"POST",@"Method",jsonString,@"userDetails",@"Not Required",@"AdditionalInfo", nil];
//            
//            PostService *service = [[PostService alloc] init];
//            service.delegate = self;
//            
//            [service connectToPostServer:requestDictionary :@"GETCAMPAIGNS"];
//            
//            //save the version in userdefaults
//            
//        }
        
        
    }
    
    else
    {
        //NSLog(@"No campaign found for current venue");
    }
    
}

-(void)sendCampDetailsToApplication :(NSMutableArray *)input : (NSData *)beaconDetails
{
    //Parse the data
//    NSError *myError = nil;
//    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:beaconDetails options:NSJSONReadingMutableLeaves error:&myError];
//    //NSLog(@"!!! Beacon details in final : %@",result);
//    //NSLog(@"!!! CAMP details in final : %@",input);
//    NSString *localUuidMajorMinor=[[NSString alloc]init];
//    if (myError==nil)
//    {
//        if ([scanType isEqualToString:@"MAJOR"])
//        {
//            
//            NSString * originalUuid= [result objectForKey:@"uuid"];
//            NSString * originalMinor= [result objectForKey:@"minor"];
//            NSString * originalMajor= [result objectForKey:@"major"];
//            
//            localUuidMajorMinor=[NSString stringWithFormat:@"%@:%@:%@",originalUuid,originalMajor,originalMinor];
//            
//        }
//        else if ([scanType isEqualToString:@"UUID"])
//        {
//            NSString * originalUuid= [result objectForKey:@"uuid"];
//            NSString * originalMinor= [result objectForKey:@"minor"];
//            NSString * originalMajor= [result objectForKey:@"major"];
//            
//            localUuidMajorMinor=[NSString stringWithFormat:@"%@:%@:%@",originalUuid,originalMajor,originalMinor];
//        }
//    }
//    
    NSMutableArray *Originalcampaign=[[NSMutableArray alloc]initWithArray:input];
//    
//    NSMutableArray *campaignToSend=[[NSMutableArray alloc]init];
//    [campaignToSend removeAllObjects];
//    NSString *multipleAdsPolicy=[self.campaignPolicy objectForKey:@"multipleAds"];
//    
//    if ([multipleAdsPolicy caseInsensitiveCompare:@"NO"]==NSOrderedSame)
//    {
//        //NSLog(@"what,s there in policy %@",self.campaignPolicy);
//        NSString *rePresentId=[self.campaignPolicy objectForKey:@"CampIdRePresent"];
//        if ([rePresentId caseInsensitiveCompare:@"YES"]==NSOrderedSame)
//        {
//            //NSLog(@"!!! Rotate Ads Dictionay has %@",self.lastShownCampaignDetails);
//            if (self.lastShownCampaignDetails!=nil && self.lastShownCampaignDetails.count>0 && localUuidMajorMinor.length>10)
//            {
//                if ([self.lastShownCampaignDetails objectForKey:localUuidMajorMinor])
//                {
//                    campaignToSend=[self.lastShownCampaignDetails objectForKey:localUuidMajorMinor];
//                    if (campaignToSend.count>0)
//                    {
//                        input=[[NSMutableArray alloc]initWithObjects:[campaignToSend objectAtIndex:0], nil];
//                        NSMutableArray *localArray=[campaignToSend mutableCopy];
//                        [localArray removeObjectAtIndex:0];
//                        [self.lastShownCampaignDetails setValue:localArray forKey:localUuidMajorMinor];
//                        
//                    }
//                    else
//                    {
//                        //Loop to show the same campaign based policy
//                        NSString *rotateLocalPolicy=[self.campaignPolicy objectForKey:@"rotateAds"];
//                        if ([rotateLocalPolicy caseInsensitiveCompare:@"YES"]==NSOrderedSame)
//                        {
//                            NSMutableArray *localArray=[input mutableCopy];
//                            [localArray removeObjectAtIndex:0];
//                            [self.lastShownCampaignDetails setValue:localArray forKey:localUuidMajorMinor];
//                            input=[[NSMutableArray alloc]initWithObjects:[input objectAtIndex:0], nil];
//                        }
//                        else
//                        {
//                            [input removeAllObjects];
//                        }
//                        
//                    }
//                    
//                }
//                else
//                {
//                    
//                    NSMutableArray *localArray=[input mutableCopy];
//                    [localArray removeObjectAtIndex:0];
//                    [self.lastShownCampaignDetails setValue:localArray forKey:localUuidMajorMinor];
//                    
//                    input=[[NSMutableArray alloc]initWithObjects:[input objectAtIndex:0], nil];
//                }
//                
//                
//            }
//            else
//            {
//                
//                NSMutableArray *localArray=[input mutableCopy];
//                [localArray removeObjectAtIndex:0];
//                [self.lastShownCampaignDetails setValue:localArray forKey:localUuidMajorMinor];
//                
//                input=[[NSMutableArray alloc]initWithObjects:[input objectAtIndex:0], nil];
//            }
//            
//        }
//        else
//        {
//            //NSLog(@"!!! Rotate Ads Array has %@",self.lastShownCampaignIds);
//            if (self.lastShownCampaignIds!=nil && self.lastShownCampaignIds.count>0)
//            {
//                
//                for (int i=0; i<input.count; i++)
//                {
//                    if ([self.lastShownCampaignIds containsObject:[input objectAtIndex:i]])
//                    {
//                        if (i==input.count-1)
//                        {
//                            [input removeAllObjects];
//                        }
//                    }
//                    else
//                    {
//                        [self.lastShownCampaignIds addObject:[input objectAtIndex:i]];
//                        input=[[NSMutableArray alloc]initWithObjects:[input objectAtIndex:i], nil];
//                        break;
//                    }
//                }
//                
//            }
//            else
//            {
//                [self.lastShownCampaignIds addObject:[input objectAtIndex:0]];
//                input=[[NSMutableArray alloc]initWithObjects:[input objectAtIndex:0], nil];
//            }
//        }
//        
//        
//    }
    //NSLog(@"!!! Final camp details to Application %@",input);
//    
//    if (input.count>0)
//    {
//        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
//        {
//            
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//            localNotification.timeZone = [NSTimeZone defaultTimeZone];
//            localNotification.alertBody = [NSString stringWithFormat:@"%@",[[input objectAtIndex:0] objectForKey:@"cTitle"]];
//            localNotification.soundName = UILocalNotificationDefaultSoundName;
//            //localNotification.applicationIconBadgeNumber = 1;
//            NSDictionary *infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"offers",@"type",input,@"description",Originalcampaign,@"AllCampaigns", nil];
//            localNotification.userInfo = infoDictionary;
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
    
        //Call delegate method to return values
        if([self.delegate respondsToSelector:@selector(didGetCampaign:)]) 
        {
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:STRINGSUCCESS,@"status",input,@"description",Originalcampaign,@"AllCampaigns", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            
            NSMutableArray *array1=[Originalcampaign mutableCopy];
            
            if ([[[NSUserDefaults standardUserDefaults ]objectForKey:@"CampaignsId"] count ]!=0) {
              
            NSMutableArray *array2=[[[NSUserDefaults standardUserDefaults ]objectForKey:@"CampaignsId"]mutableCopy];
            
            for (int i=0; i<array1.count; i++) {
                for (int j=0; j<array2.count; j++) {
                    if (!([array2 containsObject:[[array1 objectAtIndex:i]objectForKey:@"cId"]])) {
                        NSMutableArray *newCamp=[[[NSUserDefaults standardUserDefaults ]objectForKey:@"CampaignsId" ]mutableCopy];
                        NSMutableArray *newCamps=[[[NSUserDefaults standardUserDefaults ]objectForKey:@"Campaigns" ]mutableCopy];
                        [newCamp addObject:[[array1 objectAtIndex:i]objectForKey:@"cId"]];
                         [newCamps addObject:[array1 objectAtIndex:i]];
                       [[NSUserDefaults standardUserDefaults]setObject:newCamp forKey:@"CampaignsId"];
                        [[NSUserDefaults standardUserDefaults]setObject:newCamps forKey:@"Campaigns"];
                       [self.delegate didGetCampaign:jsonData];
                        break;
                    }
                    else{
                        
                    }
                }
            }
            }
            else{
                
                for (int i=0; i<array1.count; i++) {
                    NSMutableArray *campaignIds=[[NSMutableArray alloc]init];
                    NSMutableArray *campaigns=[[NSMutableArray alloc]init];
                    
                    [campaignIds addObject:[[array1 objectAtIndex:i]objectForKey:@"cId"]];
                     [campaigns addObject:[array1 objectAtIndex:i]];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:campaignIds forKey:@"CampaignsId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSUserDefaults standardUserDefaults]setObject:campaigns forKey:@"Campaigns"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                     [self.delegate didGetCampaign:jsonData];
                    
                }
               
            }
            
            
            
            
        }
        
   // }
}

@end
