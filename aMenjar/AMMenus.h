//
//  AMMenus.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMenu.h"

@interface AMMenus : NSMutableArray

-(NSString *)stringValue;

-(int)horaPedido;
-(int)minutoPedido;
-(double)getPrecio;

@property NSMutableArray *realArray;

@end
