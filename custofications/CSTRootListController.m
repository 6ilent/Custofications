#include "CSTRootListController.h"

@implementation CSTRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)testNotifications:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.6ilent.custofications/TestNotifications", nil, nil, true);
}

- (void)testBanner:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.6ilent.custofications/TestBanner", nil, nil, true);
}
@end
