//
//  AMQRPedidoViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 02/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMQRPedidoViewController.h"
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AMGolTableViewCell.h"
#import <Parse/Parse.h>
#import "AMRegistro.h"
#import <PassSlot/PassSlot.h>

@interface AMQRPedidoViewController ()<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,PTKViewDelegate,PKAddPassesViewControllerDelegate>

@property UIImage *QR;
@property NSMutableArray *registro;
@property MBProgressHUD *HUD;
@property UIView *confirm;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cnclBtn;
@property (weak, nonatomic) PTKView *paymentView;
@property UIView *vistaPagos;
@property NSString *emailDestino;
@property NSString *pago;
@property NSString *importePagado;

@end

@implementation AMQRPedidoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self crearQR];
    [self.tablaResumen setDelegate:self];
    [self.tablaResumen setDataSource:self];
    [self.tablaResumen reloadData];
    self.tablaResumen.layer.cornerRadius = 25.0f;
    [self.tablaResumen setClipsToBounds:YES];
    self.vistaBotones.layer.cornerRadius = 25.0f;
    [self.vistaBotones setClipsToBounds:YES];
    self.localBtn.layer.cornerRadius = 5.0f;
    self.stripeBtn.layer.cornerRadius = 5.0f;
    [self loadInitialData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.view sendSubviewToBack:self.vistaBotones];
    
    //[self.vistaBotones removeFromSuperview];

    CGRect f = self.tablaResumen.frame;
    f.origin.x = 321.0f;
    self.tablaResumen.frame = f;
}

-(void)viewDidAppear:(BOOL)animated
{
    [NSTimer scheduledTimerWithTimeInterval:0.001
                                     target:self
                                   selector:@selector(mover:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)mover:(NSTimer*)timer
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect f = self.tablaResumen.frame;
                         f.origin.x = 16.0f;
                         self.tablaResumen.frame = f;
                     }
                     completion:^(BOOL finished){
                         [self.tablaResumen setContentOffset:CGPointMake(0.0f, 20.0f)  animated:YES];
                     }];
}

