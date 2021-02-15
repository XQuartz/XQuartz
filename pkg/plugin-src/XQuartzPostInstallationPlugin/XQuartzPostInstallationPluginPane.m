//
//  XQuartzPostInstallationPluginPane.m
//  XQuartzPostInstallationPlugin
//
//  Created by Jeremy Sequoia on 2/15/21.
//

#import "XQuartzPostInstallationPluginPane.h"

NS_ASSUME_NONNULL_BEGIN

@implementation XQuartzPostInstallationPluginPane

- (instancetype)initWithSection:(id)parent
{
    self = [super initWithSection:parent];
 
    return self;
}

- (NSString *)title
{
    NSBundle * const bundle = [NSBundle bundleForClass:self.class];
    return [bundle localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void)didEnterPane:(InstallerSectionDirection)dir
{
    InstallerSection * const installerSection = self.section;
    NSMutableDictionary * const installerDictionary = installerSection.sharedDictionary;

    NSNumber * const requiresLogoutNumber = installerDictionary[@"XQuartz_Requires_Logout"];
    NSAssert(requiresLogoutNumber, @"Error getting logout requirement from pre-installation plugin.");
    
    BOOL const requiresLogout = requiresLogoutNumber.boolValue;

    if (requiresLogout) {
        NSBundle * const bundle = [NSBundle bundleForClass:self.class];

        NSAlert *alert = [NSAlert new];
        alert.messageText = [bundle localizedStringForKey:@"AlertMessage" value:nil table:nil] ?: @"nil message";
        alert.informativeText = [bundle localizedStringForKey:@"AlertInformative" value:nil table:nil] ?: @"nil string";
        [alert setAlertStyle:NSInformationalAlertStyle];

        (void)[alert runModal];
    }

    if (dir == InstallerDirectionForward) {
        [self gotoNextPane];
    } else {
        [self gotoPreviousPane];
    }
}

@end

NS_ASSUME_NONNULL_END
