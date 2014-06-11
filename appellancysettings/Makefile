include $(THEOS)/makefiles/common.mk

ARCHS=armv7 armv7s arm64
CFLAGS = -fobjc-arc

BUNDLE_NAME = AppellancySettings
AppellancySettings_FILES = AppellancySettings.mm
AppellancySettings_INSTALL_PATH = /Library/PreferenceBundles
AppellancySettings_FRAMEWORKS = UIKit
AppellancySettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AppellancySettings.plist$(ECHO_END)
