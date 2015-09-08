//
//  DMTabBarItem.m
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMTabBarItem.h"

static CGFloat kDMTabBarItemGradientColor_Locations[] =     {0.0f, 0.5f, 1.0f};

#define kDMTabBarItemGradientColor1                         [NSColor colorWithCalibratedWhite:0.7f alpha:0.0f]
#define kDMTabBarItemGradientColor2                         [NSColor colorWithCalibratedWhite:0.7f alpha:1.0f]
#define kDMTabBarItemGradient                               [[NSGradient alloc] initWithColors: [NSArray arrayWithObjects: \
                                                                                                         kDMTabBarItemGradientColor1, \
                                                                                                         kDMTabBarItemGradientColor2, \
                                                                                                         kDMTabBarItemGradientColor1, nil] \
                                                                                   atLocations: kDMTabBarItemGradientColor_Locations \
                                                                                    colorSpace: [NSColorSpace genericGrayColorSpace]]


@interface NSImage (DMTabBar)

- (NSImage *)templateImageUsingTintColor:(NSColor *)tintColor;

@end

@implementation NSImage (DMTabBar)

- (NSImage *)templateImageUsingTintColor:(NSColor *)tintColor {
    CGFloat shadowOffset = 1.0f;
    CGFloat imageWidth = self.size.width;
    CGFloat imageHeight = self.size.height;
    CGFloat scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
    
    NSRect sourceRect = NSMakeRect(0,0,imageWidth,imageHeight);
    CGFloat dropShadowOffsetY = imageWidth <= 32.0 ? -1.0f : -2.0f;
    CGFloat innerShadowBlurRadius = (imageWidth * scaleFactor) <= 16.0f ? 1.5f :
    3.0f;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
    CGImageRef sourceMask =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    CGColorSpaceRef colorSpace =
    CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageWidth * scaleFactor,
                                                 (imageHeight + shadowOffset) *
                                                 scaleFactor,
                                                 8,
                                                 imageWidth * 4 * scaleFactor,
                                                 colorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    
    CFRelease(colorSpace);
    CGContextSetShouldAntialias(context, YES);
    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    CGContextTranslateCTM(context, 0.0f, 1.0f);
    
    // Outer Shadow
    CGContextSaveGState(context);
    {
        CGColorRef shadowColorRef = CGColorGetConstantColor(kCGColorWhite);
        CGColorRef alphaShadowColorRef = CGColorCreateCopyWithAlpha(shadowColorRef, 0.1f);
        CGContextSetShadowWithColor(context, CGSizeMake(0, dropShadowOffsetY), 0, alphaShadowColorRef);
        CFRelease(alphaShadowColorRef);
        CGContextDrawImage(context, sourceRect, sourceMask);
    }
    CGContextRestoreGState(context);

    // Fill the mask
    CGContextSaveGState(context);
    {
        CGFloat redComponent = 0.0f;
        CGFloat greenComponent = 0.0f;
        CGFloat blueComponent = 0.0f;
        CGFloat alphaComponent = 0.0f;
        [tintColor getRed:&redComponent
                    green:&greenComponent
                     blue:&blueComponent
                    alpha:&alphaComponent];
        
        CGContextClipToMask(context, sourceRect, sourceMask);
        CGContextSetRGBFillColor(context, redComponent, greenComponent, blueComponent, alphaComponent);
        CGContextFillRect(context, sourceRect);
    }
    CGContextRestoreGState(context);
    
    // Fill the gradient
    CGContextSaveGState(context);
    {
        CGFloat locations[2] = {0, 1};
        CGFloat startRed, startGreen, startBlue, startAlpha;
        CGFloat endRed, endGreen, endBlue, endAlpha;
        
        [[NSColor colorWithSRGBRed:1.0f green:1.0f blue:1.0f alpha:0.05]
         getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];
        [[NSColor colorWithSRGBRed:1.0f green:1.0f blue:1.0f alpha:0.2]
         getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
        
        CGFloat componnents[8] = {
            startRed, startGreen, startBlue, startAlpha,
            endRed, endGreen, endBlue, endAlpha
        };
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, componnents, locations, 2);
        CFRelease(colorSpace);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(sourceRect),
                                         CGRectGetMinY(sourceRect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(sourceRect),
                                       CGRectGetMaxY(sourceRect));
        CGContextClipToMask(context, sourceRect, sourceMask);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
        CFRelease(gradient);
    }
    CGContextRestoreGState(context);

    //Draw inner shadow with inverted mask
    CGContextSaveGState(context);
    {
        CGColorRef shadowColorRef = CGColorGetConstantColor(kCGColorWhite);
        CGColorRef alphaShadowColorRef =
        CGColorCreateCopyWithAlpha(shadowColorRef, 0.6f);
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), innerShadowBlurRadius, alphaShadowColorRef);
        CFRelease(alphaShadowColorRef);
        
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextDrawImage(context, sourceRect, sourceMask);
    }
    CGContextRestoreGState(context);
    
    CGImageRef retImageRef = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    NSImage *retImage = [[NSImage alloc] initWithCGImage:retImageRef
                                                    size:NSMakeSize(imageWidth, imageHeight + shadowOffset)];
    
    CFRelease(retImageRef);
    CFRelease(sourceMask);
    
    return retImage;
}

