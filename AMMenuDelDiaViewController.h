//
//  AMmenuDelDiaViewController.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AMMenus.h"

@interface AMMenuDelDiaViewController : UITableViewController

@property NSMutableArray *primeros;
@property NSMutableArray *segundos;
@property NSMutableArray *postres;
@property BOOL festivo;

@property AMMenu *menu;

- (IBAction)unwindToNothinginMenu:(UIStoryboardSegue *)segue;
- (IBAction)unwindToSendMail:(UIStoryboardSegue *)segue;

@end
