//
//  UTCMenuClockAppDelegate.m
//  UTCMenuClock
//
//  Created by John Adams on 11/14/11.
//
// Copyright 2011 John Adams
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UTCMenuClockAppDelegate.h"

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;
NSMenuItem   *dateMenuItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}

- (void) quitProgram:(id)sender {
    // Cleanup here if necessary... 
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) openGithubURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/netik/UTCMenuClock"]];
}

- (void) doDateUpdate {
    
    NSDate* date = [NSDate date];
    NSDateFormatter* UTCdateDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdf = [[[NSDateFormatter alloc] init] autorelease];
    
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    [UTCdf setTimeZone: UTCtz];
    [UTCdateDF setTimeZone: UTCtz];
    
    [UTCdf setDateFormat: @"HH:mm:ss"];
    [UTCdateDF setDateFormat: @"MM-dd-YYYY"];
    
    NSString* UTCtimepart = [UTCdf stringFromDate: date];
    NSString* UTCdatepart = [UTCdateDF stringFromDate: date];
    
    [ourStatus setTitle:[NSString stringWithFormat:@"%@ UTC",UTCtimepart]];
    [dateMenuItem setTitle:UTCdatepart]; 
}

// this is the main work loop, fired on 1s intervals.
- (void) fireTimer:(NSTimer*)theTimer {
    [self doDateUpdate];
}

- (void)awakeFromNib
{
    mainMenu = [[NSMenu alloc] init];
    
    //Create Image for menu item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *theItem;
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    // retain a reference to the item so we don't have to find it again
    ourStatus = theItem;
    
    //Set Image
    //[theItem setImage:(NSImage *)menuicon];
    [theItem setTitle:@""];
    
    //Make it turn blue when you click on it
    [theItem setHighlightMode:YES];
    [theItem setEnabled: YES];

    // build the menu
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    dateMenuItem = mainItem;
    
    NSMenuItem *cp1Item = [[NSMenuItem alloc] init];
    NSMenuItem *cp2Item = [[NSMenuItem alloc] init];
    NSMenuItem *cp3Item = [[NSMenuItem alloc] init];
    NSMenuItem *quitItem = [[NSMenuItem alloc] init];
    NSMenuItem *sepItem = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];

    [mainItem setTitle:@""];
    
    [cp1Item setTitle:@"UTC Menu Clock v1.0"];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp3Item setTitle:@"http://github.com/netik/UTCMenuClock"];

    [cp3Item setEnabled:TRUE];
    [cp3Item setAction:@selector(openGithubURL:)];

    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];
    
    [mainMenu addItem:mainItem];
    // "---"
    [mainMenu addItem:sepItem];
    // "---"
    [mainMenu addItem:cp1Item];
    [mainMenu addItem:cp2Item];
    [mainMenu addItem:cp3Item];
    // "---"
    [mainMenu addItem:sep2Item];
    // "---"
    [mainMenu addItem:quitItem];
    
    [theItem setMenu:(NSMenu *)mainMenu];

    // Update the date immediately after setup so that there is no timer lag
    [self doDateUpdate];
    
    NSNumber *myInt = [NSNumber numberWithInt:1];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:myInt repeats:YES];
    
}

@end