@end

@interface DMTabBarButtonCell : NSButtonCell { }
@end

@interface DMTabBarItem() {
    NSButton*       tabBarItemButton;
}
@end

@implementation DMTabBarItem

@synthesize enabled,icon,toolTip;
@synthesize tag;
@synthesize tabBarItemButton;
@synthesize state;

+ (DMTabBarItem *) tabBarItemWithIcon:(NSImage *) iconImage tag:(NSUInteger) itemTag {
    return [[DMTabBarItem alloc] initWithIcon:iconImage tag:itemTag];
}

- (id)initWithIcon:(NSImage *) iconImage tag:(NSUInteger) itemTag {
    self = [super init];
    if (self) {
        // Create associated NSButton to place inside the bar (it's customized by DMTabBarButtonCell with a special gradient for selected state)
        tabBarItemButton = [[NSButton alloc] initWithFrame:NSZeroRect];
        tabBarItemButton.cell = [[DMTabBarButtonCell alloc] init];

#if 1        
        //  Under Mavericks, you no longer get the blue icon tinting.  To work around this, we tint the image explicitly.
        tabBarItemButton.image = iconImage;
        tabBarItemButton.alternateImage = [iconImage templateImageUsingTintColor:[NSColor colorWithCalibratedRed:0.167 green:0.517 blue:1.000 alpha:1.000]];
        [tabBarItemButton.cell setShowsStateBy:NSContentsCellMask];
#endif
        [tabBarItemButton setEnabled:YES];
        tabBarItemButton.tag = itemTag;
        [tabBarItemButton sendActionOn:NSLeftMouseDownMask];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[DMTabBarItem] tag=%i - title=%@", (int)self.tag,self.title];
}

#pragma mark - Properties redirects

// We simply redirects properties to the the NSButton class

- (void) setIcon:(NSImage *)newIcon { 
    tabBarItemButton.image = newIcon;   
}

- (NSImage *) icon {   
    return tabBarItemButton.image;  
}

- (void) setTag:(NSUInteger)newTag {  
    tabBarItemButton.tag = newTag; 
}

- (NSUInteger) tag {  
    return tabBarItemButton.tag;    
}

- (void) setToolTip:(NSString *)newToolTip {   
    tabBarItemButton.toolTip = newToolTip;  
}

- (NSString *) toolTip {  
    return tabBarItemButton.toolTip;    
}

- (void) setKeyEquivalentModifierMask:(NSUInteger)newKeyEquivalentModifierMask {
    tabBarItemButton.keyEquivalentModifierMask = newKeyEquivalentModifierMask; 
}

- (NSUInteger) keyEquivalentModifierMask {
    return tabBarItemButton.keyEquivalentModifierMask; 
}

- (void) setKeyEquivalent:(NSString *)newKeyEquivalent {
    tabBarItemButton.keyEquivalent = newKeyEquivalent;
}

- (NSString *) keyEquivalent { 
    return tabBarItemButton.keyEquivalent;  
}

- (void) setState:(NSInteger)value {
    tabBarItemButton.state = value;
}

- (NSInteger) state {
    return tabBarItemButton.state;
}

@end


#pragma mark - DMTabBarButtonCell

@implementation DMTabBarButtonCell

- (id)init {
    self = [super init];
    if (self) {
        self.bezelStyle = NSTexturedRoundedBezelStyle;
    }
    return self;
}

- (NSInteger) nextState {
    return self.state;
}

- (void) drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
#if 0
    if (self.state == NSOnState) {
        // If selected we need to draw the border new background for selection (otherwise we will use default back color)
        // Save current context
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        // Draw light vertical gradient
        [kDMTabBarItemGradient drawInRect:frame angle:-90.0f];
        
        // Draw shadow on the left border of the item
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = NSMakeSize(1.0f, 0.0f);
        shadow.shadowBlurRadius = 2.0f;
        shadow.shadowColor = [NSColor darkGrayColor];
        [shadow set];
        
        [[NSColor blackColor] set];        
        CGFloat radius = 50.0;
        NSPoint center = NSMakePoint(NSMinX(frame) - radius, NSMidY(frame));
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:-90.0f endAngle:90.0f];
        [path closePath];
        [path fill];
        
        // shadow of the right border
        shadow.shadowOffset = NSMakeSize(-1.0f, 0.0f);
        [shadow set];
        
        center = NSMakePoint(NSMaxX(frame) + radius, NSMidY(frame));
        path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:90.0f  endAngle:270.0f];
        [path closePath];
        [path fill];
        
        // Restore context
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
#endif
}
@end
