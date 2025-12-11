//
//  UTCMenuClockAppDelegate.h
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

#import <Cocoa/Cocoa.h>

@interface UTCMenuClockAppDelegate : NSObject <NSApplicationDelegate>

// Window outlet (weak - owned by nib)
@property (weak) IBOutlet NSWindow *window;

// Menu is created programmatically, so we need a strong reference
@property (strong, nonatomic) NSMenu *mainMenu;

// Status bar item (strong - we own it)
@property (strong, nonatomic) NSStatusItem *statusItem;

// Timer for clock updates
@property (strong, nonatomic) NSTimer *timer;

// Menu items that need state management
@property (strong, nonatomic) NSMenuItem *dateMenuItem;
@property (strong, nonatomic) NSMenuItem *show24Item;
@property (strong, nonatomic) NSMenuItem *showDateItem;
@property (strong, nonatomic) NSMenuItem *showSecondsItem;
@property (strong, nonatomic) NSMenuItem *showJulianItem;
@property (strong, nonatomic) NSMenuItem *showTimeZoneItem;

@end
