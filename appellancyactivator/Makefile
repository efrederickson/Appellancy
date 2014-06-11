ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:7.1:7.1
CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppellancyActivator
AppellancyActivator_FILES = AActivatorEvent.xm
AppellancyActivator_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
