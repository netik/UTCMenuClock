//
// UTCMenuClockAppDelegate.m
// UTCMenuClock
//
// Created by John Adams on 11/14/11.
//
// Copyright 2011-2026 John Adams <jna@retina.net>
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
#import "UTCDateDisplayFormatter.h"
#import "UTCMenuClockPreferences.h"

static NSString *const GITHUB_URL = @"https://github.com/netik/UTCMenuClock";

@implementation UTCMenuClockAppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        [UTCMenuClockPreferences registerDefaults];
        _dateFormatter = [[UTCDateDisplayFormatter alloc] init];
        [self refreshDateFormatterPreferences];
    }
    return self;
}

- (void)refreshDateFormatterPreferences {
    [self.dateFormatter updatePreferences:[UTCMenuClockPreferences currentPreferences]];
}

- (BOOL)fetchBooleanPreference:(NSString *)preference {
    return [NSUserDefaults.standardUserDefaults boolForKey:preference];
}

- (void)quitProgram:(id)sender {
    [NSApplication.sharedApplication terminate:nil];
}

- (void)toggleLaunch:(id)sender {
    BOOL enableLaunch = ([sender state] == NSControlStateValueOff);
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];

    if ([launchController updateLaunchAtLoginEnabled:enableLaunch]) {
        [sender setState:enableLaunch ? NSControlStateValueOn : NSControlStateValueOff];
    } else {
        BOOL actualState = [launchController launchAtLogin];
        [sender setState:actualState ? NSControlStateValueOn : NSControlStateValueOff];
    }
}

- (void)togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender representedObject];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;

    if (state == NSControlStateValueOff) {
        [sender setState:NSControlStateValueOn];
        [defaults setBool:YES forKey:preference];
    } else {
        [sender setState:NSControlStateValueOff];
        [defaults setBool:NO forKey:preference];
    }

    [self refreshDateFormatterPreferences];
    [self scheduleTimer];
}

- (void)toggleISOPreference:(id)sender {
    NSInteger state = [sender state];
    [self togglePreference:sender];

    BOOL isoDisabled = (state == NSControlStateValueOff);
    for (NSMenuItem *item in @[_show24Item, _showDateItem, _showSecondsItem, _showJulianItem, _showTimeZoneItem]) {
        [item setEnabled:!isoDisabled];
    }
}

- (void)copyToPasteboard {
    NSDate *now = NSDate.date;
    NSString *dateString = [self.dateFormatter statusBarStringForDate:now];
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    [pasteboard clearContents];
    [pasteboard setString:dateString forType:NSPasteboardTypeString];
}

- (void)copyISO8601ToPasteboard {
    NSString *dateString = [self.dateFormatter iso8601StringForDate:NSDate.date];
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    [pasteboard clearContents];
    [pasteboard setString:dateString forType:NSPasteboardTypeString];
}

- (void)openGithubURL:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:GITHUB_URL]];
}

- (NSDictionary<NSAttributedStringKey, id> *)statusBarTitleAttributes {
    // Menu bar items use menuBarFont (14pt), not systemFontSize (13pt).
    return @{
        NSFontAttributeName: [NSFont menuBarFontOfSize:0],
        NSForegroundColorAttributeName: NSColor.labelColor,
    };
}

- (void)updateStatusBarTitle:(NSString *)title {
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:[self statusBarTitleAttributes]];
    self.statusItem.button.attributedTitle = attributedTitle;
}

- (void)updateDateMenuHeaderForDate:(NSDate *)date {
    self.dateMenuItem.title = [self.dateFormatter menuHeaderStringForDate:date];
}

- (void)doDateUpdate {
    NSDate *now = NSDate.date;
    [self updateDateMenuHeaderForDate:now];
    [self updateStatusBarTitle:[self.dateFormatter statusBarStringForDate:now]];
}

- (void)fireTimer:(NSTimer *)theTimer {
    [self doDateUpdate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMenuBar];
    [self setupWakeNotifications];
    [self scheduleTimer];
}

