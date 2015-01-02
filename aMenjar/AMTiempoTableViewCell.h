//
//  AMTiempoTableViewCell.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 20/05/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMContactViewController.h"

@interface AMTiempoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *temperatura;
@property (weak, nonatomic) IBOutlet UILabel *maximo;
@property (weak, nonatomic) IBOutlet UILabel *minimo;
@property AMContactViewController *padre;
@property (weak, nonatomic) IBOutlet UIButton *refresh;
@property (weak, nonatomic) IBOutlet UILabel *tipo;
@property (weak, nonatomic) IBOutlet UIImageView *fondo;

-(void)startRotation;
-(void)stopRotation;

@end