- (void)loadInitialData
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:@"arraySaveAmenjarPedidos"];
    if (savedArray != nil) {
        NSArray *oldArray = [NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
        if (oldArray != nil) self.registro = [[NSMutableArray alloc] initWithArray:oldArray];
        else {
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
}

-(void)crearQR
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [[self.menus stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationUp];
    UIImage *resized = [self resizeImage:image withQuality:kCGInterpolationNone rate:5.0];
    self.QR = resized;
    [self.tablaResumen reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.email resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self.menus count]);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AMMenu *menu = [self.menus objectAtIndex:section];
    return [menu elementos];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 105.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ((section + 1) == [self.menus count]) return 215.0f;
    return 10.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AMMenu *menu = [self.menus objectAtIndex:section];
    
    UIView *view = [[UIView alloc] initWithFrame:(CGRectMake(0.0f, 0.0f, 288.0f, 105.0f))];
    
    UILabel *nombre = [[UILabel alloc] initWithFrame:(CGRectMake(8.0f, 8.0f, 151.0f, 29.0f))];
    nombre.text = menu.nombre;
    nombre.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    nombre.textColor =[UIColor whiteColor];
    [view addSubview:nombre];
    
    UILabel *hora = [[UILabel alloc] initWithFrame:(CGRectMake(8.0f, 38.0f, 51.0f, 28.0f))];
    if(menu.minuto < 10) {
        hora.text = [NSString stringWithFormat:@"%d:0%d",menu.hora,menu.minuto];
    }
    else {
        hora.text = [NSString stringWithFormat:@"%d:%d",menu.hora,menu.minuto];
    }
    hora.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    hora.textColor =[UIColor whiteColor];
    [view addSubview:hora];
    
    UILabel *take = [[UILabel alloc] initWithFrame:(CGRectMake(167.0f, 8.0f, 113.0f, 29.0f))];
    take.textAlignment = NSTextAlignmentRight;
    if (menu.llevar) take.text = @"Para llevar";
    else take.text = @"Para quedarse";
    take.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    take.textColor =[UIColor whiteColor];
    [view addSubview:take];
    
    UILabel *menuL = [[UILabel alloc] initWithFrame:(CGRectMake(8.0f, 63.0f, 272.0f, 34.0f))];
    menuL.textAlignment = NSTextAlignmentLeft;
    menuL.text = [NSString stringWithFormat:@"Menú %d", (int)(section + 1)];
    menuL.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    menuL.textColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    menuL.textColor =[UIColor whiteColor];
    [view addSubview:menuL];
    
    UILabel *cubiertos = [[UILabel alloc] initWithFrame:(CGRectMake(64.0f, 38.0f, 216.0f, 28.0f))];
    if (menu.cubiertos) cubiertos.text = @"Con cubiertos";
    else cubiertos.text = @"Sin cubiertos";
    cubiertos.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    cubiertos.textAlignment = NSTextAlignmentRight;
    cubiertos.textColor = [UIColor whiteColor];
    [view addSubview:cubiertos];
    
    UILabel *precioL = [[UILabel alloc] initWithFrame:CGRectMake(173.0f, 62.0f, 54.0f, 34.0f)];
    precioL.text = @"Precio:";
    [precioL setTextAlignment:NSTextAlignmentRight];
    precioL.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    precioL.textColor = [UIColor whiteColor];
    [precioL setAdjustsFontSizeToFitWidth:YES];
    [view addSubview:precioL];
    
    UILabel *precio = [[UILabel alloc] initWithFrame:CGRectMake(226.0f, 62.0f, 54.0f, 34.0f)];
    precio.text = [NSString stringWithFormat:@"%.2f€",[menu getPrecio]];
    precio.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    [precio setTextAlignment:NSTextAlignmentRight];
    precio.textColor = [UIColor colorWithRed:(27.0f/255.0f) green:(174.0f/255.0f) blue:(12.0f/255.0f) alpha:1.0f];
    [view addSubview:precio];
    
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ((section + 1) == [self.menus count]) {
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRectMake(0.0f, 0.0f, 288.0f, 215.0f))];
        
        UIImageView *fotoQR = [[UIImageView alloc] initWithFrame:CGRectMake(69.0f, 50.0f, 150.0f, 150.0f)];
        fotoQR.image = self.QR;
        [view addSubview:fotoQR];
        
        UILabel *precioL = [[UILabel alloc] initWithFrame:CGRectMake(165.0f, 8.0f, 54.0f, 34.0f)];
        precioL.text = @"Total:";
        [precioL setTextAlignment:NSTextAlignmentRight];
        precioL.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        precioL.textColor = [UIColor whiteColor];
        [view addSubview:precioL];
        
        UILabel *precio = [[UILabel alloc] initWithFrame:CGRectMake(221.0f, 8.0f, 59.0f, 34.0f)];
        precio.text = [NSString stringWithFormat:@"%.2f€",[self.menus getPrecio]];
        [precio setTextAlignment:NSTextAlignmentRight];
        precio.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        [precio setAdjustsFontSizeToFitWidth:YES];
        precio.textColor = [UIColor colorWithRed:(27.0f/255.0f) green:(174.0f/255.0f) blue:(12.0f/255.0f) alpha:1.0f];
        [view addSubview:precio];
        
        UILabel *guardar = [[UILabel alloc] initWithFrame:(CGRectMake(69.0f, 172.0f, 150.0f, 28.0f))];
        guardar.textAlignment = NSTextAlignmentCenter;
        guardar.text = @"Guardar";
        guardar.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.8f];
        guardar.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        [view addSubview:guardar];
        
        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage:)];
        tapRec.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tapRec];
        
        return view;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:(CGRectMake(0.0f, 0.0f, 288.0f, 10.0f))];
    return view;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMGolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellElemento" forIndexPath:indexPath];
    AMMenu *menu = [self.menus objectAtIndex:indexPath.section];
    if (indexPath.row < [menu.primeros count]) {
        cell.foto.image = [UIImage imageNamed:@"primeros"];
        cell.plato.text = [menu.primeros objectAtIndex:indexPath.row];
    }
    else if (indexPath.row < ([menu.primeros count] + [menu.segundos count])) {
        cell.foto.image = [UIImage imageNamed:@"segundos"];
        cell.plato.text = [menu.segundos objectAtIndex:(indexPath.row - [menu.primeros count])];
    }
    else if ((indexPath.row == ([menu.primeros count] + [menu.segundos count])) && (![menu.postre isEqualToString:@""])){
        cell.foto.image = [UIImage imageNamed:@"postre"];
        cell.plato.text = menu.postre;
    }
    else {
        cell.foto.image = [UIImage imageNamed:@"bebida"];
        cell.plato.text = menu.bebida;
    }
    return cell;
}

