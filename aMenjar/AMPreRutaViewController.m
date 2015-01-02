//
//  AMPreRutaViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 15/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMPreRutaViewController.h"
#import "AMRoutesViewController.h"

@interface AMPreRutaViewController ()

@end

@implementation AMPreRutaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AMRoutesViewController *tbc = (AMRoutesViewController *)self.childViewControllers[0];
    tbc.rutas = self.papi.rutas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)salir:(id)sender {
    [self.papi salir];
}

@end
