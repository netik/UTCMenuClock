//
//  UTCMenuClockAppDelegate.h
//  UTCMenuClock
//
//  Created by John Adams on 11/14/11.
//  Copyright 2011 Twitter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UTCMenuClockAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
