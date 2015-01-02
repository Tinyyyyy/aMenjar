//
//  AMRegistro.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 07/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMRegistro.h"

@implementation AMRegistro

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.elemento forKey:@"elementoPlato"];
    [coder encodeObject:self.veces
           forKey:[@"elemento: " stringByAppendingString:self.elemento]];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [[AMRegistro alloc] init];
    if (self != nil) {
        self.elemento = [coder decodeObjectForKey:@"elementoPlato"];
        self.veces = [coder decodeObjectForKey:[@"elemento: " stringByAppendingString:self.elemento]];
    }
    return self;
}

@end
