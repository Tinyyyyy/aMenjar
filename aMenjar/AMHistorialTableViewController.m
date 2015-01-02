//
//  AMHistorialTableViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 07/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMHistorialTableViewController.h"
#import "AMRegistroTableViewCell.h"
#import "AMRegistro.h"

@interface AMHistorialTableViewController ()

@property NSMutableArray *registro;
@property int contador;

@end

@implementation AMHistorialTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadInitialData];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadInitialData {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:@"arraySaveAmenjarPedidos"];
    if (savedArray != nil) {
        NSArray *oldArray = [NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
        if (oldArray != nil) {
            self.registro = [[NSMutableArray alloc] initWithArray:oldArray];
        } else {
            self.registro = [[NSMutableArray alloc] init];
            [self.registro addObject:[[NSMutableArray alloc] init]];
            [self.registro addObject:[[NSMutableArray alloc] init]];
            [self.registro addObject:[[NSMutableArray alloc] init]];
            [self.registro addObject:[[NSMutableArray alloc] init]];
        }
    }
    else {
        self.registro = [[NSMutableArray alloc] init];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.contador = 1;
    bool borrar = NO;
    for(int i = 0; i < [self.registro count]; ++i) {
        NSArray *vec = [self.registro objectAtIndex:i];
        if([vec count] > 0) {
            ++self.contador;
            borrar = YES;
        }
    }
    if(borrar) ++self.contador;
    return self.contador;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 90;
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0 || section == (self.contador -1)) return @"";
    for(int i = 0; i < [self.registro count]; ++i) {
        NSArray *vec = [self.registro objectAtIndex:i];
        if([vec count] > 0 && (section-1) <= i) {
            if(i == 0) return @"Primeros";
            else if(i == 1) return @"Segundos";
            else if(i == 2) return @"Postres";
            else if(i == 3) return @"Bebida";
        }
    }
    return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *myLabel = [[UILabel alloc] init];
    if(section == 0) myLabel.frame = CGRectMake(20, 30, 320, 20);
    else myLabel.frame = CGRectMake(20, 15, 320, 20);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == (self.contador -1)) return 1;
    NSArray *listaref;
    bool tro = NO;
    for(int i = 0; i < [self.registro count] && !tro; ++i) {
        NSArray *vec = [self.registro objectAtIndex:i];
        if([vec count] > 0 && (section-1) <= i) {
            listaref = [self.registro objectAtIndex:i];
            tro = YES;
        }
    }
    return ([listaref count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        static NSString *CellIdentifier = @"cellDescripcionRegistro";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    if(indexPath.section == (self.contador -1)) {
        static NSString *CellIdentifier = @"cellBorrarHistorial";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Borrar:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        cell.tag = indexPath.row;
        [cell addGestureRecognizer:tapGestureRecognizer];
        return cell;
    }
    NSArray *listaref;
    bool tro = NO;
    UIImage *imagenLogo;
    for(int i = 0; i < [self.registro count] && !tro; ++i) {
        NSArray *vec = [self.registro objectAtIndex:i];
        if([vec count] > 0 && (indexPath.section-1) <= i) {
            listaref = [self.registro objectAtIndex:i];
            tro = YES;
            if(i == 0) imagenLogo = [UIImage imageNamed:@"primeros"];
            else if(i == 1) imagenLogo = [UIImage imageNamed:@"segundos"];
            else if(i == 2) imagenLogo = [UIImage imageNamed:@"postre"];
            else if(i == 3) imagenLogo = [UIImage imageNamed:@"bebida"];
        }
    }
    static NSString *CellIdentifier = @"cellRegistroElemento";
    AMRegistroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    AMRegistro *elemento = [listaref objectAtIndex:indexPath.row];
    [cell.plato setNumberOfLines:0];
    cell.plato.text = elemento.elemento;
    cell.repe.text = [NSString stringWithFormat:@"%d", (int)[elemento.veces integerValue]];
    cell.logo.image = imagenLogo;
    [cell setUserInteractionEnabled:NO];
    return cell;
}

-(void)Borrar:(UITapGestureRecognizer *)onetap
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Borrar el historial", @"AlertView")
                                                        message:NSLocalizedString(@"Está seguro de que quiere borrar el historial de platos pedidos?", @"AlertView")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"SI", @"AlertView")
                                              otherButtonTitles:NSLocalizedString(@"NO", @"AlertView"), nil];
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.registro = [[NSMutableArray alloc] init];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [self.registro addObject:[[NSMutableArray alloc] init]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.registro] forKey:@"arraySaveAmenjarPedidos"];
        [self.tableView reloadData];
    }
    else { }
}

@end