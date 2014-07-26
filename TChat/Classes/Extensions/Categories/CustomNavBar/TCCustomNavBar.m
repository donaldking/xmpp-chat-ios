//
//  TCCustomNavBar.m
//  TChat
//
//  Created by SWATI KIRVE on 26/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCCustomNavBar.h"
#define customNavBar @"navbar"

@implementation TCCustomNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    view.layer.contents = (id)[[UIImage imageNamed:customNavBar] CGImage];
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    
    [self addSubview:view];
    [self sendSubviewToBack:view];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
