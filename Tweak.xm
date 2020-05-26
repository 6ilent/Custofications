#import "Tweak.h"

static BBServer *bbServer = nil;

static dispatch_queue_t getBBServerQueue() {
	static dispatch_queue_t queue;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		void *handle = dlopen(NULL, RTLD_GLOBAL);
		if (handle) {
			dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
			if (pointer) {
				queue = *pointer;
			}
			dlclose(handle);
		}
	});
	return queue;
}

static void fakeNotification(NSString *sectionID, NSDate *date, NSString *message, bool banner) {
    BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];

    bulletin.title = @"Custofication";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if (banner) {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:15];
            });
        }
        // SBLockScreenNotificationListController *listController=([[%c(UIApplication) sharedApplication] respondsToSelector:@selector(notificationDispatcher)] && [[[%c(UIApplication) sharedApplication] notificationDispatcher] respondsToSelector:@selector(notificationSource)]) ? [[[%c(UIApplication) sharedApplication] notificationDispatcher] notificationSource]  : [[[%c(SBLockScreenManager) sharedInstanceIfExists] lockScreenViewController] valueForKey:@"notificationController"];
        // [listController observer:[listController valueForKey:@"observer"] addBulletin:bulletin forFeed:14];
    } else {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:alwaysToLockScreen:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
            });
        } else if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:4];
            });
        }
    }
}

void CSTTestNotifications() {
    [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 1!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 2!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 3!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 4!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 5!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 6!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 7!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 8!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 9!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 10!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 11!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 12!", false);
        fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test notification 13!", false);
        fakeNotification(@"com.apple.Music", [NSDate date], @"Test notification 14!", false);
        fakeNotification(@"com.apple.mobilephone", [NSDate date], @"Test notification 15!", false);
    });
}

void CSTTestBanner() {
    fakeNotification(@"com.apple.MobileSMS", [NSDate date], @"Test banner!", true);
}

%hook BBServer
-(id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;
}

-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}

- (void)dealloc {
  if (bbServer == self) {
    bbServer = nil;
  }

  %orig;
}
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CSTTestNotifications, (CFStringRef)@"com.6ilent.custofications/TestNotifications", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CSTTestBanner, (CFStringRef)@"com.6ilent.custofications/TestBanner", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}