-(void) saveImage:(UITapGestureRecognizer *)twotap
{
    if(self.QR != nil) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Guardando el codigo QR";
        [HUD showWhileExecuting:@selector(guardando) onTarget:self withObject:nil animated:YES];
    }
}

-(IBAction)rotate:(id)sender
{
    [self.btnDer setTitle:@""];
    [self.btnDer setEnabled:NO];
    [self.vistaBotones setBackgroundColor:[UIColor blackColor]];//colorWithRed:0.0f green:(204.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f]];
    [self.emailLabel setTextColor:[UIColor whiteColor]];
    UIColor *color = [UIColor lightGrayColor];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"johnapleseed@apple.com" attributes:@{NSForegroundColorAttributeName: color}];
    [self.email setDelegate:self];
    [self.localBtn setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:(51.0f/255.0f) alpha:1.0f]];
    [self.localBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.localBtn setTitleShadowColor:[UIColor colorWithRed:(239.0f/255.0f) green:(239.0f/255.0f) blue:(239.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
    [self.stripeBtn setBackgroundColor:[UIColor colorWithRed:0.0f green:(122.0f/255.0f) blue:1.0f alpha:1.0f]];
    [self.stripeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.stripeBtn setTitleShadowColor:[UIColor colorWithRed:(239.0f/255.0f) green:(239.0f/255.0f) blue:(239.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
    //[self.imagenApple setBackgroundImage:[UIImage imageNamed:@"applePay"] forState:UIControlStateNormal];
    //[self.applePbtn setBackgroundColor:[UIColor whiteColor]];
    //[self.proxim setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.proxim setTitleShadowColor:[UIColor colorWithRed:(239.0f/255.0f) green:(239.0f/255.0f) blue:(239.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
    self.poweredStripe.image = [UIImage imageNamed:@"stripe"];
    
    self.preciobotones.font = [UIFont fontWithName:@"DS-Digital-Bold" size:35.0f];
    [self.preciobotones setTextColor:[UIColor colorWithRed:0.0f green:(204.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f]];
    self.preciobotones.text = [NSString stringWithFormat:@"%.2f",[self.menus getPrecio]];
    self.euroBotones.textColor = [UIColor colorWithRed:0.0f green:(204.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f];
    self.cabeceraPago.image = [UIImage imageNamed:@"cabeceraPago"];
    
    [self.tablaResumen performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    [self.vistaBotones setFrame:CGRectMake(16, 72, self.view.bounds.size.width - 32, self.view.bounds.size.height - 80)];
    [self.view addSubview:self.vistaBotones];
    [self.email becomeFirstResponder];
    CGRect f = self.vistaBotones.frame;
}

- (IBAction)applePay:(id)sender
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Apple Pay"
                                      message:@"Cuando Apple Pay esté disponible en España actualizaremos la app para su uso."
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Apple Pay"
                                                        message:@"Cuando Apple Pay esté disponible en España actualizaremos la app para su uso."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)stripe:(id)sender
{
    if ([self NSStringIsValidEmail:self.email.text]) {
        [self.email resignFirstResponder];
        self.emailDestino = self.email.text;
        [self addStripeView];
    }
    else {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"E-mail válido"
                                          message:@"Por favor introduce un e-mail válido."
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail válido"
                                                            message:@"Por favor introduce un e-mail válido."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)addStripeView
{
    [self.vistaBotones performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    self.vistaPagos = [[UIView alloc] initWithFrame:CGRectMake(321, 72, 288, (screenHeight - 80))];
    self.vistaPagos.layer.cornerRadius = 25.0f;
    [self.vistaPagos setBackgroundColor:[UIColor blackColor]];
    double alt = self.vistaPagos.frame.size.height;
    
    UILabel *precio = [[UILabel alloc] initWithFrame:CGRectMake(210, 75.0f, 70, 35)];
    precio.textColor = [UIColor whiteColor];
    int centimos = (int)(([self.menus getPrecio] * 1.05) * 100);
    double euros = (centimos/100.0);
    precio.text = [NSString stringWithFormat:@"%.2f€",euros];
    precio.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    precio.textAlignment = NSTextAlignmentRight;
    [self.vistaPagos addSubview:precio];
    
    UILabel *precioL = [[UILabel alloc] initWithFrame:CGRectMake(105, 75.0f, 100, 35)];
    precioL.textColor = [UIColor whiteColor];
    precioL.text = @"Precio final:";
    precioL.textAlignment = NSTextAlignmentRight;
    precioL.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    [self.vistaPagos addSubview:precioL];
    
    UILabel *seguro = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, ((alt/2.0f)+33.0f), 258, 52)];
    seguro.numberOfLines = 0;
    seguro.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    seguro.text = @"Recuerde  que  el  pago de esta aplicación se realiza  mediante  un  sistema de pago seguro creado y mantenido por:";
    seguro.textColor = [UIColor whiteColor];
    [self.vistaPagos addSubview:seguro];
    
    UILabel *recoger = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 115, 258, 80)];
    recoger.numberOfLines = 0;
    recoger.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    recoger.text = @"Al  haber utilizado el servicio Pay & Go, usted no tiene que hacer cola al recoger su pedido. Simplemente  indentifíquese  con  el  mail  de confirmación   o  el Pass  de  Passbook  y  le daremos su pedido";
    recoger.textColor = [UIColor whiteColor];
    [self.vistaPagos addSubview:recoger];
    
    UILabel *payandgo = [[UILabel alloc] initWithFrame:CGRectMake(8, 25, 272, 35)];
    payandgo.textColor = [UIColor colorWithRed:(51.0f/255.0f) green:(51.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f];
    payandgo.text = @"PAY & GO";
    payandgo.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:35.0f];
    [self.vistaPagos addSubview:payandgo];
    
    UIImageView *stripeImage = [[UIImageView alloc] initWithFrame:CGRectMake(195, ((alt/2.0f)+75.0f), 85.0f, 40.0f)];
    stripeImage.image = [UIImage imageNamed: @"stripeLogo"];
    [self.vistaPagos addSubview:stripeImage];
    
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(8,((alt/2.0f)-23.0f),272,46)];
    self.paymentView = view;
    [self.paymentView setDelegate:self];
    [self.paymentView setClipsToBounds:YES];
    [self.vistaPagos addSubview:self.paymentView];
    [self.view addSubview:self.vistaPagos];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect f3 = self.vistaPagos.frame;
                         f3.origin.x = 16.0f;
                         self.vistaPagos.frame = f3;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    self.btnDer.title = @"Pagar";
    [self.btnDer setEnabled:YES];
    
    [self.btnDer setTarget:self];
    [self.btnDer setAction:@selector(buy:)];
}

- (void)buy:(id)sender
{
    [self.paymentView endEditing:YES];
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.HUD];
    self.HUD.labelText = @"Autorizando...";
    [self.HUD show:YES];
    
    [self createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self.HUD hide:YES];
            [self ensenarError:@"Error al conectar con Stripe. Vuelva a intentarlo y sino llame al 93 176 06 51"];
        } else {
            [self charge:token];
        }
    }];
}

