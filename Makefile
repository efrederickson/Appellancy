ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:7.1:7.1

THEOS_DEVICE_IP=192.168.7.146
THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

#all::
#	cd FaceRecognition && xcodebuild -parallelizeTargets > /dev/null

after-install::
	install.exec "killall -9 Preferences"

#main project
SUBPROJECTS += libappellancy

#springboard hook
SUBPROJECTS += appellancyspringboard

#other projects
SUBPROJECTS += appellancysettings
SUBPROJECTS += appellancyflipswitch
SUBPROJECTS += appellancyactivator

include $(THEOS_MAKE_PATH)/aggregate.mk
