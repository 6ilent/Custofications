#include "CSTRootListController.h"
#include "AppearanceSettings.m"

@implementation CSTRootListController
@synthesize respringButton;

- (instancetype)init {
    self = [super init];

    if (self) {
        CSTAppearanceSettings *appearanceSettings = [[CSTAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(respring:)];
        self.respringButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.respringButton;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"Custofications";
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Custofications.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:path atomically:YES];

    CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }

    //Here we check if the switch is on based of the key of the PSSwitchCell, then hide the specifier
    //We then hide the cell using the id of it. If its already hidden we reinsert the cell below a certain specifier based on its ID
    NSString *key = [specifier propertyForKey:@"key"];
        if([key isEqualToString:@"cstEnabled"]) {
            if([value boolValue]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"94"]] afterSpecifierID:@"93" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"95"]] afterSpecifierID:@"94" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"96"]] afterSpecifierID:@"95" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"97"]] afterSpecifierID:@"96" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"98"]] afterSpecifierID:@"97" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"99"]] afterSpecifierID:@"98" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"100"]] afterSpecifierID:@"99" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"101"]] afterSpecifierID:@"100" animated:YES];
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"102"]] afterSpecifierID:@"101" animated:YES];
            } else if([self containsSpecifier:self.savedSpecifiers[@"94"]]) {
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"94"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"95"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"96"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"97"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"98"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"99"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"100"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"101"]] animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"102"]] animated:YES];
        }
    }
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    NSArray *chosenIDs = @[@"94", @"95", @"96", @"97", @"98", @"99", @"100", @"101", @"102"];
    self.savedSpecifiers = (!self.savedSpecifiers) ? [[NSMutableDictionary alloc] init] : self.savedSpecifiers;
     for(PSSpecifier *specifier in _specifiers) {
        if([chosenIDs containsObject:[specifier propertyForKey:@"id"]]) {
         [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

    return _specifiers;
}

- (void)loadView {
    [super loadView];
    ((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.6ilent.custofications.plist"];
      if(![preferences[@"cstEnabled"] boolValue] == true) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"94"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"95"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"96"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"97"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"98"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"99"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"100"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"101"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"102"]] animated:NO];
    }

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Custofications.bundle/custofications.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

    _table.tableHeaderView = self.headerView;
}

- (void)reloadSpecifiers {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.6ilent.custofications.plist"];
    if([preferences[@"cstEnabled"] boolValue] == false) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"94"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"95"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"96"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"97"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"98"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"99"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"100"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"101"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"102"]] animated:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = THEME_COLOR;
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

    if (offsetY > 0) offsetY = 0;
    self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 200 - offsetY);
}

- (void)resetPrefs:(id)sender {
  HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.6ilent.custofications"];
  [prefs removeAllObjects];

  [self respring:sender];
}

- (void)respring:(id)sender {
    NSTask *t = [[[NSTask alloc] init] autorelease];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
    [t launch];
}

- (void)sendNotifications:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.6ilent.custofications/sendNotifications", nil, nil, true);
}

- (void)sendBanner:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.6ilent.custofications/sendBanner", nil, nil, true);
}

@end
