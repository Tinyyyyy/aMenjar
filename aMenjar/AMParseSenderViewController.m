//
//  AMParseSenderViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 06/05/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMParseSenderViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface AMParseSenderViewController () <UITextViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITextView *notificacion;
@property (weak, nonatomic) IBOutlet UILabel *numLeft;
@property (weak, nonatomic) IBOutlet UITextView *notiShow;
@property int veces;

@end

@implementation AMParseSenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.veces = 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int dia = (int)[comps weekday];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    int diaR = (int)[components day];
    int mes = (int)[components month];
    int ano = (int)[components year];
    
    NSString *noti = [NSString stringWithFormat:@"%02d/%02d/%02d: Feliz ",diaR,mes,ano];
    
    if (dia == 1) {
        noti = [noti stringByAppendingString:@"Domingo!"];
    }
    else if (dia == 2) {
        noti = [noti stringByAppendingString:@"Lunes!"];
    }
    else if (dia == 3) {
        noti = [noti stringByAppendingString:@"Martes!"];
    }
    else if (dia == 4) {
        noti = [noti stringByAppendingString:@"Miércoles!"];
    }
    else if (dia == 5) {
        noti = [noti stringByAppendingString:@"Jueves!"];
    }
    else if (dia == 6) {
        noti = [noti stringByAppendingString:@"Viernes!"];
    }
    else if (dia == 7) {
        noti = [noti stringByAppendingString:@"Sábado!"];
    }
    
    noti = [noti stringByAppendingString:@" Ya tienes actualizado el menú del día!"];
    
    [self.notificacion setText:noti];
    
    [self.numLeft setText:[NSString stringWithFormat:@"%d",(int)(224 - ([self.notificacion.text length]))]];
    if((int)(224 - ([self.notificacion.text length])) < 0) {
        [self.numLeft setTextColor:[UIColor redColor]];
    }
    
    [self.notificacion setDelegate:self];
    //[self.notificacion becomeFirstResponder];
    [self.notificacion setReturnKeyType:UIReturnKeyDone];
    [self.notiShow setSelectable:NO];
    [self.notiShow setText:self.notificacion.text];
    [self.notiShow setTextColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.notiShow setText:self.notificacion.text];
    [self.notiShow setTextColor:[UIColor whiteColor]];
    [self.numLeft setText:[NSString stringWithFormat:@"%d",(int)(224 - ([self.notificacion.text length]))]];
    if((int)(224 - ([self.notificacion.text length])) < 0) {
        [self.numLeft setTextColor:[UIColor redColor]];
    }
}

- (IBAction)enviarNoti:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enviar la notificación", @"AlertView")
                                                        message:NSLocalizedString(@"Desea confirmar y enviar la notificación?", @"AlertView")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                              otherButtonTitles:NSLocalizedString(@"Cancelar", @"AlertView"), nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Cargando";
        [HUD showWhileExecuting:@selector(enviar) onTarget:self withObject:nil animated:YES];
    }
}

-(void) enviar
{
    if(self.veces == 0) {
        if((int)(224 - ([self.notificacion.text length])) >= 0) {
            
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
            
            // Send push notification to query
            [PFPush sendPushMessageToQueryInBackground:pushQuery
                                           withMessage:self.notificacion.text];
            
            PFQuery *pushQueryA = [PFInstallation query];
            [pushQueryA whereKey:@"deviceType" equalTo:@"android"];
            
            // Send push notification to query
            [PFPush sendPushMessageToQueryInBackground:pushQueryA
                                           withMessage:self.notificacion.text];
            
            self.veces = 1;
            
            if (nil != NSClassFromString(@"UIAlertController")) {
                //show alertcontroller
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"ENVIADA"
                                              message:@"Notificación enviada"
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ENVIADA"
                                                                message:@"Notificación enviada"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else {
            if (nil != NSClassFromString(@"UIAlertController")) {
                //show alertcontroller
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Demasiado larga"
                                              message:@"Notificación demasiado larga"
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demasiado larga"
                                                                message:@"Notificación demasiado larga"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"NO ENVIADA"
                                          message:@"Acabas de enviar una notificación!!!"
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO ENVIADA"
                                                            message:@"Acabas de enviar una notificación!!!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
