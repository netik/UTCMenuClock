//
// UTCMenuClockAppDelegate.m
// UTCMenuClock
//
// Created by John Adams on 11/14/11.
//
// Copyright 2011-2022 John Adams <jna@retina.net>
//
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

static NSString *const showDatePreferenceKey = @"ShowDate";
static NSString *const showSecondsPreferenceKey = @"ShowSeconds";
static NSString *const showJulianDatePreferenceKey = @"ShowJulianDate";
static NSString *const showTimeZonePreferenceKey = @"ShowTimeZone";
static NSString *const show24HourPreferenceKey = @"24HRTime";
static NSString *const showISO8601PreferenceKey = @"ISO8601";

/* Some app constants go here */
static NSString *const GITHUB_URL = @"http://github.com/netik/UTCMenuClock";

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;

// make this global so other functions can manipulate menu elements.
NSMenuItem *dateMenuItem;
NSMenuItem *showTimeZoneItem;
NSMenuItem *show24Item;
NSMenuItem *showDateItem;
NSMenuItem *showSecondsItem;
NSMenuItem *showJulianItem;
NSMenuItem *showTimeZoneItem;

/*!
 @brief Exits the app
 */
- (void) quitProgram:(id)sender {
    // Cleanup here if necessary...
    [[NSApplication sharedApplication] terminate:nil];
}

/*!
 @brief Flips the user preference that starts the application at launch.
 */
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

/*!
 @brief Returns a preference's setting based on the key
 @param preference The preference to retrieve as an NSString
 @return boolean from the preference list
 */
- (BOOL) fetchBooleanPreference:(NSString *)preference {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [standardUserDefaults boolForKey:preference];
    return value;
}

/*!
 @brief Flips the user preference that starts the application at launch.
 @param sender The menu component to change
 */
- (void) togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender representedObject];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (state == NSOffState) {
        [sender setState:NSOnState];
        [standardUserDefaults setBool:TRUE forKey:preference];
    } else {
        [sender setState:NSOffState];
        [standardUserDefaults setBool:FALSE forKey:preference];
    }
    
}

/*!
 @brief Flips the user preference that starts the application at launch.
 @param sender The menu component to change
 */
- (void) toggleISOPreference:(id)sender {
    NSInteger state = [sender state];
    
    [self togglePreference:sender];
    
    if (state == NSOffState) {
        // disable all of the menu items which are not related to ISO state
        [show24Item setEnabled:FALSE];
        [showDateItem setEnabled:FALSE];
        [showSecondsItem setEnabled:FALSE];
        [showJulianItem setEnabled:FALSE];
        [showTimeZoneItem setEnabled:FALSE];

    } else {
        // enable all of the menu items which are not related to ISO state
        [show24Item setEnabled:TRUE];
        [showDateItem setEnabled:TRUE];
        [showSecondsItem setEnabled:TRUE];
        [showJulianItem setEnabled:TRUE];
        [showTimeZoneItem setEnabled:TRUE];
    }
    
}


/*!
 @brief Copies the current date and time to the pasteboard based on user preferences
 */
- (void) copyToPasteboard {
    NSString *dateString = [self makeDateString];

    // Set string
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:dateString forType:NSPasteboardTypeString];
}

/*!
 @brief Copies the current date and time to the pasteboard as an ISO8601 date
 */
- (void) copyIS08601ToPasteboard {
    NSString *dateString = [self makeISO8601DateString];

    // Set string
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:dateString forType:NSPasteboardTypeString];
}

/*!
 @brief Opens the github URL in the default Browser where the source code lives
 */
- (void) openGithubURL:(id)sender {
    [[NSWorkspace sharedWorkspace]
     openURL:[NSURL URLWithString:GITHUB_URL]];
}

/*!
 @brief Formats the current date as an ISO8601 date string
 @return NSString the date as a string
 */
- (NSString *) makeISO8601DateString {
    NSDate* date = [NSDate date];
    NSISO8601DateFormatter* UTCiso = [[[NSISO8601DateFormatter alloc] init] autorelease];
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [UTCiso setTimeZone: UTCtz];
    return [UTCiso stringFromDate: date];
    
}
/*!
 @brief Formats the current date based on the user's preferences
 @return NSString the date as a string
 */
