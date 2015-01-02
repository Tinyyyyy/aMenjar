//
//  AMAppDelegate.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMAppDelegate.h"
#import <Parse/Parse.h>
#import "APLDefaults.h"
#import "Stripe.h"
#import <PassSlot/PassSlot.h>
#import <ESTBeaconManager.h>

NSString * const StripePublishableKey = @"";

NSString * const EstimoteUUID = @"";

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AMAppDelegate () <NSXMLParserDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager  *manager;
@property (nonatomic, strong) CLBeaconRegion     *region;
@property (nonatomic, strong) CLBeacon           *lastBeacon;

@end

@implementation AMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    
    [PassSlot start:@""];
    
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    [Parse setApplicationId:@""
                  clientKey:@""];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@""];
    
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:173 identifier:@"Estimote Region"];
    self.region.notifyEntryStateOnDisplay = YES;
    self.region.notifyOnEntry = YES;
    self.region.notifyOnExit = YES;
    [self.manager startMonitoringForRegion:self.region];
    if(IS_OS_8_OR_LATER) {
        [self.manager requestWhenInUseAuthorization];
        [self.manager requestAlwaysAuthorization];
    }
    
    // Change the background color of navigation bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Change the font style of the navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"NUEVOMENUBOOL"];
    BOOL nuevoMenu = YES;
    if(data == nil){
        nuevoMenu = NO;
    }
    else {
        nuevoMenu = [[NSUserDefaults standardUserDefaults] boolForKey:@"NUEVOMENUBOOL"];
    }
    
    //MENU DEL DIA
    if (!nuevoMenu) {
        NSString *valueToSave = @"Menú del día";
        [[NSUserDefaults standardUserDefaults]
         setObject:valueToSave forKey:@"TituloMenudelDia"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"MenudeldiaPrimeros"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"MenudeldiaSegundos"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"MenudeldiaPostres"];
        
        //MENU GOLTV
        
        NSString *valueToSave2 = @"Menú GolTV";
        [[NSUserDefaults standardUserDefaults]
         setObject:valueToSave2 forKey:@"TituloMenuGol"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"GolPlatosMediodia"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"GolPlatosNoche"];
    }
    else {
        NSUserDefaults *NonVolatile = [NSUserDefaults standardUserDefaults];
        [NonVolatile setBool:NO forKey:@"NUEVOMENUBOOL"];
    }
    
    sleep(2);
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"A menjar!"
                                      message:notification.alertBody
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        [[self topMostController] presentViewController:alert animated:YES completion:nil];
    }
    else {
        //show alertview
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A menjar!"
                                                        message:notification.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

// iBeacons

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:self.region.identifier])
    {
        if ([self whantsiBeacon]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = NSLocalizedString(@"Bienvenido! Porque no entras y pruebas nuestros platos del día?", @"");
            notification.alertAction = NSLocalizedString(@"Abrir", @"");
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:self.region.identifier]) {
        if ([self whantsiBeacon]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = NSLocalizedString(@"Muchas gracias por venir! Hasta pronto", @"");
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.manager requestStateForRegion:self.region];
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            [self.manager startRangingBeaconsInRegion:self.region];
            
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            // stop ranging beacons, etc
            NSLog(@"Region unknown");
    }
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] > 0) {
        // Handle your found beacons here
        CLBeacon *beacon = [beacons firstObject];
        if (([beacon.minor isEqualToNumber:[NSNumber numberWithInt:1]]) && (![self.lastBeacon.minor isEqualToNumber:beacon.minor])) {
            if ([self whantsiBeacon]) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = @"Nuestros baños te van a encantar! Estás preparado? \ue00e";
                notification.alertAction = NSLocalizedString(@"Abrir", @"");
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
        self.lastBeacon = beacon;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    UIDevice *dev = [UIDevice currentDevice];
    NSString *tokenString = [dev name];
    if ([tokenString isEqualToString:@""]) {
        [currentInstallation setObject:@"pro" forKey:@"user"];
    }
    else if ([tokenString isEqualToString:@""]) {
        [currentInstallation setObject:@"pro" forKey:@"user"];
    }
    else if ([tokenString isEqualToString:@""]) {
        [currentInstallation setObject:@"pro" forKey:@"user"];
    }
    else if ([tokenString isEqualToString:@""]) {
        [currentInstallation setObject:@"pro" forKey:@"user"];
    }
    else {
        [currentInstallation setObject:@"free" forKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

-(BOOL)whantsiBeacon
{
    BOOL alarmaPermitida;
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"iBeaconBoolKey"];
    if(data1 == nil){
        alarmaPermitida = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iBeaconBoolKey"];
    }
    else {
        alarmaPermitida = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"iBeaconBoolKey"];
    }
    return alarmaPermitida;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
