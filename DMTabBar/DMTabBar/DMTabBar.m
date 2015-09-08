//
//  DMTabBar.m
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMTabBar.h"

// Default tabBar item width
#define kDMTabBarItemWidth                                  32.0f

@interface DMTabBar() {
    NSArray*                    tabBarItems;
    DMTabBarItem*               selectedTabBarItem_;
    DMTabBarEventsHandler       selectionHandler;
}

// Relayout button items
- (void) layoutSubviews;
// Remove all loaded button items
- (void) removeAllTabBarItems;
// Handle click on a single item (change selection, post event to the handler)
- (void) selectTabBarItem:(id)sender;

@end

@implementation DMTabBar

@synthesize selectedIndex,selectedTabBarItem;
@synthesize tabBarItems;

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    }
    return self;
}

- (void)dealloc {
    [self removeAllTabBarItems];
}

- (void) removeAllTabBarItems {
    [self.tabBarItems enumerateObjectsUsingBlock:^(DMTabBarItem* tabBarItem, NSUInteger idx, BOOL *stop) {
        [tabBarItem.tabBarItemButton removeFromSuperview];
    }];
    tabBarItems = nil;
}

- (void) handleTabBarItemSelection:(DMTabBarEventsHandler) newSelectionHandler {
    selectionHandler = newSelectionHandler;
}

- (void)selectTabBarItem:(id)sender {    
    __block NSUInteger itemIndex = NSNotFound;
    [self.tabBarItems enumerateObjectsUsingBlock:^(DMTabBarItem* tabBarItem, NSUInteger idx, BOOL *stop) {
        if (sender == tabBarItem.tabBarItemButton) {
            itemIndex = idx;
            *stop = YES;
        }
    }];
    if (itemIndex == NSNotFound) return;
    
    self.selectedTabBarItem = [self.tabBarItems objectAtIndex:itemIndex];
}

#pragma mark - Layout Subviews

- (void) resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutSubviews];
}

- (void) layoutSubviews {
    NSUInteger buttonsNumber = [self.tabBarItems count];
    CGFloat totalWidth = (buttonsNumber*kDMTabBarItemWidth);
    __block CGFloat offset_x = floorf((NSWidth(self.bounds)-totalWidth)/2.0f);
    [self.tabBarItems enumerateObjectsUsingBlock:^(DMTabBarItem* tabBarItem, NSUInteger idx, BOOL *stop) {
        tabBarItem.tabBarItemButton.frame = NSMakeRect(offset_x, NSMinY(self.bounds), kDMTabBarItemWidth, NSHeight(self.bounds));
        offset_x += kDMTabBarItemWidth;
    }];
}

- (void) setTabBarItems:(NSArray *)newTabBarItems {
    if (newTabBarItems != tabBarItems) {
        [self removeAllTabBarItems];
        tabBarItems = newTabBarItems;
        
        NSUInteger selectedItemIndex = [self.tabBarItems indexOfObject:self.selectedTabBarItem];
        NSUInteger itemIndex = 0;
        [self.tabBarItems enumerateObjectsUsingBlock:^(DMTabBarItem * tabBarItem, NSUInteger idx, BOOL *stop) {
            NSButton *itemButton = tabBarItem.tabBarItemButton;
            itemButton.frame = NSMakeRect(0.0f, 0.0f, kDMTabBarItemWidth, NSHeight(self.bounds));
            itemButton.state = (itemIndex == selectedItemIndex ? NSOnState : NSOffState);
            itemButton.action = @selector(selectTabBarItem:);
            itemButton.target = self;
            [self addSubview:itemButton];
        }];
        
        [self layoutSubviews];
        
        if (![self.tabBarItems containsObject:self.selectedTabBarItem])
            self.selectedTabBarItem = ([self.tabBarItems count] > 0 ? [self.tabBarItems objectAtIndex:0] : nil);
    }
}

- (DMTabBarItem *) selectedTabBarItem {
    return selectedTabBarItem_;
}

- (void) setSelectedTabBarItem:(DMTabBarItem *)newSelectedTabBarItem {
    if ([self.tabBarItems containsObject:newSelectedTabBarItem] == NO) return;
    
    NSUInteger selectedItemIndex = [self.tabBarItems indexOfObject:newSelectedTabBarItem];

    if (selectionHandler)
        selectionHandler(DMTabBarItemSelectionType_WillSelect,newSelectedTabBarItem,selectedItemIndex);
    selectedTabBarItem_ = newSelectedTabBarItem;
    
    __block NSUInteger buttonIndex = 0;
    [self.tabBarItems enumerateObjectsUsingBlock:^(DMTabBarItem* tabBarItem, NSUInteger idx, BOOL *stop) {
        tabBarItem.state = (buttonIndex == selectedItemIndex ? NSOnState : NSOffState);
        ++buttonIndex;
    }];

    if (selectionHandler)
        selectionHandler(DMTabBarItemSelectionType_DidSelect,newSelectedTabBarItem,selectedItemIndex);
}

- (NSUInteger) selectedIndex {
    return [self.tabBarItems indexOfObject:self.selectedTabBarItem];
}

- (void) setSelectedIndex:(NSUInteger)newSelectedIndex {
    if (newSelectedIndex != self.selectedIndex && newSelectedIndex < [self.tabBarItems count]) {
        self.selectedTabBarItem = [self.tabBarItems objectAtIndex:newSelectedIndex];
    }
}

@end
