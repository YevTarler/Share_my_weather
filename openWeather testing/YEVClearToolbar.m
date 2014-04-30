//
//  YEVClearToolbar.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/28/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "YEVClearToolbar.h"

@implementation YEVClearToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithWhite:0 alpha:0.0f] set]; // or clearColor etc
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}
@end
