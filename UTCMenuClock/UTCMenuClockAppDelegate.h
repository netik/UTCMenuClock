//
//  UTCMenuClockAppDelegate.h
//  UTCMenuClock
//
//  Created by John Adams on 11/14/11.
//  Copyright 2011 John Adams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UTCMenuClockAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSMenu *mainMenu;
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *mainMenu;

@end
