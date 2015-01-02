//
//  AMMenu.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMMenu.h"

@implementation AMMenu

-(id)init
{
    self = [super init];
    self.primeros = [[NSMutableArray alloc] init];
    self.segundos = [[NSMutableArray alloc] init];
    self.postre = @"";
    self.bebida = @"";
    self.nombre = nil;
    self.cubiertos = NO;
    return self;
}

-(BOOL)addDish:(NSString *)dish atPos:(int)pos
{
    if (pos == 1) {
        if (![self.primeros containsObject:dish]) {
            if ([self.primeros count] + [self.segundos count] == 2) {
                return NO;
            }
            else  [self.primeros addObject:dish];
        }
        else [self.primeros removeObject:dish];
    }
    else {
        if (![self.segundos containsObject:dish]) {
            if ([self.primeros count] + [self.segundos count] == 2) {
                return NO;
            }
            else  [self.segundos addObject:dish];
        }
        else [self.segundos removeObject:dish];
    }
    return YES;
}

-(BOOL)addDesert:(NSString *)desert
{
    if (desert == self.postre) self.postre = @"";
    else {
        if (![self.postre isEqualToString: @""]) {
            return NO;
        }
        else self.postre = desert;
    }
    return YES;
}

-(int)elementos
{
    int count = ((int)[self.primeros count] + (int)[self.segundos count]);
    if (![self.postre isEqualToString:@""]) count += 1;
    if (![self.bebida isEqualToString:@"SIN BEBIDA"])count += 1;
    return count;
}

-(double)getPrecio
{
    double val = 0;
    if (([self.primeros count] == 1) && [self.segundos count] == 0) { // 1 primero
        if (![self.bebida isEqualToString:@"SIN BEBIDA"]) {
            if (![self.postre isEqualToString:@""]) val += 6.20; // con bebida y postre
            else val += 5; // con bebida
        }
        else if (![self.postre isEqualToString:@""]) val += 5; // con postre
        else val += 4; // basico
    }
    else if ([self.primeros count] == 2) {   // 2 primeros
        if (![self.bebida isEqualToString:@"SIN BEBIDA"]) {
            if (![self.postre isEqualToString:@""]) val += 8.50; // con bebida y postre
            else val += 8.20; // con bebida
        }
        else if (![self.postre isEqualToString:@""]) val += 8.20; // con postre
        else val += 7; // basico
    }
    else if (([self.primeros count] + [self.segundos count]) == 2) { // 1 primero y 1 segundo
        if (![self.bebida isEqualToString:@"SIN BEBIDA"]) {
            if (![self.postre isEqualToString:@""]) val += 8.50;
            else val += 8.20;
        }
        else if (![self.postre isEqualToString:@""]) val += 8.20;
        else val += 7;
    }
    else if (([self.primeros count] == 0) && ([self.segundos count] == 1)) { // 1 segundo
        if (![self.bebida isEqualToString:@"SIN BEBIDA"]) {
            if (![self.postre isEqualToString:@""]) val += 6.20;
            else val += 5;
        }
        else if (![self.postre isEqualToString:@""]) val += 5;
        else val += 4.5;
    }
    else if ([self.segundos count] == 2) { // 2 segundos
        if (![self.bebida isEqualToString:@"SIN BEBIDA"]) {
            if (![self.postre isEqualToString:@""]) val += 9;
            else val += 8.7;
        }
        else if (![self.postre isEqualToString:@""]) val += 8.7;
        else val += 7.5;
    }
    if ((val < 8.5) && (self.cubiertos) &&(self.llevar)) val += 0.20;
    return val;
}

@end