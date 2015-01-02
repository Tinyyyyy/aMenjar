//
//  AMCustomMenuCell.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 03/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMCustomMenuCell.h"

@implementation AMCustomMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
