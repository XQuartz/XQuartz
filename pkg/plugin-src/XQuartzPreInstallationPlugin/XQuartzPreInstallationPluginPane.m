//
//  XQuartzPreInstallationPluginPane.m
//  XQuartzPreInstallationPlugin
//
//  Created by Jeremy Sequoia on 2/15/21.
//

#import "XQuartzPreInstallationPluginPane.h"

NS_ASSUME_NONNULL_BEGIN

@implementation XQuartzPreInstallationPluginPane

- (NSString *)title
{
    NSBundle * const bundle = [NSBundle bundleForClass:self.class];
    return [bundle localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void)didEnterPane:(InstallerSectionDirection)dir
{
    NSFileManager * const fm = NSFileManager.defaultManager;
    BOOL const requiresLogout = ![fm fileExistsAtPath:@"/Library/LaunchAgents/org.xquartz.startx.plist"] ||
                                [fm fileExistsAtPath:@"/Library/LaunchAgents/org.macosforge.xquartz.startx.plist"];

    InstallerSection * const installerSection = self.section;
    NSMutableDictionary * const installerDictionary = installerSection.sharedDictionary;
    
    installerDictionary[@"XQuartz_Requires_Logout"] = @(requiresLogout);

    if (requiresLogout) {
        NSLog(@"XQuartz will require logout to finish installation.");
    } else {
        NSLog(@"XQuartz will not require logout to finish installation.");
    }

    if (dir == InstallerDirectionForward) {
        [self gotoNextPane];
    } else {
        [self gotoPreviousPane];
    }
}

@end

NS_ASSUME_NONNULL_END
