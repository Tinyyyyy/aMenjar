//
//  AMPedido5.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 03/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMPedido5.h"
#import "SevenSwitch.h"
#import "AMMenuDelDiaViewController.h"

@interface AMPedido5()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property NSArray *listaBebidas;

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UITextField *labelScreen;
@property NSDate *minDate;

@end

@implementation AMPedido5

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    
    SevenSwitch *mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch2.offImage = [UIImage imageNamed:@"cross"];
    mySwitch2.onImage = [UIImage imageNamed:@"check"];
    mySwitch2.onTintColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    mySwitch2.isRounded = NO;
    [self.switchView addSubview:mySwitch2];
    [mySwitch2 setOn:YES animated:YES];
    ant.menu.llevar = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    ant.menu.bebida = @"SIN BEBIDA";
    
    [self.nombre setDelegate:self];
    [self.nombre setReturnKeyType:UIReturnKeyDone];
    
    UIColor *color = [UIColor lightGrayColor];
    self.nombre.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nombre" attributes:@{NSForegroundColorAttributeName: color}];
    
    [self.nombre addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    self.listaBebidas = [[NSArray alloc] initWithObjects:@"SIN BEBIDA",@"Coca-Cola",@"Coca-Cola Zero",@"Coca-Cola Light",@"Schweppes Limón",@"Schweppes Naranja",@"Trina naranja",@"Sprite",@"Agua",@"Agua con gas",@"Cerveza",@"Cerveza sin alcohol",@"Zumo de Piña",@"Zumo de Melocotón", nil];
    [self.bebida setDataSource:self];
    [self.bebida setDelegate:self];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    [components setHour:16];
    [components setMinute:30];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *maxDate = [cal dateFromComponents:components];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    [components setHour:13];
    [components setMinute:0];
    NSCalendar *cale = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.minDate = [cale dateFromComponents:components];
    
    NSTimeInterval interval = [maxDate timeIntervalSinceDate:self.minDate];
    
    [self.slider setMaximumValue:interval];
    [self.slider setMinimumValue:0.0f];
    [self.slider setValue:(interval/2.0)];
    
    double valor = (double)(self.slider.value);
    
    NSDate *date = [NSDate dateWithTimeInterval:valor sinceDate:self.minDate];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    ant.menu.hora = (int)hour;
    ant.menu.minuto = (int)minute;
    ant.menu.llevar = YES;
    ant.menu.cubiertos = NO;
    self.labelScreen.text = [NSString stringWithFormat:@"%d:%d",(int)hour,(int)minute];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Horario de recogida"
                                                    message:@"El horario de recogida es de 13:00 a 16:30"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)switchChanged:(SevenSwitch *)sender {
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    ant.menu.llevar = !ant.menu.llevar;
}

- (IBAction)sliderChanged:(id)sender {
    double valor = (double)(self.slider.value);
    
    NSDate *date = [NSDate dateWithTimeInterval:valor sinceDate:self.minDate];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    ant.menu.hora = (int)hour;
    ant.menu.minuto = (int)minute;
    
    if (minute < 10) self.labelScreen.text = [NSString stringWithFormat:@"%d:0%d",(int)hour,(int)minute];
    else self.labelScreen.text = [NSString stringWithFormat:@"%d:%d",(int)hour,(int)minute];
    
}

- (IBAction)textFieldFinished:(id)sender {
    UITextField *field = (UITextField *)sender;
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    if (ant.menu == nil) ant.menu = [[AMMenu alloc] init];
    ant.menu.nombre = field.text;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.listaBebidas count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.listaBebidas objectAtIndex:row];
    
}

