//
//  SidebarViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 07/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController {
    NSArray *menuItems;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    menuItems = @[@"Nosotros", @"Menú del día", @"Menú Gol", @"Mapa",@"Información"];
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *tokenString = [dev name];

    if ([tokenString isEqualToString:@"iPhone 6 de Mauro Vime"]) {
        menuItems = @[@"Nosotros", @"Menú del día", @"Menú Gol", @"Mapa",@"Información",@"Notificaciones"];
    }
    else if ([tokenString isEqualToString:@"iPhone de Javier Vime"]) {
        menuItems = @[@"Nosotros", @"Menú del día", @"Menú Gol", @"Mapa",@"Información",@"Notificaciones"];
    }
    else if ([tokenString isEqualToString:@"iPhone de Jimena Castillo"]) {
        menuItems = @[@"Nosotros", @"Menú del día", @"Menú Gol", @"Mapa",@"Información",@"Notificaciones"];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:(29.0f/255.0f) green:(29.0f/255.0f) blue:(27.0f/255.0f) alpha:1.0f];
    
    // Ad AM logo image
    UIImage *image = [UIImage imageNamed:@"cabecera"];
    
    CGRect frameV = self.view.frame;
    frameV.origin.x = 0.0f;
    frameV.origin.y = -20.0f;
    
    frameV.size.height = 70.0f;
    frameV.size.width = 300.0f;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frameV];
    [iv setImage:image];
    [headerView addSubview:iv];
    
    return headerView;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"a menjar!";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

@end
