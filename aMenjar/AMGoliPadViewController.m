//
//  AMGoliPadViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 03/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMGoliPadViewController.h"
#import "AMGolParser.h"
#import "AMGolDetalleViewController.h"
#import "MBProgressHUD.h"

@interface AMGoliPadViewController () <NSXMLParserDelegate,MBProgressHUDDelegate>

@property int sender;

@property (weak, nonatomic) IBOutlet UIView *contenedor;
@property (weak, nonatomic) IBOutlet UIView *contenedor2;

@property BOOL reload;
@property AMGolDetalleViewController *editVC2;

@property BOOL mediodiaB;

@end

@implementation AMGoliPadViewController



-(void)viewDidLoad
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.reload = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.reload) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Cargando";
        [HUD showWhileExecuting:@selector(actualizarDatos) onTarget:self withObject:nil animated:YES];
        self.reload = NO;
    }
}

-(void)actualizarDatos
{
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    self.mediodiaB = true;
    NSString *title = @"";
    if ([parser.dia isEqualToString:@"ERROR"]) {
        title = @"SIN CONEXIÓN A INTERNET";
    }
    else {
        title = [[[title stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
        title = [[[title stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
        title = [title stringByAppendingString:parser.ano];
    }
    [self.navigationItem setTitle:title];
    AMGolDetalleViewController *tbc = (AMGolDetalleViewController *)self.childViewControllers[0];
    tbc.platos = self.mediodia;
    AMGolDetalleViewController *tbc2 = (AMGolDetalleViewController *)self.childViewControllers[1];
    tbc2.platos = self.noche;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [tbc.tableView reloadData];
    [tbc2.tableView reloadData];
}

- (IBAction)actualizar:(id)sender
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Cargando";
    [HUD showWhileExecuting:@selector(actualizarDatos) onTarget:self withObject:nil animated:YES];
    self.reload = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    if ([segue.identifier isEqualToString:@"embed"])
    {
        AMGolDetalleViewController *detalleVC = segue.destinationViewController;
        detalleVC.platos = self.mediodia;
    }
    if ([segue.identifier isEqualToString:@"embed2"])
    {
        AMGolDetalleViewController *detalleVC = segue.destinationViewController;
        detalleVC.platos = self.noche;
    }
}

@end
