//
//  AMResumenIpadViewController.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 14/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMMenus.h"
#import "Stripe.h"
#import <PassKit/PassKit.h>
#import "PTKView.h"
#import "AMMenudeldiaiPadViewController.h"

typedef void (^STPCheckoutTokenBlock)(STPToken* token, NSError* error);

@interface AMResumenIpadViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDer;
@property (weak, nonatomic) IBOutlet UIView *vistaBotones;
@property (weak, nonatomic) IBOutlet UITableView *tablaResumen;
@property AMMenus *menus;
@property (weak, nonatomic) IBOutlet UIButton *localBtn;
@property (weak, nonatomic) IBOutlet UIButton *stripeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *poweredStripe;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UILabel *preciobotones;
@property (weak, nonatomic) IBOutlet UILabel *euroBotones;
@property (weak, nonatomic) IBOutlet UIImageView *cabeceraPago;
@property AMMenudeldiaiPadViewController *papi;

@end
