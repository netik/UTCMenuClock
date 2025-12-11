//
//  LaunchAtLoginController.h
//

#import <Cocoa/Cocoa.h>

@interface LaunchAtLoginController : NSObject {

}

@property BOOL launchAtLogin;

- (void)setLaunchAtLogin:(BOOL)enabled;
- (void)setLaunchAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end
