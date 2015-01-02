//
//  AMTiempoTableViewCell.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 20/05/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMTiempoTableViewCell.h"

@implementation AMTiempoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.refresh.imageView.image = [UIImage imageNamed:@"refresh.png"];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)refresh:(id)sender {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.duration = 3.0;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.refresh.imageView.layer addAnimation:animation forKey:@"transform.rotation.z"];
    [self.padre refreshWeather];
}

-(void)startRotation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.duration = 3.0;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.refresh.imageView.layer addAnimation:animation forKey:@"transform.rotation.z"];
}


-(void)stopRotation
{
    [self.refresh.imageView.layer removeAllAnimations];
    self.refresh.imageView.image = [UIImage imageNamed:@"refresh.png"];
}

@end
