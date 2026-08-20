//
//  UTCDateDisplayFormatter.m
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

#import "UTCDateDisplayFormatter.h"
#import "UTCMenuClockPreferences.h"

@interface UTCDateDisplayFormatter ()
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;
@property (nonatomic, strong) NSDateFormatter *shortDateFormatter;
@property (nonatomic, strong) NSDateFormatter *julianDayFormatter;
@property (nonatomic, strong) NSISO8601DateFormatter *iso8601Formatter;
@property (nonatomic, strong) UTCMenuClockPreferences *preferences;
@end

@implementation UTCDateDisplayFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        NSTimeZone *utc = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

        _timeFormatter = [[NSDateFormatter alloc] init];
        _fullDateFormatter = [[NSDateFormatter alloc] init];
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        _julianDayFormatter = [[NSDateFormatter alloc] init];
        _iso8601Formatter = [[NSISO8601DateFormatter alloc] init];

        for (NSDateFormatter *formatter in @[_timeFormatter, _fullDateFormatter, _shortDateFormatter, _julianDayFormatter]) {
            formatter.timeZone = utc;
            formatter.locale = posix;
        }

        _fullDateFormatter.dateStyle = NSDateFormatterFullStyle;
        _fullDateFormatter.timeStyle = NSDateFormatterNoStyle;
        _shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
        _shortDateFormatter.timeStyle = NSDateFormatterNoStyle;
        [_julianDayFormatter setDateFormat:@"D/"];

        _iso8601Formatter.timeZone = utc;
        _preferences = [[UTCMenuClockPreferences alloc] init];
    }
    return self;
}

- (void)updatePreferences:(UTCMenuClockPreferences *)preferences {
    self.preferences = preferences;

    if (preferences.showSeconds) {
        self.timeFormatter.dateFormat = preferences.show24HourTime ? @"HH:mm:ss" : @"hh:mm:ss a";
    } else {
        self.timeFormatter.dateFormat = preferences.show24HourTime ? @"HH:mm" : @"hh:mm a";
    }
}

- (NSString *)iso8601StringForDate:(NSDate *)date {
    return [self.iso8601Formatter stringFromDate:date];
}

- (NSString *)menuHeaderStringForDate:(NSDate *)date {
    return [self.fullDateFormatter stringFromDate:date];
}

- (NSString *)statusBarStringForDate:(NSDate *)date {
    if (self.preferences.showISO8601) {
        return [self iso8601StringForDate:date];
    }

    NSString *timePart = [self.timeFormatter stringFromDate:date];
    NSString *julianPart = self.preferences.showJulianDate ? [self.julianDayFormatter stringFromDate:date] : @"";
    NSString *timeZonePart = self.preferences.showTimeZone ? @" UTC" : @"";

    if (self.preferences.showDate) {
        NSString *datePart = [self.shortDateFormatter stringFromDate:date];
        return [NSString stringWithFormat:@"%@ %@%@%@", datePart, julianPart, timePart, timeZonePart];
    }

    return [NSString stringWithFormat:@"%@%@%@", julianPart, timePart, timeZonePart];
}

@end
