//
//  AMGoltest.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 02/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMGolTest.h"
#import "AMGolParser.h"
#import "AMGolDetalleViewController.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"

@interface AMGolTest () <NSXMLParserDelegate,MBProgressHUDDelegate>

@property int sender;
@property (weak, nonatomic) IBOutlet UIView *contenedor;
@property AMGolDetalleViewController *editVC;

@property (weak, nonatomic) IBOutlet UIButton *botonMed;

@property (weak, nonatomic) IBOutlet UIButton *botonNoche;

@property BOOL mediodiaB;
@property BOOL reload;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation AMGolTest



-(void)viewDidLoad
{
    self.reload = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _sidebarButton.image = [UIImage imageNamed:@"menu"];
    
    [self.botonMed setTintColor: [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.botonNoche setTintColor:[UIColor grayColor]];
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:@"GolPlatosMediodia"];
    if (savedArray != nil) self.mediodia = [[NSKeyedUnarchiver unarchiveObjectWithData:savedArray] mutableCopy];
    savedArray = [currentDefaults objectForKey:@"GolPlatosNoche"];
    if (savedArray != nil) self.noche = [[NSKeyedUnarchiver unarchiveObjectWithData:savedArray] mutableCopy];
    
    if(([self.mediodia count]+[self.noche count]) < 1) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Cargando";
        [HUD showWhileExecuting:@selector(actualizarDatos) onTarget:self withObject:nil animated:YES];
        self.reload = NO;
    }
    else {
        NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"TituloMenuGol"];
        [self.navigationItem setTitle:savedValue];
    }
}

-(void)actualizarDatos
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    self.mediodiaB = true;
    [self.botonMed setTintColor: [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.botonNoche setTintColor:[UIColor grayColor]];
    NSString *title = @"";
    if ([parser.dia isEqualToString:@"ERROR"]) title = @"SIN CONEXIÓN";
    else {
        title = [[[title stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
        title = [[[title stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
        title = [title stringByAppendingString:parser.ano];
    }
    [self.navigationItem setTitle:title];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    AMGolDetalleViewController *tbc = (AMGolDetalleViewController *)self.childViewControllers[0];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.navigationItem.title forKey:@"TituloMenuGol"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.mediodia] forKey:@"GolPlatosMediodia"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.noche] forKey:@"GolPlatosNoche"];
    
    [tbc.tableView reloadData];
}

- (IBAction)mediodia:(id)sender
{
    self.mediodiaB = true;
    [self.botonMed setTintColor: [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    [self.botonNoche setTintColor:[UIColor grayColor]];
    AMGolDetalleViewController *tbc = (AMGolDetalleViewController *)self.childViewControllers[0];
    tbc.platos = self.mediodia;
    tbc.padre = self;
    [tbc.tableView reloadData];
}

- (IBAction)noche:(id)sender
{
    self.mediodiaB = false;
    [self.botonMed setTintColor:[UIColor grayColor]];
    [self.botonNoche setTintColor:[UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
    AMGolDetalleViewController *tbc = (AMGolDetalleViewController *)self.childViewControllers[0];
    tbc.platos = self.noche;
    tbc.padre = self;
    [tbc.tableView reloadData];
}

-(void)actualizarDatos2
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    NSString *title = @"";
    if ([parser.dia isEqualToString:@"ERROR"]) title = @"SIN CONEXIÓN";
    else {
        title = [[[title stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
        title = [[[title stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
        title = [title stringByAppendingString:parser.ano];
    }
    [self.navigationItem setTitle:title];
    AMGolDetalleViewController *tbc = (AMGolDetalleViewController *)self.childViewControllers[0];
    if(self.mediodiaB) tbc.platos = self.mediodia;
    else tbc.platos = self.noche;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.navigationItem.title forKey:@"TituloMenuGol"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.mediodia] forKey:@"GolPlatosMediodia"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.noche] forKey:@"GolPlatosNoche"];
    
    [tbc.tableView reloadData];
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
}

@end
