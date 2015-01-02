//
//  AMAppDelegate.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property NSMutableArray *primeros;
@property NSMutableArray *segundos;
@property NSMutableArray *postres;
@property BOOL festivo;

@end
