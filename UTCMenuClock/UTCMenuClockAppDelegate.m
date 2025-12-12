//
// UTCMenuClockAppDelegate.m
// UTCMenuClock
//
// Created by John Adams on 11/14/11.
//
// Copyright 2011-2025 John Adams <jna@retina.net>
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
    
    if (state == NSControlStateValueOff) {
        [sender setState:NSControlStateValueOn];
        [launchController setLaunchAtLogin:YES];
    } else {
        [sender setState:NSControlStateValueOff];
        [launchController setLaunchAtLogin:NO];
    }
    
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
    
    if (state == NSControlStateValueOff) {
        [sender setState:NSControlStateValueOn];
        [standardUserDefaults setBool:YES forKey:preference];
    } else {
        [sender setState:NSControlStateValueOff];
        [standardUserDefaults setBool:NO forKey:preference];
    }
    [self scheduleTimer];
}

/*!
 @brief Flips the user preference that starts the application at launch.
 @param sender The menu component to change
 */
- (void) toggleISOPreference:(id)sender {
    NSInteger state = [sender state];
    
    [self togglePreference:sender];
    
    if (state == NSControlStateValueOff) {
        // disable all of the menu items which are not related to ISO state
        [_show24Item setEnabled:NO];
        [_showDateItem setEnabled:NO];
        [_showSecondsItem setEnabled:NO];
        [_showJulianItem setEnabled:NO];
        [_showTimeZoneItem setEnabled:NO];

    } else {
        // enable all of the menu items which are not related to ISO state
        [_show24Item setEnabled:YES];
        [_showDateItem setEnabled:YES];
        [_showSecondsItem setEnabled:YES];
        [_showJulianItem setEnabled:YES];
        [_showTimeZoneItem setEnabled:YES];
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
    NSISO8601DateFormatter* UTCiso = [[NSISO8601DateFormatter alloc] init];
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
    NSDateFormatter* UTCdf = [[NSDateFormatter alloc] init];
    NSDateFormatter* UTCdateDF = [[NSDateFormatter alloc] init];
    NSDateFormatter* UTCdateShortDF = [[NSDateFormatter alloc] init];
    NSDateFormatter* UTCdaynum = [[NSDateFormatter alloc] init];
    
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

    [_dateMenuItem setTitle:UTCdatepart];
    
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
    _statusItem.button.title = dateString;
}

// Unused for now... need to finish.
- (IBAction)showFontMenu:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel makeKeyAndOrderFront:sender];
}

