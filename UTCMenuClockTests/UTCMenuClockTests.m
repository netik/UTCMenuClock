//
//  UTCMenuClockTests.m
//  UTCMenuClockTests
//
//  Created by John Adams on 11/14/11.
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

#import "UTCMenuClockTests.h"
#import "UTCDateDisplayFormatter.h"
#import "UTCMenuClockPreferences.h"

@implementation UTCMenuClockTests

- (NSDate *)dateFromUTCString:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:string];
}

- (UTCDateDisplayFormatter *)formatterWithPreferences:(void (^)(UTCMenuClockPreferences *))configure {
    UTCMenuClockPreferences *preferences = [[UTCMenuClockPreferences alloc] init];
    configure(preferences);
    UTCDateDisplayFormatter *formatter = [[UTCDateDisplayFormatter alloc] init];
    [formatter updatePreferences:preferences];
    return formatter;
}

- (void)testAppBundleIdentifier {
    XCTAssertEqualObjects(NSBundle.mainBundle.bundleIdentifier, @"net.retina.UTCMenuClock");
}

- (void)testStatusBarStringUsesISO8601WhenEnabled {
    NSDate *date = [self dateFromUTCString:@"2024-06-15 14:30:45"];
    UTCDateDisplayFormatter *formatter = [self formatterWithPreferences:^(UTCMenuClockPreferences *preferences) {
        preferences.showISO8601 = YES;
    }];

    NSString *result = [formatter statusBarStringForDate:date];
    XCTAssertTrue([result containsString:@"2024-06-15"]);
    XCTAssertTrue([result containsString:@"14:30:45"]);
}

- (void)testStatusBarString24HourWithSecondsAndTimeZone {
    NSDate *date = [self dateFromUTCString:@"2024-06-15 14:30:45"];
    UTCDateDisplayFormatter *formatter = [self formatterWithPreferences:^(UTCMenuClockPreferences *preferences) {
        preferences.show24HourTime = YES;
        preferences.showSeconds = YES;
        preferences.showTimeZone = YES;
    }];

    NSString *result = [formatter statusBarStringForDate:date];
    XCTAssertEqualObjects(result, @"14:30:45 UTC");
}

- (void)testStatusBarStringIncludesDateAndJulianDay {
    NSDate *date = [self dateFromUTCString:@"2024-01-10 09:05:00"];
    UTCDateDisplayFormatter *formatter = [self formatterWithPreferences:^(UTCMenuClockPreferences *preferences) {
        preferences.showDate = YES;
        preferences.showJulianDate = YES;
        preferences.show24HourTime = YES;
    }];

    NSString *result = [formatter statusBarStringForDate:date];
    XCTAssertTrue([result containsString:@"1/10/24"]);
    XCTAssertTrue([result containsString:@"10/"]);
    XCTAssertTrue([result containsString:@"09:05"]);
}

- (void)testMenuHeaderUsesFullDateStyle {
    NSDate *date = [self dateFromUTCString:@"2024-06-15 14:30:45"];
    UTCDateDisplayFormatter *formatter = [[UTCDateDisplayFormatter alloc] init];
    [formatter updatePreferences:[[UTCMenuClockPreferences alloc] init]];

    NSString *result = [formatter menuHeaderStringForDate:date];
    XCTAssertTrue([result containsString:@"2024"]);
    XCTAssertTrue([result containsString:@"June"]);
    XCTAssertTrue([result containsString:@"15"]);
}

@end
