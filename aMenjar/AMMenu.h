//
//  AMMenu.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMMenu : NSObject

@property NSMutableArray *primeros;
@property NSMutableArray *segundos;
@property NSString *bebida;
@property NSString *postre;
@property BOOL llevar;
@property NSString* nombre;
@property int hora;
@property int minuto;
@property BOOL cubiertos;

-(BOOL)addDish:(NSString *)dish atPos:(int)pos;
-(BOOL)addDesert:(NSString *)desert;
-(int)elementos;
-(double)getPrecio;

@end
