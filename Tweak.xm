//Imports our headers
#import "Tweak.h"

//Definitions for our preference observers
#define kIdentifier @"com.6ilent.custofications"
#define kSettingsChangedNotification (CFStringRef)@"com.6ilent.custofications/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.6ilent.custofications.plist"

//Our preference variables
static BOOL cstEnabled;
static NSString *cstApp;
static NSInteger cstAmount;
static NSString *cstTitle;
static NSString *cstMessage;

//Our BBServer variable
static BBServer *bbServer = nil;

//gets the queue to our BBServer
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

//handler method for our fakes, it loads everything into BBBulletin
static void fakeNotification(NSString *sectionID, NSDate *date, NSString *message, bool banner) {
    BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];

    bulletin.title = cstTitle;
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

    //If the banner variable then send as a banner if not then send it to the lockscreen
    if (banner) {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:15];
            });
        }
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

//method that sends our fake notification IF the tweak is enabled and for the set amount of times
void CSTTestNotifications() {
    if (cstEnabled) {
        [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            for (int o = 0; o < cstAmount; o++) {
              fakeNotification(cstApp, [NSDate date], cstMessage, false);
            }
        });
    }
}

//method that sends our fake banner IF the tweak is enabled and for the set amount of times
void CSTTestBanner() {
    if (cstEnabled) {
        for (int i = 0; i < cstAmount; i++) {
          fakeNotification(cstApp, [NSDate date], cstMessage, true);
        }
    }
}

//Hooks bbserver and adds its data to our bbserver variable so we can play with it, kind of magic?
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

//Method that loads the prefs
static void reloadPrefs() {
  //Fancy magic
  CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

  NSDictionary *prefs = nil;
  if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
    CFArrayRef keys = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

    if (keys != nil) {
      prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keys, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

      if (prefs == nil) {
        prefs = [NSDictionary dictionary];
      }
      CFRelease(keys);
    }
  } else {
    prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
  }

  //registers our preferences to variables in our tweak so we can use them
  cstEnabled = [prefs objectForKey:@"cstEnabled"] ? [(NSNumber *)[prefs objectForKey:@"cstEnabled"] boolValue] : true;
  cstApp = [prefs objectForKey:@"cstApp"] ? [[prefs objectForKey:@"cstApp"] stringValue] : @"com.apple.Preferences";
  cstAmount = [prefs objectForKey:@"cstAmount"] ? [[prefs objectForKey:@"cstAmount"] integerValue] : 1;
  cstTitle = [prefs objectForKey:@"cstTitle"] ? [[prefs objectForKey:@"cstTitle"] stringValue] : @"Title";
  cstMessage = [prefs objectForKey:@"cstMessage"] ? [[prefs objectForKey:@"cstMessage"] stringValue] : @"Hello World!";
}

/*Initial loading point for the tweak
  -reloads the preferences
  -sets up observers for when the preferences change and for when the preferences send the action to send the banner/notification
*/
%ctor {
    reloadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CSTTestNotifications, (CFStringRef)@"com.6ilent.custofications/sendNotifications", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)CSTTestBanner, (CFStringRef)@"com.6ilent.custofications/sendBanner", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}