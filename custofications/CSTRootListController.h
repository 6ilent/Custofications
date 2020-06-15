#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import "NSTask.h"

#define THEME_COLOR [UIColor colorWithRed:245.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1.0];

@interface CSTAppearanceSettings : HBAppearanceSettings

@end

@interface PSListController (iOS12Plus)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface CSTRootListController : HBRootListController {
    UITableView * _table;
}

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
- (void)resetPrefs:(id)sender;
- (void)respring:(id)sender;
- (void)sendNotifications:(id)sender;
- (void)sendBanner:(id)sender;

@end
