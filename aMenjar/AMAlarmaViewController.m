//
//  AMAlarmaViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 11/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMAlarmaViewController.h"
#import "SevenSwitch.h"

@interface AMAlarmaViewController ()

@property (weak, nonatomic) IBOutlet UISlider *sliderTiempo;
@property BOOL alarmaPermitida;
@property (weak, nonatomic) IBOutlet UILabel *minutosLabel;

@end

@implementation AMAlarmaViewController

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

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmaboolKey"];
    int valor;
    if(data == nil){
        self.alarmaPermitida = YES;
        [[NSUserDefaults standardUserDefaults] setBool:self.alarmaPermitida forKey:@"AlarmaboolKey"];
        valor = 5;
    }
    else {
        self.alarmaPermitida = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"AlarmaboolKey"];
        valor = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmaTime"] intValue];
    }
    
    [self.sliderTiempo setEnabled:self.alarmaPermitida];
    [self.sliderTiempo setValue:(float)valor];
    
    if(self.alarmaPermitida) {
        NSString *value;
        if (valor < 10) {
            value = [NSString stringWithFormat:@"0%d",valor];
        }
        else {
            value = [NSString stringWithFormat:@"%d",valor];
        }
        self.minutosLabel.text = value;
        [self.minutosLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [self.minutosLabel setTextColor:[UIColor lightGrayColor]];
        self.minutosLabel.text = @"00";
    }
    
    [self.sliderTiempo setEnabled:self.alarmaPermitida];
    
    SevenSwitch *mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake(20.0f,267.5f, 65, 30)];
    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch2.offImage = [UIImage imageNamed:@"cross"];
    mySwitch2.onImage = [UIImage imageNamed:@"check"];
    mySwitch2.onTintColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    mySwitch2.isRounded = NO;
    [self.view addSubview:mySwitch2];
    [mySwitch2 setOn:self.alarmaPermitida animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)exit:(id)sender {
    [self.anterior exit];
}

- (void)switchChanged:(SevenSwitch *)sender {
    self.alarmaPermitida = !self.alarmaPermitida;
    if(!self.alarmaPermitida) {
        [self.minutosLabel setTextColor:[UIColor lightGrayColor]];
        self.minutosLabel.text = @"00";
    }
    else {
        int valor = (int)self.sliderTiempo.value;
        NSString *value;
        if (valor < 10) {
            value = [NSString stringWithFormat:@"0%d",valor];
        }
        else {
            value = [NSString stringWithFormat:@"%d",valor];
        }
        self.minutosLabel.text = value;
        [self.minutosLabel setTextColor:[UIColor whiteColor]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:valor] forKey:@"AlarmaTime"];
    }
    [self.sliderTiempo setEnabled:self.alarmaPermitida];
    NSUserDefaults *NonVolatile = [NSUserDefaults standardUserDefaults];
	[NonVolatile setBool:self.alarmaPermitida forKey:@"AlarmaboolKey"];
}

- (IBAction)sliderChanged:(id)sender {
    int valor = (int)self.sliderTiempo.value;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:valor] forKey:@"AlarmaTime"];
    NSString *value;
    if (valor < 10) {
        value = [NSString stringWithFormat:@"0%d",valor];
    }
    else {
        value = [NSString stringWithFormat:@"%d",valor];
    }
    self.minutosLabel.text = value;
}

@end
