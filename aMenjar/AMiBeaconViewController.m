//
//  AMiBeaconViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 17/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMiBeaconViewController.h"
#import "SevenSwitch.h"

@interface AMiBeaconViewController ()


@property (weak, nonatomic) IBOutlet UIView *switchView;
@property BOOL ibeaconPermitido;

@end

@implementation AMiBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ibeaconPermitido = [self whantsiBeacon];
    SevenSwitch *mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch2.offImage = [UIImage imageNamed:@"cross"];
    mySwitch2.onImage = [UIImage imageNamed:@"check"];
    mySwitch2.onTintColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    mySwitch2.isRounded = NO;
    [self.switchView addSubview:mySwitch2];
    [mySwitch2 setOn:self.ibeaconPermitido animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)switchChanged:(SevenSwitch *)sender {
    self.ibeaconPermitido = !self.ibeaconPermitido;
    [[NSUserDefaults standardUserDefaults] setBool:self.ibeaconPermitido forKey:@"iBeaconBoolKey"];
}

- (IBAction)exit:(id)sender {
    [self.anterior exit];
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

@end
