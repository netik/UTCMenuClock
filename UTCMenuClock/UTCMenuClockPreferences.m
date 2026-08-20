//
//  UTCMenuClockPreferences.m
//  UTCMenuClock
//
//  Created by John Adams on 8/20/26.
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

#import "UTCMenuClockPreferences.h"

NSString *const UTCShowDatePreferenceKey = @"ShowDate";
NSString *const UTCShowSecondsPreferenceKey = @"ShowSeconds";
NSString *const UTCShowJulianDatePreferenceKey = @"ShowJulianDate";
NSString *const UTCShowTimeZonePreferenceKey = @"ShowTimeZone";
NSString *const UTCShow24HourPreferenceKey = @"24HRTime";
NSString *const UTCShowISO8601PreferenceKey = @"ISO8601";

@implementation UTCMenuClockPreferences

+ (void)registerDefaults {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults registerDefaults:@{
        UTCShowTimeZonePreferenceKey: @YES,
        UTCShow24HourPreferenceKey: @YES,
        UTCShowJulianDatePreferenceKey: @NO,
        UTCShowDatePreferenceKey: @NO,
        UTCShowSecondsPreferenceKey: @NO,
        UTCShowISO8601PreferenceKey: @NO,
    }];
    [defaults removeObjectForKey:@"dateKey"];
}

+ (instancetype)currentPreferences {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    UTCMenuClockPreferences *preferences = [[UTCMenuClockPreferences alloc] init];
    preferences.showDate = [defaults boolForKey:UTCShowDatePreferenceKey];
    preferences.showSeconds = [defaults boolForKey:UTCShowSecondsPreferenceKey];
    preferences.showJulianDate = [defaults boolForKey:UTCShowJulianDatePreferenceKey];
    preferences.showTimeZone = [defaults boolForKey:UTCShowTimeZonePreferenceKey];
    preferences.show24HourTime = [defaults boolForKey:UTCShow24HourPreferenceKey];
    preferences.showISO8601 = [defaults boolForKey:UTCShowISO8601PreferenceKey];
    return preferences;
}

@end
