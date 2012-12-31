//
//  DMBar.m
//  DMBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMBar.h"

// Gradient applied to the background of the tabBar
// (Colors and gradient from Stephan Michels Softwareentwicklung und Beratung - SMTabBar)
#define kDMBarGradientColor_Start                        [NSColor colorWithCalibratedRed:0.851f green:0.851f blue:0.851f alpha:1.0f]
#define kDMBarGradientColor_End                          [NSColor colorWithCalibratedRed:0.700f green:0.700f blue:0.700f alpha:1.0f]
#define KDMBarGradient

// Border color of the bar
#define kDMBarBorderColor                                [NSColor colorWithDeviceWhite:0.2 alpha:1.0f]

// Bar height
#define kDMBarHeight                                     22.0

@implementation DMBar

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        [self setDefaultColors];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setDefaultColors];
    }
    return self;
}

- (void)setDefaultColors
{
    self.gradientColorStart = kDMBarGradientColor_Start;
    self.gradientColorEnd = kDMBarGradientColor_End;
    self.borderColor = kDMBarBorderColor;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Draw bar gradient
    [[[NSGradient alloc] initWithStartingColor:self.gradientColorStart endingColor:self.gradientColorEnd] drawInRect:self.bounds angle:90.0];
    
    // Draw drak gray bottom border
    [_borderColor setStroke];
    [NSBezierPath setDefaultLineWidth:0.0f];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds)) 
                              toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
}

- (BOOL) isFlipped {
    return YES;
}

- (void) setFrame:(NSRect)frameRect {
    frameRect.size.height = kDMBarHeight;       // enforce a "standard" height for the bar
    [super setFrame:frameRect];
}

@end
