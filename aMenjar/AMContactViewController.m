//
//  XYZContactViewController.m
//  iNotas
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMContactViewController.h"
#import "AMContactCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SWRevealViewController.h"
#import "AMTiempoTableViewCell.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface AMContactViewController ()<MFMailComposeViewControllerDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property NSMutableArray *favoritos;
@property UIImage *logo;
@property NSNumber *temp;
@property NSNumber *min;
@property NSNumber *max;
@property BOOL visible;
@property NSString *tipo;

@end

@implementation AMContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info." style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _sidebarButton.image = [UIImage imageNamed:@"menu"];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self refreshWeather];
}

- (BOOL)connectedToInternet
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

-(void)refreshWeather
{
    if (![self connectedToInternet]) {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"Mapas fuera de servicio. Vuelva a intentarlo más tarde."
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
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            //show alertview
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sin conexión a internet"
                                                            message:@"Se necesita conexión a internet. Active el wi-fi o el 3G/4G."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    self.tipo = @"";
    self.temp = [NSNumber numberWithDouble:DBL_MIN];
    self.max = [NSNumber numberWithDouble:DBL_MAX];
    self.min = [NSNumber numberWithDouble:DBL_MIN];
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=41.40392019999999&lon=2.1967128000000002&mode=json&units=metric&lang=sp"];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    //Capturing server response
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    self.visible = YES;
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (!error) {
             NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSDictionary *main = [parsedObject objectForKey:@"main"];
             NSArray *weather = [parsedObject objectForKey:@"weather"];
             NSDictionary *detail = [weather objectAtIndex:0];
             self.tipo = [detail objectForKey:@"description"];
             self.temp = [main objectForKey:@"temp"];
             self.max = [main objectForKey:@"temp_max"];
             self.min = [main objectForKey:@"temp_min"];
             self.logo = [UIImage imageNamed:[detail objectForKey:@"icon"]];
             if (self.visible) {
                 self.visible = NO;
                 [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             }
         }
     }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    self.visible = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.visible = NO;
}

- (void)willBecomeActive:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self.tableView reloadData];
}

-(void)appHasGoneInBackground:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(willBecomeActive:)
                                                   name:UIApplicationWillEnterForegroundNotification
                                                 object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)Facebook:(UITapGestureRecognizer *)onetap
{
    NSURL *fbURL = [NSURL URLWithString:@"fb://profile/295540453790784"];
    if (![[UIApplication sharedApplication] canOpenURL:fbURL]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/amenjar"]];
    else  [[UIApplication sharedApplication] openURL:fbURL];
}

-(void)Twitter:(UITapGestureRecognizer *)onetap
{
    NSURL *twURL = [[NSURL alloc] initWithString:@"twitter://user?screen_name=amenjar"];
    if (![[UIApplication sharedApplication] canOpenURL:twURL]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/amenjar"]];
    else [[UIApplication sharedApplication] openURL: twURL];
}

-(void)Mail:(UITapGestureRecognizer *)onetap
{
    if ([MFMailComposeViewController canSendMail]) {
        NSArray *toNom = [[NSArray alloc] initWithObjects:@"info@amenjar.com", nil];
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Contacto"];
        [mailViewController setMessageBody:@"" isHTML:NO];
        [mailViewController setToRecipients:toNom];
        [self presentModalViewController:mailViewController animated:YES];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)Telefono:(UITapGestureRecognizer *)onetap
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Call"
                                      message:@"931760651"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Llamar"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 NSString *URLString = @"tel://931760651";
                                 NSURL *URL = [NSURL URLWithString:URLString];
                                 [[UIApplication sharedApplication] openURL:URL];
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        
        UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:cancel]; // add action to uialertcontroller
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        //show alertview
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"931760651", @"AlertView")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancelar", @"AlertView")
                                                  otherButtonTitles:NSLocalizedString(@"Llamar", @"AlertView"), nil];
        [alertView show];
    }
}