- (void)createToken:(STPCheckoutTokenBlock)block
{
    
    PTKCard* card = self.paymentView.card;
    STPCard* scard = [[STPCard alloc] init];
    
    scard.number = card.number;
    scard.expMonth = card.expMonth;
    scard.expYear = card.expYear;
    scard.cvc = card.cvc;
    
    [Stripe createTokenWithCard:scard
                 publishableKey:@""
                     completion:^(STPToken *token, NSError *error) {
                         block(token, error);
                     }];
    
}

- (void)charge:(STPToken *)token
{
    self.HUD.labelText = @"Cobrando...";
    int centimos = (int)(([self.menus getPrecio] * 1.05) * 100);
    NSDictionary *productInfo = @{
                                  @"price": [NSString stringWithFormat:@"%d",centimos],
                                  @"cardToken": token.tokenId,
                                  @"toEmail": self.emailDestino
                                  };
    [PFCloud callFunctionInBackground:@"purchaseItem"
                       withParameters:productInfo
                                block:^(NSString *result, NSError *error) {
                                    [self.HUD hide:YES];
                                    if (error) {
                                        [self ensenarError:@"Ha habido un error en el proceso de compra.No se preocupe, no se le ha cobrado nada. Vuelva a intentarlo y si no llame al 93 176 06 51"];
                                        
                                    } else {
                                        self.btnDer.title = @"";
                                        [self.btnDer setEnabled:NO];
                                        int centimos = (int)(([self.menus getPrecio] * 1.05) * 100);
                                        double euros = (centimos/100.0);
                                        self.importePagado = [NSString stringWithFormat:@"%.2f",euros];
                                        [self sendTo:self.emailDestino pagado:@"Si, con Stripe"];
                                    }
                                }];
}


