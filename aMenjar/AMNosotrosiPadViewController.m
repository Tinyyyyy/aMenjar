//
//  AMNosotrosiPadViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 07/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMNosotrosiPadViewController.h"
#import "AMMenudeldiaiPadViewController.h"

@interface AMNosotrosiPadViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end

@implementation AMNosotrosiPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.logo.image = [UIImage imageNamed:@"lofoiPadAM.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    BOOL alarmaPermitida;
    NSUserDefaults *NonVolatile = [NSUserDefaults standardUserDefaults];
    alarmaPermitida = [NonVolatile integerForKey:@"MostrarMenuAmenjar"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MostrarMenuAmenjar"];
    if(alarmaPermitida) {
        [self.tabBarController setSelectedIndex:1];
        UINavigationController *item = [self.tabBarController.childViewControllers objectAtIndex:1];
        AMMenudeldiaiPadViewController *viewC = [item.childViewControllers objectAtIndex:0];
        viewC.reload = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
