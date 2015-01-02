//
//  AMBebidas.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 02/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMBebidas.h"

@interface AMBebidas () <UIPickerViewDataSource>

@end

@implementation AMBebidas

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 12;
}

self.listaBebidas = [[NSArray alloc] initWithObjects:@"Happy",@"Dopey",@"Doc",@"Bashful",@"Sleepy",@"Sneezy",@"Grumpy", nil];

@end
