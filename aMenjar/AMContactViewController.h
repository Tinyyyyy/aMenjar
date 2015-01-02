//
//  XYZContactViewController.h
//  iNotas
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AMContactViewController : UITableViewController

-(void)refreshWeather;
- (IBAction)unwindToInfo:(UIStoryboardSegue *)segue;

@end