/*!
 @brief Fires to update the clock
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
    _mainMenu = [[NSMenu alloc] init];

    // Disable auto enable
    [_mainMenu setAutoenablesItems:NO];

    //Create Image for menu item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *theItem;
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    // while some day we may want more customizable font selection, for now
    // set the system font to use fixed-width digits
    theItem.button.font = [NSFont monospacedDigitSystemFontOfSize:NSFont.systemFontSize weight:NSFontWeightRegular];
    // retain a reference to the item so we don't have to find it again
    _statusItem = theItem;
    
    // build the menu
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    _dateMenuItem = mainItem;
    [mainItem setEnabled:NO];
    
    NSMenuItem *cp1Item = [[NSMenuItem alloc] init];
    NSMenuItem *cp2Item = [[NSMenuItem alloc] init];
    NSMenuItem *cp3Item = [[NSMenuItem alloc] init];
    NSMenuItem *quitItem = [[NSMenuItem alloc] init];
    NSMenuItem *copyItem = [[NSMenuItem alloc] init];
    NSMenuItem *copy2Item = [[NSMenuItem alloc] init];
    NSMenuItem *launchItem = [[NSMenuItem alloc] init];
    NSMenuItem *showISO8601Item = [[NSMenuItem alloc] init];

    // date specific items
    _showDateItem = [[NSMenuItem alloc] init];
    _show24Item = [[NSMenuItem alloc] init];
    _showSecondsItem = [[NSMenuItem alloc] init];
    _showJulianItem = [[NSMenuItem alloc] init];
    _showTimeZoneItem = [[NSMenuItem alloc] init];


    //   NSMenuItem *changeFontItem = [[NSMenuItem alloc] init];

    // Every menu separator must be it's own element.
    NSMenuItem *sep1Item = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];
    NSMenuItem *sep3Item = [NSMenuItem separatorItem];
    NSMenuItem *sep4Item = [NSMenuItem separatorItem];
    NSMenuItem *sep5Item = [NSMenuItem separatorItem];

    // Build all of the individual elements in the menu
    [mainItem setTitle:@""];
    
    [copyItem setTitle:@"Copy"];
    [copyItem setEnabled:YES];
    [copyItem setAction:@selector(copyToPasteboard)];
    
    [copy2Item setTitle:@"Copy as ISO-8601"];
    [copy2Item setEnabled:YES];
    [copy2Item setAction:@selector(copyIS08601ToPasteboard)];
    
    [cp3Item setEnabled:YES];
    [cp3Item setAction:@selector(openGithubURL:)];
    
    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:YES];
    [launchItem setAction:@selector(toggleLaunch:)];
    
    [_show24Item setTitle:@"24 HR Time"];
    [_show24Item setEnabled:YES];
    [_show24Item setAction:@selector(togglePreference:)];
    [_show24Item setRepresentedObject:show24HourPreferenceKey];
    
    [_showDateItem setTitle:@"Show Date"];
    [_showDateItem setEnabled:YES];
    [_showDateItem setAction:@selector(togglePreference:)];
    [_showDateItem setRepresentedObject:showDatePreferenceKey];
    
    [_showSecondsItem setTitle:@"Show Seconds"];
    [_showSecondsItem setEnabled:YES];
    [_showSecondsItem setAction:@selector(togglePreference:)];
    [_showSecondsItem setRepresentedObject:showSecondsPreferenceKey];
    
    [_showJulianItem setTitle:@"Show Julian Date"];
    [_showJulianItem setEnabled:YES];
    [_showJulianItem setAction:@selector(togglePreference:)];
    [_showJulianItem setRepresentedObject:showJulianDatePreferenceKey];
    
    [_showTimeZoneItem setTitle:@"Show Time Zone"];
    [_showTimeZoneItem setEnabled:YES];
    [_showTimeZoneItem setAction:@selector(togglePreference:)];
    [_showTimeZoneItem setRepresentedObject:showTimeZonePreferenceKey];

    [showISO8601Item setTitle:@"Show ISO8601 Instead"];
    [showISO8601Item setEnabled:YES];
    [showISO8601Item setAction:@selector(toggleISOPreference:)];
    [showISO8601Item setRepresentedObject:showISO8601PreferenceKey];
    
    //   [changeFontItem setTitle:@"Change Font..."];
    //  [changeFontItem setAction:@selector(showFontMenu:)];
    
    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:YES];
    [quitItem setAction:@selector(quitProgram:)];
    
    // promo junk (menu bottom)
    [cp1Item setTitle:@"UTC Menu Clock v1.4"];
    [cp1Item setEnabled:NO];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp2Item setEnabled:NO];
    [cp3Item setTitle:@"http://github.com/netik/UTCMenuClock"];
    [cp3Item setEnabled:NO];

    // the full menu gets built here.
    [_mainMenu addItem:mainItem];
    // "---"
    [_mainMenu addItem:sep1Item];
    // Copy section
    [_mainMenu addItem:copyItem];
    [_mainMenu addItem:copy2Item];
    // "---"
    [_mainMenu addItem:sep2Item];

    // Preferences area
    BOOL showDate = [self fetchBooleanPreference:showDatePreferenceKey];
    BOOL showSeconds = [self fetchBooleanPreference:showSecondsPreferenceKey];
    BOOL showJulian = [self fetchBooleanPreference:showJulianDatePreferenceKey];
    BOOL showTimeZone = [self fetchBooleanPreference:showTimeZonePreferenceKey];
    BOOL show24HrTime = [self fetchBooleanPreference:show24HourPreferenceKey];
    BOOL showISOInstead = [self fetchBooleanPreference:showISO8601PreferenceKey];

    // set the menu states based on the preferences
    [_show24Item setState:show24HrTime ? NSControlStateValueOn : NSControlStateValueOff];
    [_showDateItem setState:showDate ? NSControlStateValueOn : NSControlStateValueOff];
    [_showSecondsItem setState:showSeconds ? NSControlStateValueOn : NSControlStateValueOff];
    [_showJulianItem setState:showJulian ? NSControlStateValueOn : NSControlStateValueOff];
    [_showTimeZoneItem setState:showTimeZone ? NSControlStateValueOn : NSControlStateValueOff];
    
    if (showISOInstead) {
        [showISO8601Item setState:NSControlStateValueOn];
        
        // disable all of the menu items which are not related to ISO state
        [_show24Item setEnabled:NO];
        [_showDateItem setEnabled:NO];
        [_showSecondsItem setEnabled:NO];
        [_showJulianItem setEnabled:NO];
        [_showTimeZoneItem setEnabled:NO];
    
    } else {
        [showISO8601Item setState:NSControlStateValueOff];

        // enable all of the menu items which are not related to ISO state
        [_show24Item setEnabled:YES];
        [_showDateItem setEnabled:YES];
        [_showSecondsItem setEnabled:YES];
        [_showJulianItem setEnabled:YES];
        [_showTimeZoneItem setEnabled:YES];
    }
    
    // Lastly, deal with Launch at Login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    
    [launchItem setState:launch ? NSControlStateValueOn : NSControlStateValueOff];
    
    [_mainMenu addItem:launchItem];
    [_mainMenu addItem:_show24Item];
    [_mainMenu addItem:_showDateItem];
    [_mainMenu addItem:_showSecondsItem];
    [_mainMenu addItem:_showJulianItem];
    [_mainMenu addItem:_showTimeZoneItem];
    [_mainMenu addItem:showISO8601Item];
    //  [_mainMenu addItem:changeFontItem];
    // "---"
    [_mainMenu addItem:sep3Item];
    [_mainMenu addItem:quitItem];
    
    // promo stuff
    [_mainMenu addItem:sep4Item];
    // "---"
    [_mainMenu addItem:cp1Item];
    [_mainMenu addItem:cp2Item];
    [_mainMenu addItem:sep5Item];
    [_mainMenu addItem:cp3Item];

    [theItem setMenu:_mainMenu];
    
    [self scheduleTimer];
}

- (void)scheduleTimer {
    // Invalidate and dealloc old timer
    [_timer invalidate];
    _timer = nil;
    
    // Update the date immediately
    [self doDateUpdate];

    // Get the current date components (without ms)
    NSDateComponents *startUnits = [[NSCalendar currentCalendar] components:
                                    (NSCalendarUnitYear |
                                     NSCalendarUnitMonth |
                                     NSCalendarUnitDay |
                                     NSCalendarUnitHour |
                                     NSCalendarUnitMinute |
                                     NSCalendarUnitSecond)
                                                                   fromDate: [NSDate date]];

    NSTimeInterval interval;
    NSTimeInterval tolerance;
    
    // Schedule the timer
    if ([self fetchBooleanPreference:showSecondsPreferenceKey]) {
        // Update every 1 second with 50ms of tolerance to allow for CPU sleep
        // (Chosen arbitrarily: 100ms of tolerance makes the updates visibly irregular, 50ms looks fine)
        
        // Start at the next whole second
        [startUnits setSecond:[startUnits second] + 1.0];

        interval = 1.0;
        tolerance = 0.05;
    } else {
        // If we're not showing seconds, set the timer to fire at the next whole minute then every 60 seconds
        [startUnits setSecond:0];
        [startUnits setMinute:[startUnits minute] + 1.0];
        
        // Update every 60 seconds with 500ms of tolerance
        interval = 60.0;
        tolerance = 0.5;
    }
    
    // Set up wake notifications to reset the timer after sleep
    [self fileNotifications];

    NSDate *startDateTime = [[NSCalendar currentCalendar] dateFromComponents:startUnits];
    _timer = [[NSTimer alloc] initWithFireDate:startDateTime interval:interval target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    _timer.tolerance = tolerance;
    
    // Schedule the timer
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)receiveWakeNote: (NSNotification*) note
{
    // When the machine wakes from sleep, reset our timer to make sure we're still running on the second/minute
    [self scheduleTimer];
}
 
- (void)fileNotifications
{
    // https://developer.apple.com/library/archive/qa/qa1340/_index.html
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
            selector: @selector(receiveWakeNote:)
            name: NSWorkspaceDidWakeNotification object: nil];
}

- (void)dealloc
{
    // Remove notification observer
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    // Invalidate timer (ARC handles the release)
    [_timer invalidate];
}

@end
