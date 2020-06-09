ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Custofications

Custofications_FILES = CSTRootListController.m AppearanceSettings.m
Custofications_INSTALL_PATH = /Library/PreferenceBundles
Custofications_FRAMEWORKS = UIKit
Custofications_PRIVATE_FRAMEWORKS = Preferences
Custofications_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Custofications.plist$(ECHO_END)
