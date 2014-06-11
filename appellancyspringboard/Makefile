ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:7.1:7.1
CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppellancySpringBoard
AppellancySpringBoard_FILES = Tweak.xm NSData+AES.m
AppellancySpringBoard_LIBRARIES = flipswitch appellancy Pass

AppellancySpringBoard_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
