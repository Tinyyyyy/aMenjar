//
//  AMRoutesViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 01/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMRoutesViewController.h"
#import "AMCustomTimeCell.h"

@interface AMRoutesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AMRoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.rutas count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return @"Ruta verde";
    else if(section == 1) return @"Ruta roja";
    return @"Ruta azul";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *myLabel = [[UILabel alloc] init];
    if(section == 0) myLabel.frame = CGRectMake(20, 30, 320, 20);
    else myLabel.frame = CGRectMake(20, 15, 320, 20);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [myLabel setTextColor:[UIColor whiteColor]];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MKRoute *ruta = [self.rutas objectAtIndex:section];
    return ([ruta.steps count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKRoute *ruta = [self.rutas objectAtIndex:indexPath.section];
    if ((indexPath.section == 0) && (indexPath.row == [ruta.steps count])) {
        static NSString *CellIdentifier = @"TimeCell";
        AMCustomTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSTimeInterval tiempo = ruta.expectedTravelTime;
        double minutos = tiempo/60;
        cell.time.text = [NSString stringWithFormat:@"%.2f",minutos];
        [cell.time setTextColor:[UIColor colorWithRed:(43.0f/255.0f) green:(121.0f/255.0f) blue:(28.0f/255.0f) alpha:1.0f]];
        return cell;
    }
    else if ((indexPath.section == 1) && (indexPath.row == [ruta.steps count])) {
        static NSString *CellIdentifier = @"TimeCell";
        AMCustomTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSTimeInterval tiempo = ruta.expectedTravelTime;
        double minutos = tiempo/60;
        cell.time.text = [NSString stringWithFormat:@"%.2f",minutos];
        [cell.time setTextColor:[UIColor redColor]];
        [cell.time setAdjustsFontSizeToFitWidth:YES];
        return cell;
    }
    else if ((indexPath.section == 2) && (indexPath.row == [ruta.steps count])) {
        static NSString *CellIdentifier = @"TimeCell";
        AMCustomTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSTimeInterval tiempo = ruta.expectedTravelTime;
        double minutos = tiempo/60;
        cell.time.text = [NSString stringWithFormat:@"%.2f",minutos];
        [cell.time setTextColor:[UIColor blueColor]];
        [cell.time setAdjustsFontSizeToFitWidth:YES];
        return cell;
    }
    static NSString *CellIdentifier = @"DirectionsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MKRouteStep *step = [[MKRouteStep alloc] init];
    step = [ruta.steps objectAtIndex:indexPath.row];
    cell.textLabel.text = step.instructions;
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]];
    [cell.textLabel setNumberOfLines:0];
    [cell setBackgroundColor:[UIColor blackColor]];
    return cell;
}

@end
