//
//  AMPedidoNaviViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 12/9/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMPedidoNaviViewController.h"

@interface AMPedidoNaviViewController ()

@end

@implementation AMPedidoNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    return self.papi;
    /*for(UIViewController *vc in self.viewControllers){
        // Always use -canPerformUnwindSegueAction:fromViewController:withSender:
        // to determine if a view controller wants to handle an unwind action.
        if ([vc canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender])
            return vc;
    }
    
    
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];*/
}

@end