- (void)setupMenuBar {
    self.mainMenu = [[NSMenu alloc] init];
    [self.mainMenu setAutoenablesItems:NO];

    NSStatusBar *bar = NSStatusBar.systemStatusBar;
    NSStatusItem *statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem = statusItem;

    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    self.dateMenuItem = mainItem;
    [mainItem setEnabled:NO];

    NSMenuItem *copyItem = [[NSMenuItem alloc] init];
    NSMenuItem *copyISOItem = [[NSMenuItem alloc] init];
    NSMenuItem *launchItem = [[NSMenuItem alloc] init];
    NSMenuItem *quitItem = [[NSMenuItem alloc] init];
    NSMenuItem *versionItem = [[NSMenuItem alloc] init];
    NSMenuItem *emailItem = [[NSMenuItem alloc] init];
    NSMenuItem *githubItem = [[NSMenuItem alloc] init];
    NSMenuItem *showISO8601Item = [[NSMenuItem alloc] init];

    self.showDateItem = [[NSMenuItem alloc] init];
    self.show24Item = [[NSMenuItem alloc] init];
    self.showSecondsItem = [[NSMenuItem alloc] init];
    self.showJulianItem = [[NSMenuItem alloc] init];
    self.showTimeZoneItem = [[NSMenuItem alloc] init];

    [copyItem setTitle:@"Copy"];
    [copyItem setTarget:self];
    [copyItem setAction:@selector(copyToPasteboard)];

    [copyISOItem setTitle:@"Copy as ISO-8601"];
    [copyISOItem setTarget:self];
    [copyISOItem setAction:@selector(copyISO8601ToPasteboard)];

    [launchItem setTitle:@"Open at Login"];
    [launchItem setTarget:self];
    [launchItem setAction:@selector(toggleLaunch:)];

    [self.show24Item setTitle:@"24 HR Time"];
    [self.show24Item setTarget:self];
    [self.show24Item setAction:@selector(togglePreference:)];
    [self.show24Item setRepresentedObject:UTCShow24HourPreferenceKey];

    [self.showDateItem setTitle:@"Show Date"];
    [self.showDateItem setTarget:self];
    [self.showDateItem setAction:@selector(togglePreference:)];
    [self.showDateItem setRepresentedObject:UTCShowDatePreferenceKey];

    [self.showSecondsItem setTitle:@"Show Seconds"];
    [self.showSecondsItem setTarget:self];
    [self.showSecondsItem setAction:@selector(togglePreference:)];
    [self.showSecondsItem setRepresentedObject:UTCShowSecondsPreferenceKey];

    [self.showJulianItem setTitle:@"Show Julian Date"];
    [self.showJulianItem setTarget:self];
    [self.showJulianItem setAction:@selector(togglePreference:)];
    [self.showJulianItem setRepresentedObject:UTCShowJulianDatePreferenceKey];

    [self.showTimeZoneItem setTitle:@"Show Time Zone"];
    [self.showTimeZoneItem setTarget:self];
    [self.showTimeZoneItem setAction:@selector(togglePreference:)];
    [self.showTimeZoneItem setRepresentedObject:UTCShowTimeZonePreferenceKey];

    [showISO8601Item setTitle:@"Show ISO8601 Instead"];
    [showISO8601Item setTarget:self];
    [showISO8601Item setAction:@selector(toggleISOPreference:)];
    [showISO8601Item setRepresentedObject:UTCShowISO8601PreferenceKey];

    [quitItem setTitle:@"Quit"];
    [quitItem setTarget:self];
    [quitItem setAction:@selector(quitProgram:)];

    NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"";
    [versionItem setTitle:[NSString stringWithFormat:@"UTC Menu Clock v%@", version]];
    [versionItem setEnabled:NO];
    [emailItem setTitle:@"jna@retina.net"];
    [emailItem setEnabled:NO];
    [githubItem setTitle:GITHUB_URL];
    [githubItem setTarget:self];
    [githubItem setAction:@selector(openGithubURL:)];

    [self.mainMenu addItem:mainItem];
    [self.mainMenu addItem:[NSMenuItem separatorItem]];
    [self.mainMenu addItem:copyItem];
    [self.mainMenu addItem:copyISOItem];
    [self.mainMenu addItem:[NSMenuItem separatorItem]];

    UTCMenuClockPreferences *preferences = [UTCMenuClockPreferences currentPreferences];
    [self.show24Item setState:preferences.show24HourTime ? NSControlStateValueOn : NSControlStateValueOff];
    [self.showDateItem setState:preferences.showDate ? NSControlStateValueOn : NSControlStateValueOff];
    [self.showSecondsItem setState:preferences.showSeconds ? NSControlStateValueOn : NSControlStateValueOff];
    [self.showJulianItem setState:preferences.showJulianDate ? NSControlStateValueOn : NSControlStateValueOff];
    [self.showTimeZoneItem setState:preferences.showTimeZone ? NSControlStateValueOn : NSControlStateValueOff];

    if (preferences.showISO8601) {
        [showISO8601Item setState:NSControlStateValueOn];
        for (NSMenuItem *item in @[self.show24Item, self.showDateItem, self.showSecondsItem, self.showJulianItem, self.showTimeZoneItem]) {
            [item setEnabled:NO];
        }
    } else {
        [showISO8601Item setState:NSControlStateValueOff];
    }

    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchItem setState:[launchController launchAtLogin] ? NSControlStateValueOn : NSControlStateValueOff];

    [self.mainMenu addItem:launchItem];
    [self.mainMenu addItem:self.show24Item];
    [self.mainMenu addItem:self.showDateItem];
    [self.mainMenu addItem:self.showSecondsItem];
    [self.mainMenu addItem:self.showJulianItem];
    [self.mainMenu addItem:self.showTimeZoneItem];
    [self.mainMenu addItem:showISO8601Item];
    [self.mainMenu addItem:[NSMenuItem separatorItem]];
    [self.mainMenu addItem:quitItem];
    [self.mainMenu addItem:[NSMenuItem separatorItem]];
    [self.mainMenu addItem:versionItem];
    [self.mainMenu addItem:emailItem];
    [self.mainMenu addItem:[NSMenuItem separatorItem]];
    [self.mainMenu addItem:githubItem];

    statusItem.menu = self.mainMenu;
}

