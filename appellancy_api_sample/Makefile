ARCHS = armv7 arm64
THEOS_DEVICE_IP = 192.168.7.146
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Appellancy_API_sample
Appellancy_API_sample_FILES = Tweak.xm
Appellancy_API_sample_FRAMEWORKS = UIKit
Appellancy_API_sample_LIBRARIES = appellancy

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
