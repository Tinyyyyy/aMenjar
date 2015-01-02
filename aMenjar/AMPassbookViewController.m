//
//  AMPassbookViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 14/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMPassbookViewController.h"
#import "SevenSwitch.h"

@interface AMPassbookViewController ()

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property BOOL passPermitido;

@end

@implementation AMPassbookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passPermitido = [self whantsPass];
    SevenSwitch *mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch2.offImage = [UIImage imageNamed:@"cross"];
    mySwitch2.onImage = [UIImage imageNamed:@"check"];
    mySwitch2.onTintColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    mySwitch2.isRounded = NO;
    [self.switchView addSubview:mySwitch2];
    [mySwitch2 setOn:self.passPermitido animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)switchChanged:(SevenSwitch *)sender {
    self.passPermitido = !self.passPermitido;
    [[NSUserDefaults standardUserDefaults] setBool:self.passPermitido forKey:@"PassbookAddBoolKey"];
}

-(BOOL)whantsPass
{
    BOOL alarmaPermitida;
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"PassbookAddBoolKey"];
    if(data1 == nil){
        alarmaPermitida = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PassbookAddBoolKey"];
    }
    else {
        alarmaPermitida = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"PassbookAddBoolKey"];
    }
    return alarmaPermitida;
}

@end
