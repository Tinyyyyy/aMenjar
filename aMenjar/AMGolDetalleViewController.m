//
//  AMGolDetalleViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 01/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMGolDetalleViewController.h"
#import "AMGolTest.h"
#import "AMGoliPadViewController.h"
#import "AMGolTableViewCell.h"

@interface AMGolDetalleViewController ()

@end

@implementation AMGolDetalleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizar menú GolTV"];
    [refresh setTintColor:[UIColor whiteColor]];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizando menú..."];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AMGoliPadViewController *papi = (AMGoliPadViewController*) self.padre;
        [papi actualizarDatos];
    }
    else
    {
        AMGolTest *papi = (AMGolTest*) self.padre;
        [papi actualizarDatos2];
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[dateFormatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
    [refresh endRefreshing];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizar menú GolTV"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (int)([self.platos count] / 3);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Menú";
    else if (section == 1) return @"Menú vegetariano";
    return @"Menú vegano";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self.platos count] <= 3) return [self.platos count];
        else return 3;
    }
    else if (section == 1) {
        if ([self.platos count] <= 3) return 0;
        else if ([self.platos count] <= 6) return ([self.platos count] - 3);
        else return 3;
    }
    else {
        if ([self.platos count] <= 6) return 0;
        return ([self.platos count] - 6);
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *myLabel = [[UILabel alloc] init];
    if(section == 0) myLabel.frame = CGRectMake(20, 30, 320, 20);
    else myLabel.frame = CGRectMake(20, 15, 320, 20);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [myLabel setTextColor:[UIColor whiteColor]];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTest";
    AMGolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (indexPath.row == 0) cell.foto.image = [UIImage imageNamed:@"primeros"];
    else if (indexPath.row == 1) cell.foto.image = [UIImage imageNamed:@"segundos"];
    else cell.foto.image = [UIImage imageNamed:@"postre"];
    if (indexPath.section == 0) cell.plato.text = [self.platos objectAtIndex:indexPath.row];
    else if (indexPath.section == 1) cell.plato.text = [self.platos objectAtIndex:(indexPath.row + 3)];
    else cell.plato.text = [self.platos objectAtIndex:(indexPath.row + 6)];

    return cell;
}

@end
