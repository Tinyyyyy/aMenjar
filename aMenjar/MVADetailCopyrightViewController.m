//
//  MVADetailCopyrightViewController.m
//  Bruce Stats
//
//  Created by Mauro Vime Castillo on 19/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "MVADetailCopyrightViewController.h"

@interface MVADetailCopyrightViewController ()

@end

@implementation MVADetailCopyrightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)exit:(id)sender {
    [self.anterior exit];
}

-(void)exit2
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)unwindToCopyright:(UIStoryboardSegue *)segue { }

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueIcons8"]) {
        MVAIcons8ViewController *alarma = (MVAIcons8ViewController *) segue.destinationViewController;
        alarma.anterior = self;
    }
}

@end