- (IBAction)local:(id)sender
{
    if ([self NSStringIsValidEmail:self.email.text]) {
        [self.email resignFirstResponder];
        self.emailDestino = self.email.text;
        self.importePagado = [NSString stringWithFormat:@"%.2f",[self.menus getPrecio]];
        [self sendTo:self.email.text pagado:@"No, pagar al recoger."];
    }
    else {
        if (nil != NSClassFromString(@"UIAlertController")) {
            //show alertcontroller
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"E-mail válido"
                                          message:@"Por favor introduce un e-mail válido."
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail válido"
                                                            message:@"Por favor introduce un e-mail válido."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)sendTo:(NSString *)toMail pagado:(NSString *)pagado
{
    self.pago = pagado;
    NSString *texto = @"Estimado cliente/a,\n\nAquí tienes el resumen de tu pedido:\n\n\n";
    texto = [texto stringByAppendingString:[self.menus stringValue]];
    texto = [texto stringByAppendingString:@"\nPedido pagado: "];
    texto = [texto stringByAppendingString:pagado];
    texto = [texto stringByAppendingString:@"\n\n\nMuchas gracias,\n\nEl equipo de A menjar!"];
    BOOL tipo = [self.pago isEqualToString:@"Si, con Stripe"];
    [self sendMailTo:toMail withTitle:@"Pedido A menjar!" andText:texto andTipe:tipo];
}

-(void) guardando
{
    sleep(1);
    UIImageWriteToSavedPhotosAlbum(self.QR, nil, nil, nil);
}


-(void)sendMailTo:(NSString *)toMail withTitle:(NSString *)titulo andText:(NSString *)pedido andTipe:(BOOL)stripe
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"Enviando correo";
    
    [self.HUD show:YES];
    
    [PFCloud callFunctionInBackground:@"sendMail"
                       withParameters:@{@"toEmail":toMail,
                                        @"fromEmail":@"mauro@amenjar.com",
                                        @"fromName":@"Mauro Vime",
                                        @"text":pedido,
                                        @"subject":titulo}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        [self registroYalarma];
                                        [self sendPush];
                                        [self.HUD hide:YES];
                                        [self emailEnviado];
                                    }
                                    else {
                                        [self.HUD hide:YES];
                                        if (stripe) [self ensenarError:@"Lo sentimos, se le ha cobrado y ha habido un error al enviar el mail con el pedido. Por favor llame al 93 176 06 51"];
                                    }
                                }];
}

