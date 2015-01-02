//
//  AMMenus.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMMenus.h"

@implementation AMMenus

-(NSUInteger)count
{
    return [self.realArray count];
}

-(NSString *)stringValue
{
    NSString *contenidoPedido = @"";
    for (int i = 0; i < [self.realArray count]; ++i) {
        AMMenu *menu = [self.realArray objectAtIndex:i];
        contenidoPedido = [contenidoPedido stringByAppendingString:[NSString stringWithFormat:@"Menú %d",(i+1)]];
        contenidoPedido = [contenidoPedido stringByAppendingString:[NSString stringWithFormat:@"\n\nNombre: %@ \n\n",menu.nombre]];

        NSString *diahora;
        if (menu.minuto < 10) diahora = [NSString stringWithFormat:@"%d:0%d",menu.hora,menu.minuto];
        else diahora = [NSString stringWithFormat:@"%d:%d",menu.hora,menu.minuto];
        
        contenidoPedido = [contenidoPedido stringByAppendingString:[NSString stringWithFormat:@"Hora de recogida: %@ \n\n",diahora]];
        
        for (int i = 0; i < [menu.primeros count]; ++i) {
            contenidoPedido = [contenidoPedido stringByAppendingString:[NSString stringWithFormat:@"Plato %d: ",(i+1)]];
            contenidoPedido = [contenidoPedido stringByAppendingString:[menu.primeros objectAtIndex:i]];
            contenidoPedido = [contenidoPedido stringByAppendingString:@"\n\n"];
        }
        for (int i = 0; i < [menu.segundos count]; ++i) {
            contenidoPedido = [contenidoPedido stringByAppendingString:[NSString stringWithFormat:@"Plato %d: ",(i+1+(int)[menu.primeros count])]];
            contenidoPedido = [contenidoPedido stringByAppendingString:[menu.segundos objectAtIndex:i]];
            contenidoPedido = [contenidoPedido stringByAppendingString:@"\n\n"];
        }
        
        contenidoPedido = [contenidoPedido stringByAppendingString:@"Postre: "];
        if ([menu.postre isEqualToString:@""]) contenidoPedido = [contenidoPedido stringByAppendingString:@"NO"];
        else contenidoPedido = [contenidoPedido stringByAppendingString:menu.postre];
        
        contenidoPedido = [contenidoPedido stringByAppendingString:[@"\n\nBebida: " stringByAppendingString:menu.bebida]];
        
        if(menu.llevar) {
            contenidoPedido = [contenidoPedido stringByAppendingString:@"\n\nPara llevar: SI\n"];
            if(menu.cubiertos) contenidoPedido = [contenidoPedido stringByAppendingString:@"\nCubiertos: SI\n"];
            else contenidoPedido = [contenidoPedido stringByAppendingString:@"\nCubiertos: NO\n"];
        }
        else contenidoPedido = [contenidoPedido stringByAppendingString:@"\n\nPara llevar: NO\n"];
        
    }
    return contenidoPedido;
}

-(void)addObject:(id)anObject
{
    if (self.realArray == nil) self.realArray = [[NSMutableArray alloc] init];
    [self.realArray addObject:anObject];
}

-(id)objectAtIndex:(NSUInteger)index
{
    return [self.realArray objectAtIndex:index];
}


-(int)horaPedido
{
    int ref = 0;
    for (int i = 0; i < [self.realArray count]; ++i) {
        AMMenu *menu = [self.realArray objectAtIndex:i];
        if (menu.hora > ref) ref = menu.hora;
    }
    return ref;
}

-(int)minutoPedido
{
    int ref = 0;
    for (int i = 0; i < [self.realArray count]; ++i) {
        AMMenu *menu = [self.realArray objectAtIndex:i];
        if (menu.hora > ref) ref = menu.minuto;
    }
    return ref;
}

-(double)getPrecio
{
    double precio = 0;
    for (int i = 0; i < [self.realArray count]; ++i) {
        AMMenu *menu = [self.realArray objectAtIndex:i];
        precio += [menu getPrecio];
    }
    return precio;
}

@end