-(void)Yelp:(UITapGestureRecognizer *)onetap
{
    NSURL *yelpURL = [[NSURL alloc] initWithString:@"yelp:///biz/a-menjar-barcelona"];
    if (![[UIApplication sharedApplication] canOpenURL:yelpURL]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yelp.com/biz/a-menjar-barcelona"]];
    else [[UIApplication sharedApplication] openURL: yelpURL];
}

-(void)Whatsapp:(UITapGestureRecognizer *)onetap
{
    CFErrorRef err = nil;
    ABAddressBookRef adbk = ABAddressBookCreateWithOptions(nil, &err);
    if (nil == adbk) NSLog(@"error: %@", err);
    NSArray *snides = (__bridge_transfer NSArray *)(ABAddressBookCopyPeopleWithName(adbk, (CFStringRef)@"a menjar!"));
    if ([snides count] < 1) {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Añade el contacto"
                                          message:@"Para poder utilizar este método añada el contacto con el botón del menú."
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
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            //show alertview
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Añade el contacto"
                                                            message:@"Para poder utilizar este método añada el contacto con el botón del menú."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        ABRecordID recordID = ABRecordGetRecordID((__bridge ABRecordRef)([snides objectAtIndex:0]));
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?abid=%d",recordID]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) [[UIApplication sharedApplication] openURL: whatsappURL];
        else {
            if (nil != NSClassFromString(@"UIAlertController")) {
                //show alertcontroller
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Instale Whatsapp"
                                              message:@"Para poder utilizar este método instale Whatsapp"
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
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                //show alertview
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instale Whatsapp"
                                                                message:@"Para poder utilizar este método instale Whatsapp"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

-(void)AddToBook:(UITapGestureRecognizer *)onetap
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                CFErrorRef error = nil;
                ABRecordRef newPerson = ABPersonCreate();
                ABRecordSetValue(newPerson, kABPersonFirstNameProperty, @"a menjar!", &error);
                //Phone
                ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(multiPhone, @"931760651", kABPersonPhoneMainLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
                CFRelease(multiPhone);
                ABMutableMultiValueRef phoneNumberMultiValue =  ABMultiValueCreateMutableCopy (ABRecordCopyValue(newPerson, kABPersonPhoneProperty));
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"0034672129317",  kABPersonPhoneMobileLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
                //Mail
                ABMutableMultiValueRef addr = ABMultiValueCreateMutable(kABStringPropertyType);
                ABMultiValueAddValueAndLabel(addr, @"info@amenjar.com",kABWorkLabel, nil);
                ABRecordSetValue(newPerson, kABPersonEmailProperty, addr, nil);
                CFRelease(addr);
                //URL
                ABMutableMultiValueRef web = ABMultiValueCreateMutable(kABStringPropertyType);
                ABMultiValueAddValueAndLabel(web, @"www.amenjar.com",kABWorkLabel, nil);
                ABRecordSetValue(newPerson, kABPersonURLProperty, web, nil);
                CFRelease(web);
                //Social
                ABMultiValueRef social = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                ABMultiValueAddValueAndLabel(social, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                           (NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey,
                                                                           @"amenjar", kABPersonSocialProfileUsernameKey,
                                                                           nil]), kABPersonSocialProfileServiceTwitter, NULL);
                ABMultiValueAddValueAndLabel(social, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                           (NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey,
                                                                           @"295540453790784", kABPersonSocialProfileUsernameKey,
                                                                           nil]), kABPersonSocialProfileServiceFacebook, NULL);
                ABRecordSetValue(newPerson, kABPersonSocialProfileProperty, social, NULL);
                CFRelease(social);
                //Image
                NSData * dataRef = UIImagePNGRepresentation([UIImage imageNamed:@"logoAM"]);
                ABPersonSetImageData(newPerson, (__bridge CFDataRef)dataRef, nil);
                //Direccion
                ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
                [addressDict setObject:@"Calle Sancho de Ávila 173" forKey:(NSString *)kABPersonAddressStreetKey];
                [addressDict setObject:@"08018" forKey:(NSString *)kABPersonAddressZIPKey];
                [addressDict setObject:@"Barcelona" forKey:(NSString *)kABPersonAddressCityKey];
                ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonAddressProperty, address, &error);
                CFRelease(address);
                //Add person to addressbook
                ABAddressBookAddRecord(addressBookRef, newPerson, &error);
                ABAddressBookSave(addressBookRef, &error);
                CFRelease(newPerson);
                CFRelease(addressBookRef);
                if (error != NULL)
                {
                    CFStringRef errorDesc = CFErrorCopyDescription(error);
                    NSLog(@"Contact not saved: %@", errorDesc);
                    CFRelease(errorDesc);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                if (nil != NSClassFromString(@"UIAlertController")) {
                    //show alertcontroller
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"No se ha podido añadir el contacto!"
                                                  message:@"Debe permitir el acceso de esta aplicación a su lista de contactos."
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
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //show alertview
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No se ha podido añadir el contacto!", @"AlertView")
                                                                        message:NSLocalizedString(@"Debe permitir el acceso de esta aplicación a su lista de contactos.", @"AlertView")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef error = nil;
        ABRecordRef newPerson = ABPersonCreate();
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, @"a menjar!", &error);
        //Phone
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, @"931760651", kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
        CFRelease(multiPhone);
        ABMutableMultiValueRef phoneNumberMultiValue =  ABMultiValueCreateMutableCopy (ABRecordCopyValue(newPerson, kABPersonPhoneProperty));
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"0034672129317",  kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
        //Mail
        ABMutableMultiValueRef addr = ABMultiValueCreateMutable(kABStringPropertyType);
        ABMultiValueAddValueAndLabel(addr, @"info@amenjar.com",kABWorkLabel, nil);
        ABRecordSetValue(newPerson, kABPersonEmailProperty, addr, nil);
        CFRelease(addr);
        //URL
        ABMutableMultiValueRef web = ABMultiValueCreateMutable(kABStringPropertyType);
        ABMultiValueAddValueAndLabel(web, @"www.amenjar.com",kABWorkLabel, nil);
        ABRecordSetValue(newPerson, kABPersonURLProperty, web, nil);
        CFRelease(web);
        //Social
        ABMultiValueRef social = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        ABMultiValueAddValueAndLabel(social, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                   (NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey,
                                                                   @"amenjar", kABPersonSocialProfileUsernameKey,
                                                                   nil]), kABPersonSocialProfileServiceTwitter, NULL);
        ABMultiValueAddValueAndLabel(social, (__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                   (NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey,
                                                                   @"295540453790784", kABPersonSocialProfileUsernameKey,
                                                                   nil]), kABPersonSocialProfileServiceFacebook, NULL);
        ABRecordSetValue(newPerson, kABPersonSocialProfileProperty, social, NULL);
        CFRelease(social);
        //Image
        NSData * dataRef = UIImagePNGRepresentation([UIImage imageNamed:@"logoAM"]);
        ABPersonSetImageData(newPerson, (__bridge CFDataRef)dataRef, nil);
        //Direccion
        ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
        [addressDict setObject:@"Calle Sancho de Ávila 173" forKey:(NSString *)kABPersonAddressStreetKey];
        [addressDict setObject:@"08018" forKey:(NSString *)kABPersonAddressZIPKey];
        [addressDict setObject:@"Barcelona" forKey:(NSString *)kABPersonAddressCityKey];
        ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonAddressProperty, address, &error);
        CFRelease(address);
        //Add person to addressbook
        ABAddressBookAddRecord(addressBookRef, newPerson, &error);
        ABAddressBookSave(addressBookRef, &error);
        CFRelease(newPerson);
        CFRelease(addressBookRef);
        if (error != NULL)
        {
            CFStringRef errorDesc = CFErrorCopyDescription(error);
            NSLog(@"Contact not saved: %@", errorDesc);
            CFRelease(errorDesc);
        }
        [self.tableView reloadData];
    }
    else {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"No se ha podido añadir el contacto!"
                                          message:@"Debe permitir el acceso de esta aplicación a su lista de contactos."
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
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            //show alertview
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No se ha podido añadir el contacto!", @"AlertView")
                                                                message:NSLocalizedString(@"Debe permitir el acceso de esta aplicación a su lista de contactos.", @"AlertView")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

-(void)Copyrights:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"copyrightSegue" sender:self];
}