-(void)emailEnviado
{
    [self.HUD hide:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat alt1;
    if (self.vistaBotones != nil) alt1 = self.vistaBotones.frame.size.height;
    else alt1 = screenHeight - 80;
    self.confirm = [[UIView alloc] initWithFrame:CGRectMake(321.0f, 72.0f, 288.0f,alt1)];
    [self.confirm setBackgroundColor:[UIColor colorWithRed:0.0f green:(122.0f/255.0f) blue:(1.0f) alpha:1.0f]];
    self.confirm.layer.cornerRadius = 25.0f;
    [self.confirm setClipsToBounds:YES];
    
    UIView *forma = [[UIView alloc] initWithFrame:CGRectMake(69.0f, ((alt1/2.0f)-75), 150.0f, 150.0f)];
    [forma setBackgroundColor:[UIColor colorWithRed:0.0f green:(204.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f]];
    forma.layer.cornerRadius = (forma.frame.size.width/2.0f);
    [self.confirm addSubview:forma];
    UIImageView *check = [[UIImageView alloc] initWithFrame:CGRectMake(82.0f, ((alt1/2.0f)-62.5f), 125.0f, 125.0f)];
    check.image = [UIImage imageNamed:@"finalCheck"];
    [self.confirm addSubview:check];
    UILabel *hecho = [[UILabel alloc] initWithFrame:CGRectMake(110.0f, (((alt1/2.0f)-62.5f)+146), 68.0f, 21.0f)];
    hecho.text = @"Hecho";
    hecho.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    hecho.textColor = [UIColor whiteColor];
    hecho.textAlignment = NSTextAlignmentCenter;
    [hecho setClipsToBounds:YES];
    [self.confirm addSubview:hecho];
    
    [self.view addSubview:self.confirm];
    
    [self.cnclBtn setTitle:@""];
    [self.cnclBtn setEnabled:NO];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect f = self.tablaResumen.frame;
                         f.origin.x = -289.0f;
                         self.tablaResumen.frame = f;
                         
                         CGRect f2 = self.vistaBotones.frame;
                         f2.origin.x = -289.0f;
                         self.vistaBotones.frame = f2;
                         
                         CGRect f3 = self.vistaPagos.frame;
                         f3.origin.x = -289.0f;
                         self.vistaPagos.frame = f3;
                         
                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         CGFloat screenHeight = screenRect.size.height;
                         CGFloat alt1;
                         if (self.vistaBotones != nil) alt1 = self.vistaBotones.frame.size.height;
                         else alt1 = screenHeight - 80;
                         [self.confirm setFrame:CGRectMake(16.0f, 72.0f, 288.0f, alt1)];
                     }
                     completion:^(BOOL finished){
                         if (self.vistaBotones != nil)[self.vistaBotones performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                         if (self.vistaPagos != nil) [self.vistaPagos performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                         if ([self whantsPass]) [self getPass];
                         else {
                             sleep(1);
                             [self performSegueWithIdentifier:@"unwindToNothinginMenu" sender:self];
                         }
                     }];
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

-(void)getPass
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:self.HUD];
    self.HUD.labelText = @"Descargando Pass...";
    [self.HUD show:YES];
    self.btnDer.title = @"Salir";
    [self.btnDer setTarget:self];
    [self.btnDer setAction:@selector(exitQR:)];
    NSString *importe = [@"€" stringByAppendingString:self.importePagado];
    int dia;
    int mes;
    int ano;
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    mes = (int)[components month];
    dia = (int)[components day];
    ano = (int)[components year];
    NSString *fecha = [NSString stringWithFormat:@"%02d/%02d/%d - %d:%02d",dia,mes,ano,[self.menus horaPedido],[self.menus minutoPedido]];
    NSDictionary *values = @{@"Correo" : self.emailDestino, @"Tarjeta":self.pago, @"Dinero": importe,@"Fecha":fecha, @"Pedido":[self.menus stringValue]};
    
    [PassSlot setErrorHandler:^(NSError *error){
        [self.btnDer setEnabled:YES];
        [self.HUD hide:YES];
        NSLog(@"Ha habido un error al descargar el Pass.");
    }];
    
    [PassSlot passFromTemplateWithName:@"Order pass" withValues:values pass:^(PSPass *pass) {
        [PassSlot downloadPass:pass pass:^(PSPass *pass) {
            PKPass *pkpass = [pass pkPass];
            PKAddPassesViewController *vc = [[PKAddPassesViewController alloc] initWithPass:pkpass];
            vc.delegate = self;
            [self.navigationController presentViewController:vc animated:YES completion:NULL];
            NSLog(@"PassSlot is SO EASY!");
        }];
    }];
}

-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.btnDer setEnabled:YES];
        [self.HUD hide:YES];
    }];
}

