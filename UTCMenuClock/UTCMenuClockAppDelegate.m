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
#import "LaunchAtLoginController.h"

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;
NSMenuItem   *dateMenuItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

}

- (void) quitProgram:(id)sender {
    // Cleanup here if necessary...
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) toggleLaunch:(id)sender {
    NSInteger state = [sender state];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];

    if (state == NSOffState) {
        [sender setState:NSOnState];
        [launchController setLaunchAtLogin:YES];
    } else {
        [sender setState:NSOffState];
        [launchController setLaunchAtLogin:NO];
    }

    [launchController release];
}

- (BOOL) fetchBooleanPreference:(NSString *)preference {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [standardUserDefaults boolForKey:preference];
    return value;
}

- (void) togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender title];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    preference = [preference stringByReplacingOccurrencesOfString:@" "
                                                withString:@""];
    if (state == NSOffState) {
        [sender setState:NSOnState];
        [standardUserDefaults setBool:TRUE forKey:preference];
    } else {
        [sender setState:NSOffState];
        [standardUserDefaults setBool:FALSE forKey:preference];
    }

}

- (void) openGithubURL:(id)sender {
    [[NSWorkspace sharedWorkspace]
        openURL:[NSURL URLWithString:@"http://github.com/netik/UTCMenuClock"]];
}

- (void) doDateUpdate {

    NSDate* date = [NSDate date];
    NSDateFormatter* UTCdf = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateShortDF = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];

    [UTCdf setTimeZone: UTCtz];
    [UTCdateDF setTimeZone: UTCtz];
    [UTCdateShortDF setTimeZone: UTCtz];

    BOOL showDate = [self fetchBooleanPreference:@"ShowDate"];
    BOOL showSeconds = [self fetchBooleanPreference:@"ShowSeconds"];
    if (showSeconds){
        [UTCdf setDateFormat: @"HH:mm:ss"];
    } else {
        [UTCdf setDateFormat: @"HH:mm"];
    }

    [UTCdateDF setDateStyle:NSDateFormatterFullStyle];
    [UTCdateShortDF setDateStyle:NSDateFormatterShortStyle];

    NSString* UTCtimepart = [UTCdf stringFromDate: date];
    NSString* UTCdatepart = [UTCdateDF stringFromDate: date];
    NSString* UTCdateShort = [UTCdateShortDF stringFromDate: date];

    if (showDate) {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@ %@ UTC", UTCdateShort, UTCtimepart]];
    } else {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@ UTC",UTCtimepart]];
    }

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

    NSMenuItem *cp1Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp2Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp3Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *quitItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *launchItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showDateItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showSecondsItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *sep1Item = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];
    NSMenuItem *sep3Item = [NSMenuItem separatorItem];

    [mainItem setTitle:@""];

    [cp1Item setTitle:@"UTC Menu Clock v1.0b"];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp3Item setTitle:@"http://github.com/netik/UTCMenuClock"];

    [cp3Item setEnabled:TRUE];
    [cp3Item setAction:@selector(openGithubURL:)];

    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:TRUE];
    [launchItem setAction:@selector(toggleLaunch:)];

    [showDateItem setTitle:@"Show Date"];
    [showDateItem setEnabled:TRUE];
    [showDateItem setAction:@selector(togglePreference:)];

    [showSecondsItem setTitle:@"Show Seconds"];
    [showSecondsItem setEnabled:TRUE];
    [showSecondsItem setAction:@selector(togglePreference:)];

    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];

    [mainMenu addItem:mainItem];
    // "---"
    [mainMenu addItem:sep2Item];
    // "---"
    [mainMenu addItem:cp1Item];
    [mainMenu addItem:cp2Item];
    // "---"
    [mainMenu addItem:sep1Item];
    [mainMenu addItem:cp3Item];
    // "---"
    [mainMenu addItem:sep3Item];

    // showDateItem
    BOOL showDate = [self fetchBooleanPreference:@"ShowDate"];
    BOOL showSeconds = [self fetchBooleanPreference:@"ShowSeconds"];

    if (showDate) {
        [showDateItem setState:NSOnState];
    } else {
        [showDateItem setState:NSOffState];
    }

    if (showSeconds) {
        [showSecondsItem setState:NSOnState];
    } else {
        [showSecondsItem setState:NSOffState];
    }

    // latsly, deal with Launch at Login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [launchController release];

    if (launch) {
        [launchItem setState:NSOnState];
    } else {
        [launchItem setState:NSOffState];
    }

    [mainMenu addItem:launchItem];
    [mainMenu addItem:showDateItem];
    [mainMenu addItem:showSecondsItem];
    [mainMenu addItem:quitItem];

    [theItem setMenu:(NSMenu *)mainMenu];


    // Update the date immediately after setup so that there is no timer lag
    [self doDateUpdate];

    NSNumber *myInt = [NSNumber numberWithInt:1];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:myInt repeats:YES];


}

@end