-(void)QRPedido:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"segueQRConfig" sender:self];
}

-(void)Historial:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"segueHistorial" sender:self];
}

-(void)AlarmaPedido:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"segueAlarma" sender:self];
}

-(void)PassbookPedido:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"seguePassbook" sender:self];
}

-(void)iBeaconConfig:(UITapGestureRecognizer *)onetap
{
    [self performSegueWithIdentifier:@"iBeaconSegue" sender:self];
}

- (IBAction)unwindToInfo:(UIStoryboardSegue *)segue { }

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 1) return 1;
    if (section == 2) {
        NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hola;"];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])  return 4;
        return 3;
    }
    if (section == 3) return 3;
    if (section == 4) return 5;
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 95;
    if (indexPath.section == 1) return 90;
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    if(section == 0) myLabel.frame = CGRectMake(20, 30, 320, 20);
    else myLabel.frame = CGRectMake(20, 15, 320, 20);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        static NSString *CellIdentifier = @"CellWeather";
        AMTiempoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        if(self.logo != nil)  cell.logo.image = self.logo;
        if(![self.temp isEqualToNumber:[NSNumber numberWithDouble:DBL_MIN]]) {
            cell.temperatura.text = [NSString stringWithFormat:@"%d",[self.temp intValue]];
        }
        if(![self.max isEqualToNumber:[NSNumber numberWithDouble:DBL_MAX]]) {
            cell.maximo.text = [NSString stringWithFormat:@"%d",[self.max intValue]];
        }
        if(![self.min isEqualToNumber:[NSNumber numberWithDouble:DBL_MIN]]) {
            cell.minimo.text = [NSString stringWithFormat:@"%d",[self.min intValue]];
        }
        if (![self.tipo isEqualToString:@""]) {
            cell.tipo.text = self.tipo;
            cell.tipo.adjustsFontSizeToFitWidth = YES;
        }
        if(self.visible) {
            [cell startRotation];
        }
        else {
            [cell stopRotation];
        }
        cell.padre = self;
        cell.fondo.image = [UIImage imageNamed:@"fondoTiempo"];
        return cell;
    }
    if(indexPath.section == 1) {
        static NSString *CellIdentifier = @"CellHorarios";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    else {
        if(indexPath.section == 2) {
            if(indexPath.row == 0) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"mail"];
                cell.texto.text = @"Contacto via e-mail";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Mail:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            if(indexPath.row == 1) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"telefono"];
                cell.texto.text = @"931760651";
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell setUserInteractionEnabled:NO];
                }
                else
                {
                    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Telefono:)];
                    tapGestureRecognizer.numberOfTapsRequired = 1;
                    tapGestureRecognizer.numberOfTouchesRequired = 1;
                    cell.tag = indexPath.row;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [cell addGestureRecognizer:tapGestureRecognizer];

                }
                return cell;
            }
            if(indexPath.row == 3) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"whatsapp"];
                cell.texto.text = @"Contactar por whats app";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Whatsapp:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            else {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"add"];
                cell.texto.text = @"Añadir a la lista de contactos";
                BOOL tro = true;
                CFErrorRef err = nil;
                ABAddressBookRef adbk = ABAddressBookCreateWithOptions(nil, &err);
                if (nil == adbk) NSLog(@"error: %@", err);
                CFArrayRef snides = ABAddressBookCopyPeopleWithName(adbk, (CFStringRef)@"a menjar!");
                if (CFArrayGetCount(snides) < 1) tro = false;
                if (tro) {
                    cell.texto.text = @"Contacto ya existente";
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [cell setUserInteractionEnabled:NO];
                }
                else {
                    [cell setUserInteractionEnabled:YES];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AddToBook:)];
                    tapGestureRecognizer.numberOfTapsRequired = 1;
                    tapGestureRecognizer.numberOfTouchesRequired = 1;
                    cell.tag = indexPath.row;
                    [cell addGestureRecognizer:tapGestureRecognizer];
                }
                return cell;
            }
        }
        if(indexPath.section == 3) {
            if(indexPath.row == 0) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"facebook"];
                cell.texto.text = @"Síguenos en Facebook";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Facebook:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            if(indexPath.row == 1) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"twitter"];
                cell.texto.text = @"Síguenos en Twitter";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Twitter:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            if(indexPath.row == 2) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"yelp"];
                cell.texto.text = @"Perfil de Yelp";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Yelp:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
        }
        if (indexPath.section == 4){
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"registro"];
                cell.texto.text = @"Historial de pedidos";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Historial:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            else if (indexPath.row == 1){
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"qrcode"];
                cell.texto.text = @"Código QR";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(QRPedido:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            else if (indexPath.row == 2) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"alarma"];
                cell.texto.text = @"Configuración de la alarma";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AlarmaPedido:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            else if (indexPath.row == 3) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"passbook"];
                cell.texto.text = @"Configuración de Passbook";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PassbookPedido:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
            else if (indexPath.row == 4) {
                static NSString *CellIdentifier = @"CellContacto";
                AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.logo.image = [UIImage imageNamed:@"iBeacon"];
                cell.texto.text = @"Configuración de los iBeacons";
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iBeaconConfig:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                tapGestureRecognizer.numberOfTouchesRequired = 1;
                cell.tag = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell addGestureRecognizer:tapGestureRecognizer];
                return cell;
            }
        }
    }
    static NSString *CellIdentifier = @"CellContacto";
    AMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.logo.image = [UIImage imageNamed:@"copyright.png"];
    cell.texto.text = @"Copyrights e información";
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Copyrights:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    cell.tag = indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell addGestureRecognizer:tapGestureRecognizer];
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *URLString = @"tel://931760651";
        NSURL *URL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end