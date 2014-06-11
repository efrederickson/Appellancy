ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:7.1:7.1

include $(THEOS)/makefiles/common.mk

CFLAGS = -fobjc-arc

LIBRARY_NAME = libAppellancy
libAppellancy_LIBRARIES = c++ sqlite3
libAppellancy_FRAMEWORKS = AssetsLibrary AVFoundation CoreFoundation CoreGraphics CoreMedia CoreVideo UIKit QuartzCore opencv2

libAppellancy_FILES = OpenCVData.mm ACvVideoCamera.m AFaceDetector.mm CustomFaceRecognizer.mm FaceDetector.mm 

include $(THEOS_MAKE_PATH)/library.mk

all::
	./install

