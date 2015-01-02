//
//  AMQRPedidoViewController.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 02/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMMenus.h"
#import "Stripe.h"
#import "PTKView.h"
#import "AMMenuDelDiaViewController.h"

typedef void (^STPCheckoutTokenBlock)(STPToken* token, NSError* error);

@interface AMQRPedidoViewController : UIViewController

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

@end
