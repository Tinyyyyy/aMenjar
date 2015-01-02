//
//  AMPedido5.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 03/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMMenudeldiaiPadViewController.h"

@interface AMPedido5 : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nombre;

@property (weak, nonatomic) IBOutlet UIPickerView *bebida;

@property NSInteger *diaActual;
@property NSInteger *mesActual;
@property NSInteger *añoActual;

@property id anterior;

@property NSDate *fecha;

@end
