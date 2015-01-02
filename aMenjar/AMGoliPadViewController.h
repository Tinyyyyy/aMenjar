//
//  AMGoliPadViewController.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 03/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMGoliPadViewController : UIViewController

@property NSMutableArray *mediodia;
@property NSMutableArray *noche;
@property BOOL leido;

-(void)actualizarDatos;

@end
