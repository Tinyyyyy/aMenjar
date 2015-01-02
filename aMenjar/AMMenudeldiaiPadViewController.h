//
//  AMMenudeldiaiPadViewController.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AMPedido5.h"
#import "AMMenus.h"

@interface AMMenudeldiaiPadViewController : UITableViewController

@property NSMutableArray *primeros;
@property NSMutableArray *segundos;
@property NSMutableArray *postres;
@property BOOL festivo;
@property BOOL reload;

@property AMMenu *menu;

-(void)mailing;
-(void)cancel;

@end
