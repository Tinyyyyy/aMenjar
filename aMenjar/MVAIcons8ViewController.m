//
//  MVAIcons8ViewController.m
//  Bruce Stats
//
//  Created by Mauro Vime Castillo on 19/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "MVAIcons8ViewController.h"

@interface MVAIcons8ViewController ()

@end

@implementation MVAIcons8ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *fullURL = @"http://www.icons8.com";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.icons8web loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)exit:(id)sender {
    MVADetailCopyrightViewController *dest = (MVADetailCopyrightViewController*) self.anterior;
    [dest exit2];
}

@end
