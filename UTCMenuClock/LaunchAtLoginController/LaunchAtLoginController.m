//
//  LaunchAtLoginController.m
//
//  Updated to use SMAppService for macOS 13+ (modern API)
//

#import "LaunchAtLoginController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation LaunchAtLoginController

- (NSURL *)appURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

/**
 Returns whether the application is set to launch at login.
 Uses the modern SMAppService API (macOS 13+).
 
 @return YES if the app will launch at login, NO otherwise.
 */
- (BOOL)launchAtLogin {
    SMAppService *service = [SMAppService mainAppService];
    return (service.status == SMAppServiceStatusEnabled);
}

/**
 Sets the application to launch at login or not.
 Uses the modern SMAppService API (macOS 13+).

 @param itemURL The URL of the application bundle (unused in modern API).
 @param enabled A boolean indicating whether the application should launch at login.
 */
- (BOOL)setLaunchAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled {
    SMAppService *service = [SMAppService mainAppService];
    NSError *error = nil;
    BOOL success;

    if (enabled) {
        success = [service registerAndReturnError:&error];
        if (!success) {
            NSLog(@"Failed to enable launch at login: %@", error.localizedDescription);
        }
    } else {
        success = [service unregisterAndReturnError:&error];
        if (!success) {
            NSLog(@"Failed to disable launch at login: %@", error.localizedDescription);
        }
    }

    return success;
}

/**
 Sets the application to launch at login or not.

 @param enabled A boolean indicating whether the application should launch at login.
 */
- (void)setLaunchAtLogin:(BOOL)enabled {
    [self updateLaunchAtLoginEnabled:enabled];
}

- (BOOL)updateLaunchAtLoginEnabled:(BOOL)enabled {
    [self willChangeValueForKey:@"startAtLogin"];
    BOOL success = [self setLaunchAtLogin:[self appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
    return success;
}

@end
