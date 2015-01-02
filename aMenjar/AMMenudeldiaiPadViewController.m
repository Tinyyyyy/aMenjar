//
//  AMMenudeldiaiPadViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMMenudeldiaiPadViewController.h"
#import "AMParser.h"
#import "MBProgressHUD.h"
#import "AMRegistro.h"
#import <Parse/Parse.h>
#import "AMPedidoNaviViewController.h"
#import "AMQRPedidoViewController.h"
#import "AMResumenIpadViewController.h"

@interface AMMenudeldiaiPadViewController ()<MFMailComposeViewControllerDelegate,UIAlertViewDelegate,NSXMLParserDelegate,MBProgressHUDDelegate>

@property UIActivityIndicatorView *spinner;
@property AMMenus *menus;
@property NSInteger horaPedido;
@property NSInteger minutosPedido;

@end

@implementation AMMenudeldiaiPadViewController
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.primeros = [[NSMutableArray alloc] init];
    self.segundos = [[NSMutableArray alloc] init];
    self.postres = [[NSMutableArray alloc] init];
    self.menus = [[AMMenus alloc] init];
    self.menu = [[AMMenu alloc] init];
    self.reload = true;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizar menú"];
    [refresh setTintColor:[UIColor whiteColor]];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NUEVOMENUBOOL"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:@"MenudeldiaPrimeros"];
    if (savedArray != nil) self.primeros = [[NSKeyedUnarchiver unarchiveObjectWithData:savedArray] mutableCopy];
    savedArray = [currentDefaults objectForKey:@"MenudeldiaSegundos"];
    if (savedArray != nil) self.segundos = [[NSKeyedUnarchiver unarchiveObjectWithData:savedArray] mutableCopy];
    savedArray = [currentDefaults objectForKey:@"MenudeldiaPostres"];
    if (savedArray != nil) self.postres = [[NSKeyedUnarchiver unarchiveObjectWithData:savedArray] mutableCopy];
    if([self.primeros count] < 1) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Cargando";
        [HUD showWhileExecuting:@selector(actualizarDatos) onTarget:self withObject:nil animated:YES];
        self.reload = NO;
    }
    else {
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"TituloMenudelDia"];
        [self.navigationItem setTitle:savedValue];
        [self.tableView reloadData];
    }
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizando menú..."];
    [self actualizarDatos];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[dateFormatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
    [refresh endRefreshing];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Actualizar menú"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)actualizarDatos
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menu.xml"];
    AMParser *parser = [[AMParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.primeros = [[NSMutableArray alloc] init];
    parser.segundos = [[NSMutableArray alloc] init];
    parser.postres = [[NSMutableArray alloc] init];
    self.festivo = [parser parseDocumentWithURL:url];
    self.primeros = parser.primeros;
    self.segundos = parser.segundos;
    self.postres = parser.postres;
    NSString *titulo = @"";
    if ([parser.dia isEqualToString:@"ERROR"]) titulo = @"SIN CONEXIÓN";
    else {
        titulo = [[[titulo stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
        titulo = [[[titulo stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
        titulo = [titulo stringByAppendingString:parser.ano];
    }
    [self.navigationItem setTitle:titulo];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.navigationItem.title forKey:@"TituloMenudelDia"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.primeros] forKey:@"MenudeldiaPrimeros"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.segundos] forKey:@"MenudeldiaSegundos"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.postres] forKey:@"MenudeldiaPostres"];
    
    [self.tableView reloadData];
}

- (IBAction)reloadXML:(id)sender
{
    self.menu = [[AMMenu alloc] init];
    self.menus = [[AMMenus alloc] init];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Cargando";
    [HUD showWhileExecuting:@selector(actualizarDatos) onTarget:self withObject:nil animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.festivo) return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.festivo) return [self.primeros count];
    if (section == 0) return [self.primeros count];
    else if (section == 1) return [self.segundos count];
    return [self.postres count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *myLabel = [[UILabel alloc] init];
    if(section == 0) myLabel.frame = CGRectMake(15, 30, 320, 20);
    else myLabel.frame = CGRectMake(15, 15, 320, 20);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [myLabel setTextColor:[UIColor whiteColor]];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor blackColor];
    [headerView addSubview:myLabel];
    return headerView;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.festivo) return @"Platos";
    if (section == 0) return @"Primeros";
    else if (section == 1) return @"Segundos";
    return @"Postres";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:16.0f]];
    else [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:13.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    NSString *platoC = @"";
    if(self.festivo) {
        platoC = [self.primeros objectAtIndex:indexPath.row];
        [cell setUserInteractionEnabled:NO];
    }
    else {
        if (indexPath.section == 0) {
            platoC = [self.primeros objectAtIndex:indexPath.row];
            if ([self.menu.primeros containsObject:platoC]) {
                [cell setBackgroundColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [cell setTintColor:[UIColor whiteColor]];
            }
            else {
                [cell setBackgroundColor:[UIColor blackColor]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if (indexPath.section == 1) {
            platoC = [self.segundos objectAtIndex:indexPath.row];
            if ([self.menu.segundos containsObject:platoC]) {
                [cell setBackgroundColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [cell setTintColor:[UIColor whiteColor]];
            }
            else {
                [cell setBackgroundColor:[UIColor blackColor]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else {
            platoC = [self.postres objectAtIndex:indexPath.row];
            if (platoC == self.menu.postre) {
                [cell setBackgroundColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [cell setTintColor:[UIColor whiteColor]];
            }
            else {
                [cell setBackgroundColor:[UIColor blackColor]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [cell.textLabel setNumberOfLines:0];
    cell.textLabel.text = platoC;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.festivo) {
        NSString *tappedItem;
        if(indexPath.section == 0) {
            tappedItem = [self.primeros objectAtIndex:indexPath.row];
            if (![self.menu addDish:tappedItem atPos:1]) {
                if (nil != NSClassFromString(@"UIAlertController")) {
                    //show alertcontroller
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Número de platos máximo"
                                                  message:@"Ya ha seleccionado el número máximo de platos. Por favor deseleccione uno y seleccione el deseado."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    [alert addAction:ok]; // add action to uialertcontroller
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //show alertview
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Número de platos máximo"
                                                                    message:@"Ya ha seleccionado el número máximo de platos. Por favor deseleccione uno y seleccione el deseado."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
        else if (indexPath.section == 1){
            tappedItem = [self.segundos objectAtIndex:indexPath.row];
            if (![self.menu addDish:tappedItem atPos:2]) {
                if (nil != NSClassFromString(@"UIAlertController")) {
                    //show alertcontroller
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Número de platos máximo"
                                                  message:@"Ya ha seleccionado el número máximo de platos. Por favor deseleccione uno y seleccione el deseado."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    [alert addAction:ok]; // add action to uialertcontroller
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //show alertview
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Número de platos máximo"
                                                                    message:@"Ya ha seleccionado el número máximo de platos. Por favor deseleccione uno y seleccione el deseado."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
        else if (indexPath.section == 2) {
            tappedItem = [self.postres objectAtIndex:indexPath.row];
            if (![self.menu addDesert:tappedItem]) {
                if (nil != NSClassFromString(@"UIAlertController")) {
                    //show alertcontroller
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Postre ya seleccionado"
                                                  message:@"Sólo se puede seleccionar un máximo de 1 postre por menú."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    [alert addAction:ok]; // add action to uialertcontroller
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //show alertview
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Postre ya seleccionado"
                                                                    message:@"Sólo se puede seleccionar un máximo de 1 postre por menú."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [tableView reloadData];
}

- (IBAction)pedido:(id)sender
{
    if (!self.festivo) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        if (([self.menu.primeros count] + [self.menu.segundos count]) == 0) {
            if (nil != NSClassFromString(@"UIAlertController")) {
                //show alertcontroller
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Pedido no válido"
                                              message:@"Debe seleccionar como mínimo un primero o un segundo."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //Do some thing here
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
                [alert addAction:ok]; // add action to uialertcontroller
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                //show alertview
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pedido no válido"
                                                                message:@"Debe seleccionar como mínimo un primero o un segundo."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else {
            if (hour > 13) {
                if (nil != NSClassFromString(@"UIAlertController")) {
                    //show alertcontroller
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Hora no aceptada"
                                                  message:@"Sólo se aceptan pedidos hasta las 13:00."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    [alert addAction:ok]; // add action to uialertcontroller
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //show alertview
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hora no aceptada"
                                                                    message:@"Sólo se aceptan pedidos hasta las 13:00."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            else if (hour == 13) {
                if (minute > 0) {
                    if (nil != NSClassFromString(@"UIAlertController")) {
                        //show alertcontroller
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Hora no aceptada"
                                                      message:@"Sólo se aceptan pedidos hasta las 13:00."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 //Do some thing here
                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                 
                                             }];
                        [alert addAction:ok]; // add action to uialertcontroller
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        //show alertview
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hora no aceptada"
                                                                        message:@"Sólo se aceptan pedidos hasta las 13:00."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }
            else {
                [self performSegueWithIdentifier:@"pedido" sender:self];
            }
        }
    }
    else {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Solo días laborables"
                                          message:@"El servicio de pedidos mediante este medio sólo está disponible los días laborables. Para cualquier consulta llame al 931760651."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     //Do some thing here
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            [alert addAction:ok]; // add action to uialertcontroller
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            //show alertview
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Solo días laborables"
                                                            message:@"El servicio de pedidos mediante este medio sólo está disponible los días laborables. Para cualquier consulta llame al 931760651."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)checkMasCompras:(NSTimer*)timer
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Seguir con el pedido"
                                      message:@"Si desea añadir más menús al pedido puede hacerlo, si no se procederá a finalizar el proceso."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Check out"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self.menus addObject:self.menu];
                                 self.menu = [[AMMenu alloc] init];
                                 [self.tableView reloadData];
                                 [self performSegueWithIdentifier:@"segueQR" sender:self];
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        
        UIAlertAction* ok2 = [UIAlertAction
                              actionWithTitle:@"Más menus"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //Do some thing here
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self.menus addObject:self.menu];
                                  self.menu = [[AMMenu alloc] init];
                                  [self.tableView reloadData];
                              }];
        [alert addAction:ok2]; // add action to uialertcontroller
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        //show alertview
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Seguir con el pedido", @"AlertView")
                                                            message:NSLocalizedString(@"Si desea añadir más menús al pedido puede hacerlo, si no se procederá a finalizar el proceso.", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Check out", @"AlertView")
                                                  otherButtonTitles:NSLocalizedString(@"Más menús", @"AlertView"), nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.menus addObject:self.menu];
        self.menu = [[AMMenu alloc] init];
        [self.tableView reloadData];
        [self performSegueWithIdentifier:@"segueQR" sender:self];
    }
    else {
        [self.menus addObject:self.menu];
        self.menu = [[AMMenu alloc] init];
        [self.tableView reloadData];
    }
}

-(void)mailing
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(checkMasCompras:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.menus = [[AMMenus alloc] init];
    self.menu = [[AMMenu alloc] init];
    [self.tableView reloadData];
}


- (IBAction)unwindToNothinginMenu:(UIStoryboardSegue *)segue
{
    self.menu = [[AMMenu alloc] init];
    self.menus = [[AMMenus alloc] init];
    [self.tableView reloadData];
}

- (IBAction)refresh:(id)sender {}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueQR"]) {
        AMResumenIpadViewController *qrVC = segue.destinationViewController;
        qrVC.menus = self.menus;
        qrVC.papi = self;
    }
    if([segue.identifier isEqualToString:@"pedido"]) {
        AMPedido5 *navi = segue.destinationViewController;
        navi.anterior = self;
    }
}

@end