- (void)exitQR:(id)sender
{
    [self performSegueWithIdentifier:@"unwindToNothinginMenu" sender:self];
}

-(void) sendPush
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:@"pro"];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSString *texto = [@"Pedido realizado por " stringByAppendingString:self.emailDestino];
    [push setMessage:texto];
    [push sendPushInBackground];
}

-(void)registroYalarma
{
    [self addRegistroAM];
    int tiempo;
    BOOL alarmaPermitida;
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmaboolKey"];
    if(data1 == nil){
        alarmaPermitida = YES;
        tiempo = 5;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AlarmaboolKey"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tiempo] forKey:@"AlarmaTime"];
    }
    else {
        alarmaPermitida = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"AlarmaboolKey"];
    }
    if (alarmaPermitida) {
        tiempo = (int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmaTime"] intValue];
        UILocalNotification *local = [[UILocalNotification alloc]init];
        
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
        
        if(tiempo < 60) {
            if(([self.menus minutoPedido] - tiempo) < 0) {
                [components setHour:([self.menus horaPedido] - 1)];
                [components setMinute:(60+[self.menus minutoPedido] - tiempo)];
            }
            else {
                [components setHour:[self.menus horaPedido]];
                [components setMinute:([self.menus minutoPedido] - tiempo)];
            }
        }
        else {
            [components setHour:([self.menus horaPedido] - 1)];
            [components setMinute:[self.menus minutoPedido]];
        }
        
        local.fireDate = [calendar dateFromComponents:components];
        local.alertBody = [NSString stringWithFormat:@"Tu pedido estará preparado en %d minutos.",tiempo];
        local.alertAction = @"View";
        local.applicationIconBadgeNumber = 1;
        local.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication]scheduleLocalNotification:local];
    }
}

-(void)ensenarError:(NSString *)error
{
    if (nil != NSClassFromString(@"UIAlertController")) {
        //show alertcontroller
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"ERROR"
                                      message:error
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Cancelar"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        UIAlertAction* call = [UIAlertAction
                               actionWithTitle:@"Llamar"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action)
                               {
                                   //Do some thing here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   NSString *URLString = @"tel://931760651";
                                   NSURL *URL = [NSURL URLWithString:URLString];
                                   [[UIApplication sharedApplication] openURL:URL];
                                   
                               }];
        [alert addAction:call];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        //show alertview
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:error
                                                       delegate:self
                                              cancelButtonTitle:@"Cancelar"
                                              otherButtonTitles:@"Llamar",nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Llamar"]) {
        NSString *URLString = @"tel://931760651";
        NSURL *URL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:URL];
    }
}

