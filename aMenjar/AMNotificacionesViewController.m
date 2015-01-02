//
//  AMNotificacionesViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 06/05/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMNotificacionesViewController.h"
#import "SWRevealViewController.h"

@interface AMNotificacionesViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *diguno;
@property (weak, nonatomic) IBOutlet UIImageView *imagenes;
@property (weak, nonatomic) IBOutlet UIImageView *imagenes2;
@property (weak, nonatomic) IBOutlet UIImageView *imag3;
@property (weak, nonatomic) IBOutlet UIImageView *imag4;
@property (weak, nonatomic) IBOutlet UILabel *labelEstado;
@property int paso;

@end

@implementation AMNotificacionesViewController

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
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _sidebarButton.image = [UIImage imageNamed:@"menu"];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.diguno addTarget:self action:@selector(textFieldUno:) forControlEvents:UIControlEventEditingChanged];
    
    [self.diguno becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self clearPass];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"HOLA");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)textFieldUno:(id)sender {
    int len = (int)[self.diguno.text length];
    if(len == 0) {
        [self.imagenes setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imagenes2 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imag3 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imag4 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        self.paso = 0;
    }
    else if (len == 1) {
        [self.imagenes setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imagenes2 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imag3 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        
        [self.imag4 setImage:[UIImage imageNamed:@"redondaR.png"]];
        if(self.paso == (len-1)) {
            CGRect frameB = self.imag4.frame;
            frameB.size.height = 10.0f;
            frameB.size.width = 10.0f;
            frameB.origin.x = 98.0f;
            frameB.origin.y = 220.5f;
            [self.imag4 setFrame:frameB];
            [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frameB = self.imag4.frame;
                             frameB.size.height = 30.0f;
                             frameB.size.width = 30.0f;
                             frameB.origin.x = 88.0f;
                             frameB.origin.y = 210.5f;
                             [self.imag4 setFrame:frameB];
                         }
                         completion:^(BOOL finished){
                             ;
                         }];
        }
        self.paso = 1;
    }
    else if (len == 2) {
        [self.imagenes setImage:[UIImage imageNamed:@"redondaNO.png"]];
        [self.imagenes2 setImage:[UIImage imageNamed:@"redondaNO.png"]];
        
        [self.imag3 setImage:[UIImage imageNamed:@"redondaG.png"]];
        if(self.paso == (len-1)) {
            CGRect frameB = self.imag3.frame;
            frameB.size.height = 10.0f;
            frameB.size.width = 10.0f;
            frameB.origin.x = 136.0f;
            frameB.origin.y = 220.5f;
            [self.imag3 setFrame:frameB];
            [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frameB = self.imag3.frame;
                             frameB.size.height = 30.0f;
                             frameB.size.width = 30.0f;
                             frameB.origin.x = 126.0f;
                             frameB.origin.y = 210.5f;
                             [self.imag3 setFrame:frameB];
                         }
                         completion:^(BOOL finished){
                             ;
                         }];
        }
    
        [self.imag4 setImage:[UIImage imageNamed:@"redondaR.png"]];
        self.paso = 2;
    }
    else if (len == 3) {
        [self.imagenes setImage:[UIImage imageNamed:@"redondaNO.png"]];
        
        [self.imagenes2 setImage:[UIImage imageNamed:@"redondaB.png"]];
        
        if(self.paso == (len-1)) {
            CGRect frameB = self.imagenes2.frame;
            frameB.size.height = 10.0f;
            frameB.size.width = 10.0f;
            frameB.origin.x = 174.0f;
            frameB.origin.y = 220.5f;
            [self.imagenes2 setFrame:frameB];
            [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frameB = self.imagenes2.frame;
                             frameB.size.height = 30.0f;
                             frameB.size.width = 30.0f;
                             frameB.origin.x = 164.0f;
                             frameB.origin.y = 210.5f;
                             [self.imagenes2 setFrame:frameB];
                         }
                         completion:^(BOOL finished){
                             ;
                         }];
        }
        
        [self.imag3 setImage:[UIImage imageNamed:@"redondaG.png"]];
        [self.imag4 setImage:[UIImage imageNamed:@"redondaR.png"]];
        [self.labelEstado setText:@"Introduce la contraseña para acceder a esta sección de la app"];
        [self.labelEstado setTextColor:[UIColor blackColor]];
        
        self.paso = 3;
    }
    else if (len == 4) {
        
        [self.imagenes setImage:[UIImage imageNamed:@"redondaY.png"]];
        
        if(self.paso == (len-1)) {
            CGRect frameB = self.imagenes.frame;
            frameB.size.height = 10.0f;
            frameB.size.width = 10.0f;
            frameB.origin.x = 212.0f;
            frameB.origin.y = 220.5f;
            [self.imagenes setFrame:frameB];
            [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frameB = self.imagenes.frame;
                             frameB.size.height = 30.0f;
                             frameB.size.width = 30.0f;
                             frameB.origin.x = 202.0f;
                             frameB.origin.y = 210.5f;
                             [self.imagenes setFrame:frameB];
                         }
                         completion:^(BOOL finished){
                             ;
                         }];
        }
        
        [self.imagenes2 setImage:[UIImage imageNamed:@"redondaB.png"]];
        [self.imag3 setImage:[UIImage imageNamed:@"redondaG.png"]];
        [self.imag4 setImage:[UIImage imageNamed:@"redondaR.png"]];
        [self check];
        
        self.paso = 4;
    }
}

-(void)check
{
    if([self.diguno.text isEqualToString:@"9720"]) {
        [self performSegueWithIdentifier:@"segueNoti" sender:self];
    }
    else {
        [self.labelEstado setText:@"ERROR\nLa contraseña no es correcta!"];
        [self.labelEstado setTextColor:[UIColor redColor]];
    }
}

- (IBAction)focalizar:(id)sender {
    [self.diguno setEnabled:YES];
    [self.diguno becomeFirstResponder];
}

-(void)clearPass
{
    [self.diguno setEnabled:YES];
    
    [self.diguno setText:@""];
    
    [self.imagenes setImage:[UIImage imageNamed:@"redondaNO.png"]];
    [self.imagenes2 setImage:[UIImage imageNamed:@"redondaNO.png"]];
    [self.imag3 setImage:[UIImage imageNamed:@"redondaNO.png"]];
    [self.imag4 setImage:[UIImage imageNamed:@"redondaNO.png"]];
    
    [self.labelEstado setText:@"Introduce la contraseña para acceder a esta sección de la app"];
    [self.labelEstado setTextColor:[UIColor blackColor]];
    
    [self.diguno becomeFirstResponder];
    
    self.paso = 0;
}

- (IBAction)unwindToNothingNoti:(UIStoryboardSegue *)segue{
}

@end