- (NSString *) makeDateString {
    NSDate* date = [NSDate date];
    NSDateFormatter* UTCdf = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateShortDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdaynum = [[[NSDateFormatter alloc] init] autorelease];
    
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    [UTCdf setTimeZone: UTCtz];
    [UTCdateDF setTimeZone: UTCtz];
    [UTCdateShortDF setTimeZone: UTCtz];
    [UTCdaynum setTimeZone: UTCtz];
    
    BOOL showDate = [self fetchBooleanPreference:showDatePreferenceKey];
    BOOL showSeconds = [self fetchBooleanPreference:showSecondsPreferenceKey];
    BOOL showJulian = [self fetchBooleanPreference:showJulianDatePreferenceKey];
    BOOL showTimeZone = [self fetchBooleanPreference:showTimeZonePreferenceKey];
    BOOL show24HrTime = [self fetchBooleanPreference:show24HourPreferenceKey];
    BOOL showISO8601 = [self fetchBooleanPreference:showISO8601PreferenceKey];

    // a side effect of this function is that we also update the menu with the proper UTC date.
    [UTCdateDF setDateStyle:NSDateFormatterFullStyle];
    [UTCdateShortDF setDateStyle:NSDateFormatterShortStyle];
    [UTCdaynum setDateFormat:@"D/"];
    NSString* UTCdatepart = [UTCdateDF stringFromDate: date];

    [dateMenuItem setTitle:UTCdatepart];
    
    // showISO8601 overrides everything...
    if (showISO8601) {
        NSString *dateString = [self makeISO8601DateString];
        return dateString;
    }
    
    if (showSeconds) {
        if (show24HrTime){
            [UTCdf setDateFormat: @"HH:mm:ss"];
        } else {
            [UTCdf setDateFormat: @"hh:mm:ss a"];
        }
    } else {
        if (show24HrTime){
            [UTCdf setDateFormat: @"HH:mm"];
        } else {
            [UTCdf setDateFormat: @"hh:mm a"];
        }
    }

    NSString* UTCtimepart = [UTCdf stringFromDate: date];
    NSString* UTCdateShort = [UTCdateShortDF stringFromDate: date];
    NSString* UTCJulianDay;
    NSString* UTCTzString;
        
    if (showJulian) {
        UTCJulianDay = [UTCdaynum stringFromDate: date];
    } else {
        UTCJulianDay = @"";
    }
    
    if (showTimeZone) {
        UTCTzString = @" UTC";
    } else {
        UTCTzString = @"";
    }
    
    if (showDate) {
        return [NSString stringWithFormat:@"%@ %@%@%@", UTCdateShort, UTCJulianDay, UTCtimepart, UTCTzString];
    } else {
        return [NSString stringWithFormat:@"%@%@%@", UTCJulianDay, UTCtimepart, UTCTzString];
    }
    
}

/*!
 @brief updates the date in the menu bar
 */
- (void) doDateUpdate {
    NSString *dateString = [self makeDateString];
    [ourStatus setTitle:dateString];
    
}

// Unused for now... need to finish.
- (IBAction)showFontMenu:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel makeKeyAndOrderFront:sender];
}

/*!
 @brief Fires every one second to update the clock
 */
- (void) fireTimer:(NSTimer*)theTimer {
    [self doDateUpdate];
}

- (id)init {
    if (self = [super init]) {
        // set our default preferences at each launch.
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appDefaults = @{showTimeZonePreferenceKey: @YES,
                                      show24HourPreferenceKey: @YES,
                                      showJulianDatePreferenceKey: @NO,
                                      showDatePreferenceKey: @NO,
                                      showSecondsPreferenceKey: @NO};
        [standardUserDefaults registerDefaults:appDefaults];
        NSString *dateKey    = @"dateKey";
        //Remove old, outdated date key
        [standardUserDefaults removeObjectForKey:dateKey];
    }
    return self;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self doDateUpdate];
}

