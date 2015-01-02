//
//  ViewController.m
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import <PassSlot/PassSlot.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *test;

@end

@implementation MainViewController

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _sidebarButton.image = [UIImage imageNamed:@"menu"];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // Ad AM logo image
    UIImage *image = [UIImage imageNamed:@"logoredAM"];
    
    CGRect frameV = self.view.frame;
    frameV.origin.x = 111.0f;
    frameV.origin.y = ((self.view.frame.size.height)-(100.0f+5.0f));
    if (IS_IPHONE5) {
        frameV.origin.y = ((self.view.frame.size.height)-(100.0f+50.0f));
    }
    frameV.size.height = 100.0f;
    frameV.size.width = 100.0f;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frameV];
    [iv setImage:image];
    [self.view addSubview:iv];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    BOOL alarmaPermitida;
    NSUserDefaults *NonVolatile = [NSUserDefaults standardUserDefaults];
    alarmaPermitida = [NonVolatile integerForKey:@"MostrarMenuAmenjar"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MostrarMenuAmenjar"];
    if(alarmaPermitida) {
        [self.revealViewController revealToggleAnimated:YES];
        [self.revealViewController.rearViewController performSegueWithIdentifier:@"menuDelDia" sender:self.revealViewController.rearViewController];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
