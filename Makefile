THEOS_DEVICE_IP = 10.0.0.102

ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Custofications

Custofications_FILES = Tweak.xm
Custofications_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += custofications
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"