-(void)addRegistroAM
{
    NSMutableArray *primerosR = [self.registro objectAtIndex:0];
    NSMutableArray *segundosR = [self.registro objectAtIndex:1];
    NSMutableArray *postresR = [self.registro objectAtIndex:2];
    NSMutableArray *bebidasR = [self.registro objectAtIndex:3];
    
    for(int m = 0; m < [self.menus count]; ++m) {
        AMMenu *menuR = [self.menus objectAtIndex:m];
        for(int j = 0; j < [menuR.primeros count]; ++j) {
            NSString *newP = [menuR.primeros objectAtIndex:j];
            AMRegistro *newR;
            bool tro = NO;
            for(int i = 0; i < [primerosR count] && !tro; ++i) {
                AMRegistro *elemento = [primerosR objectAtIndex:i];
                if([elemento.elemento isEqualToString:newP]) {
                    tro = true;
                    newR = elemento;
                }
            }
            if(tro) {
                int aux = [newR.veces intValue];
                newR.veces = [NSNumber numberWithInt:(aux+1)];
            }
            else {
                newR = [[AMRegistro alloc] init];
                newR.elemento = newP;
                newR.veces = [NSNumber numberWithInt:1];
                [primerosR addObject:newR];
            }
        }
        for(int j = 0; j < [menuR.segundos count]; ++j) {
            NSString *newP = [menuR.segundos objectAtIndex:j];
            AMRegistro *newR;
            bool tro = NO;
            for(int i = 0; i < [segundosR count] && !tro; ++i) {
                AMRegistro *elemento = [segundosR objectAtIndex:i];
                if([elemento.elemento isEqualToString:newP]) {
                    tro = true;
                    newR = elemento;
                }
            }
            if(tro) {
                int aux = [newR.veces intValue];
                newR.veces = [NSNumber numberWithInt:(aux+1)];
            }
            else {
                newR = [[AMRegistro alloc] init];
                newR.elemento = newP;
                newR.veces = [NSNumber numberWithInt:1];
                [segundosR addObject:newR];
            }
        }
        if(![menuR.postre isEqualToString:@""]) {
            NSString *newP = menuR.postre;
            AMRegistro *newR;
            bool tro = NO;
            for(int i = 0; i < [postresR count] && !tro; ++i) {
                AMRegistro *elemento = [postresR objectAtIndex:i];
                if([elemento.elemento isEqualToString:newP]) {
                    tro = true;
                    newR = elemento;
                }
            }
            if(tro) {
                int aux = [newR.veces intValue];
                newR.veces = [NSNumber numberWithInt:(aux+1)];
            }
            else {
                newR = [[AMRegistro alloc] init];
                newR.elemento = newP;
                newR.veces = [NSNumber numberWithInt:1];
                [postresR addObject:newR];
            }
        }
        if(![menuR.bebida isEqualToString:@"SIN BEBIDA"]) {
            NSString *newP = menuR.bebida;
            AMRegistro *newR;
            bool tro = NO;
            for(int i = 0; i < [bebidasR count] && !tro; ++i) {
                AMRegistro *elemento = [bebidasR objectAtIndex:i];
                if([elemento.elemento isEqualToString:newP]) {
                    tro = true;
                    newR = elemento;
                }
            }
            if(tro) {
                int aux = [newR.veces intValue];
                newR.veces = [NSNumber numberWithInt:(aux+1)];
            }
            else {
                newR = [[AMRegistro alloc] init];
                newR.elemento = newP;
                newR.veces = [NSNumber numberWithInt:1];
                [bebidasR addObject:newR];
            }
        }
    }
    [self guardar];
}

- (void) guardar
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"veces" ascending:NO];
    NSSortDescriptor *sortDescriptor2;
    sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"elemento" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,sortDescriptor2,nil];
    NSArray *primerosR = [self.registro objectAtIndex:0];
    NSArray *segundosR = [self.registro objectAtIndex:1];
    NSArray *postresR = [self.registro objectAtIndex:2];
    NSArray *bebidasR = [self.registro objectAtIndex:3];
    [self.registro setObject:[[primerosR sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] atIndexedSubscript:0];
    [self.registro setObject:[[segundosR sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] atIndexedSubscript:1];
    [self.registro setObject:[[postresR sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] atIndexedSubscript:2];
    [self.registro setObject:[[bebidasR sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] atIndexedSubscript:3];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.registro] forKey:@"arraySaveAmenjarPedidos"];
}

// =============================================================================
#pragma mark - Private

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}


@end