/*!
 @brief Runs right after the nib loads
*/
- (void)awakeFromNib
{
    mainMenu = [[NSMenu alloc] init];

    // Disable auto enable
    [mainMenu setAutoenablesItems:NO];

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
    [mainItem setEnabled: NO];
    
    NSMenuItem *cp1Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp2Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp3Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *quitItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *copyItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *copy2Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *launchItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showISO8601Item = [[[NSMenuItem alloc] init] autorelease];

    // date specific items
    showDateItem = [[[NSMenuItem alloc] init] autorelease];
    show24Item = [[[NSMenuItem alloc] init] autorelease];
    showSecondsItem = [[[NSMenuItem alloc] init] autorelease];
    showJulianItem = [[[NSMenuItem alloc] init] autorelease];
    showTimeZoneItem = [[[NSMenuItem alloc] init] autorelease];


    //   NSMenuItem *changeFontItem = [[[NSMenuItem alloc] init] autorelease];

    // Every menu separator must be it's own element.
    NSMenuItem *sep1Item = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];
    NSMenuItem *sep3Item = [NSMenuItem separatorItem];
    NSMenuItem *sep4Item = [NSMenuItem separatorItem];
    NSMenuItem *sep5Item = [NSMenuItem separatorItem];

    // Build all of the individual elements in the menu
    [mainItem setTitle:@""];
    
    [copyItem setTitle:@"Copy"];
    [copyItem setEnabled:TRUE];
    [copyItem setAction:@selector(copyToPasteboard)];
    
    [copy2Item setTitle:@"Copy as ISO-8601"];
    [copy2Item setEnabled:TRUE];
    [copy2Item setAction:@selector(copyIS08601ToPasteboard)];
    
    [cp3Item setEnabled:TRUE];
    [cp3Item setAction:@selector(openGithubURL:)];
    
    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:TRUE];
    [launchItem setAction:@selector(toggleLaunch:)];
    
    [show24Item setTitle:@"24 HR Time"];
    [show24Item setEnabled:TRUE];
    [show24Item setAction:@selector(togglePreference:)];
    [show24Item setRepresentedObject:show24HourPreferenceKey];
    
    [showDateItem setTitle:@"Show Date"];
    [showDateItem setEnabled:TRUE];
    [showDateItem setAction:@selector(togglePreference:)];
    [showDateItem setRepresentedObject:showDatePreferenceKey];
    
    [showSecondsItem setTitle:@"Show Seconds"];
    [showSecondsItem setEnabled:TRUE];
    [showSecondsItem setAction:@selector(togglePreference:)];
    [showSecondsItem setRepresentedObject:showSecondsPreferenceKey];
    
    [showJulianItem setTitle:@"Show Julian Date"];
    [showJulianItem setEnabled:TRUE];
    [showJulianItem setAction:@selector(togglePreference:)];
    [showJulianItem setRepresentedObject:showJulianDatePreferenceKey];
    
    [showTimeZoneItem setTitle:@"Show Time Zone"];
    [showTimeZoneItem setEnabled:TRUE];
    [showTimeZoneItem setAction:@selector(togglePreference:)];
    [showTimeZoneItem setRepresentedObject:showTimeZonePreferenceKey];

    [showISO8601Item setTitle:@"Show ISO8601 Instead"];
    [showISO8601Item setEnabled:TRUE];
    [showISO8601Item setAction:@selector(toggleISOPreference:)];
    [showISO8601Item setRepresentedObject:showISO8601PreferenceKey];
    
    //   [changeFontItem setTitle:@"Change Font..."];
    //  [changeFontItem setAction:@selector(showFontMenu:)];
    
    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];
    
    // promo junk (menu bottom)
    [cp1Item setTitle:@"UTC Menu Clock v1.3"];
    [cp1Item setEnabled:FALSE];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp2Item setEnabled:FALSE];
    [cp3Item setTitle:@"http://github.com/netik/UTCMenuClock"];
    [cp3Item setEnabled:FALSE];

    // the full menu gets built here.
    [mainMenu addItem:mainItem];
    // "---"
    [mainMenu addItem:sep1Item];
    // Copy section
    [mainMenu addItem:copyItem];
    [mainMenu addItem:copy2Item];
    // "---"
    [mainMenu addItem:sep2Item];

    // Preferences area
    BOOL showDate = [self fetchBooleanPreference:showDatePreferenceKey];
    BOOL showSeconds = [self fetchBooleanPreference:showSecondsPreferenceKey];
    BOOL showJulian = [self fetchBooleanPreference:showJulianDatePreferenceKey];
    BOOL showTimeZone = [self fetchBooleanPreference:showTimeZonePreferenceKey];
    BOOL show24HrTime = [self fetchBooleanPreference:show24HourPreferenceKey];
    BOOL showISOInstead = [self fetchBooleanPreference:showISO8601PreferenceKey];

    // set the menu states based on the preferences
    [show24Item setState:show24HrTime ? NSOnState : NSOffState];
    [showDateItem setState:showDate ? NSOnState : NSOffState];
    [showSecondsItem setState:showSeconds ? NSOnState : NSOffState];
    [showJulianItem setState:showJulian ? NSOnState : NSOffState];
    [showTimeZoneItem setState:showTimeZone ? NSOnState : NSOffState];
    
    if (showISOInstead) {
        [showISO8601Item setState:NSOnState];
        
        // disable all of the menu items which are not related to ISO state
        [show24Item setEnabled:FALSE];
        [showDateItem setEnabled:FALSE];
        [showSecondsItem setEnabled:FALSE];
        [showJulianItem setEnabled:FALSE];
        [showTimeZoneItem setEnabled:FALSE];
    
    } else {
        [showISO8601Item setState:NSOffState];

        // enable all of the menu items which are not related to ISO state
        [show24Item setEnabled:TRUE];
        [showDateItem setEnabled:TRUE];
        [showSecondsItem setEnabled:TRUE];
        [showJulianItem setEnabled:TRUE];
        [showTimeZoneItem setEnabled:TRUE];
    }
    
    // latsly, deal with Launch at Login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [launchController release];
    
    [launchItem setState:launch ? NSOnState : NSOffState];
    
    [mainMenu addItem:launchItem];
    [mainMenu addItem:show24Item];
    [mainMenu addItem:showDateItem];
    [mainMenu addItem:showSecondsItem];
    [mainMenu addItem:showJulianItem];
    [mainMenu addItem:showTimeZoneItem];
    [mainMenu addItem:showISO8601Item];
    //  [mainMenu addItem:changeFontItem];
    // "---"
    [mainMenu addItem:sep3Item];
    [mainMenu addItem:quitItem];
    
    // promo stuff
    [mainMenu addItem:sep4Item];
    // "---"
    [mainMenu addItem:cp1Item];
    [mainMenu addItem:cp2Item];
    [mainMenu addItem:sep5Item];
    [mainMenu addItem:cp3Item];

    [theItem setMenu:(NSMenu *)mainMenu];
    
    // Update the date immediately after our setup so that there is no timer lag
    [self doDateUpdate];
    
    // Schedule the timer
    NSNumber *myInt = [NSNumber numberWithInt:1];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:myInt repeats:YES];
}

@end
