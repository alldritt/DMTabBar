//
//  DMBar.h
//  DMBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import <Cocoa/Cocoa.h>
#import "DMBar.h"


@interface DMBar : NSView {
    
}

@property (nonatomic,strong) NSColor *gradientColorStart;
@property (nonatomic,strong) NSColor *gradientColorEnd;
@property (nonatomic,strong) NSColor *borderColor;

@end