- (IBAction)mail:(id)sender {
    if ([self.nombre.text isEqualToString:@""]) {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"ERROR"
                                          message:@"Debe introducir un nombre para el menú."
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:@"Debe introducir un nombre para el menú."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
        ant.menu.nombre = self.nombre.text;
        if ([self cubiertosIncl]) {
            ant.menu.cubiertos = YES;
            AMMenudeldiaiPadViewController *dest = (AMMenudeldiaiPadViewController *)self.anterior;
            [dest mailing];
            return;
        }
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Cubiertos para llevar"
                                          message:@"Su menú no incluye cubiertos para llevar quiere añadirlos? (+0.20€)"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* no = [UIAlertAction
                                 actionWithTitle:@"NO"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
                                     ant.menu.cubiertos = NO;
                                     //Do some thing here
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     AMMenudeldiaiPadViewController *dest = (AMMenudeldiaiPadViewController *)self.anterior;
                                     [dest mailing];
                                 }];
            [alert addAction:no]; // add action to uialertcontroller
            
            UIAlertAction* si = [UIAlertAction
                                 actionWithTitle:@"SI"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
                                     ant.menu.cubiertos = YES;
                                     //Do some thing here
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     AMMenudeldiaiPadViewController *dest = (AMMenudeldiaiPadViewController *)self.anterior;
                                     [dest mailing];
                                 }];
            [alert addAction:si]; // add action to uialertcontroller
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            //show alertview
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cubiertos para llevar"
                                                            message:@"Su menú no incluye cubiertos para llevar quiere añadirlos? (+0.20€)"
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@"SI",nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

- (IBAction)canceliPad:(id)sender {
    AMMenudeldiaiPadViewController *dest = (AMMenudeldiaiPadViewController *)self.anterior;
    [dest cancel];
}

-(BOOL)cubiertosIncl
{
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    if (!ant.menu.llevar) return YES;
    if ([ant.menu getPrecio] >= 8.5) return YES;
    return NO;
}

- (IBAction)enviar:(id)sender {
    if ([self.nombre.text isEqualToString:@""]) {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"ERROR"
                                          message:@"Debe introducir un nombre para el menú."
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:@"Debe introducir un nombre para el menú."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    ant.menu.nombre = self.nombre.text;
    if ([self cubiertosIncl]) {
        ant.menu.cubiertos = YES;
        [self performSegueWithIdentifier:@"unwindToSendMail" sender:self];
        return;
    }
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Cubiertos para llevar"
                                      message:@"Su menú no incluye cubiertos para llevar quiere añadirlos? (+0.20€)"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* no = [UIAlertAction
                             actionWithTitle:@"NO"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
                                 ant.menu.cubiertos = NO;
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self performSegueWithIdentifier:@"unwindToSendMail" sender:self];
                             }];
        [alert addAction:no]; // add action to uialertcontroller
        
        UIAlertAction* si = [UIAlertAction
                             actionWithTitle:@"SI"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
                                 ant.menu.cubiertos = YES;
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self performSegueWithIdentifier:@"unwindToSendMail" sender:self];
                             }];
        [alert addAction:si]; // add action to uialertcontroller
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        //show alertview
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cubiertos para llevar"
                                                        message:@"Su menú no incluye cubiertos para llevar quiere añadirlos? (+0.20€)"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"SI",nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            AMMenudeldiaiPadViewController *ant = (AMMenudeldiaiPadViewController *)self.anterior;
            ant.menu.cubiertos = NO;
        }
        else {
            AMMenudeldiaiPadViewController *ant = (AMMenudeldiaiPadViewController *)self.anterior;
            ant.menu.cubiertos = YES;
        }
        AMMenudeldiaiPadViewController *dest = (AMMenudeldiaiPadViewController *)self.anterior;
        [dest mailing];
    }
    else {
        if (buttonIndex == 0) {
            AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
            ant.menu.cubiertos = NO;
        }
        else {
            AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
            ant.menu.cubiertos = YES;
        }
        [self performSegueWithIdentifier:@"unwindToSendMail" sender:self];
    }
}

- (IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindToNothinginMenu" sender:self];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AMMenuDelDiaViewController *ant = (AMMenuDelDiaViewController *)self.anterior;
    ant.menu.bebida = [self.listaBebidas objectAtIndex:row];
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.listaBebidas objectAtIndex:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

@end