- (void)setupWakeNotifications {
    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self
                                                       selector:@selector(receiveWakeNote:)
                                                           name:NSWorkspaceDidWakeNotification
                                                         object:nil];
}

- (void)scheduleTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self doDateUpdate];

    NSDateComponents *startUnits = [NSCalendar.currentCalendar components:
                                    (NSCalendarUnitYear |
                                     NSCalendarUnitMonth |
                                     NSCalendarUnitDay |
                                     NSCalendarUnitHour |
                                     NSCalendarUnitMinute |
                                     NSCalendarUnitSecond)
                                                                   fromDate:NSDate.date];

    NSTimeInterval interval;
    NSTimeInterval tolerance;

    if ([self fetchBooleanPreference:UTCShowSecondsPreferenceKey]) {
        startUnits.second = startUnits.second + 1;
        interval = 1.0;
        tolerance = 0.05;
    } else {
        startUnits.second = 0;
        startUnits.minute = startUnits.minute + 1;
        interval = 60.0;
        tolerance = 0.5;
    }

    NSDate *startDateTime = [NSCalendar.currentCalendar dateFromComponents:startUnits];
    self.timer = [[NSTimer alloc] initWithFireDate:startDateTime
                                          interval:interval
                                            target:self
                                          selector:@selector(fireTimer:)
                                          userInfo:nil
                                           repeats:YES];
    self.timer.tolerance = tolerance;
    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)receiveWakeNote:(NSNotification *)note {
    [self scheduleTimer];
}

- (void)dealloc {
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
    [self.timer invalidate];
}

@end
