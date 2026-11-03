TWEAK_NAME = TheosGUIUnlock
TheosGUIUnlock_FILES = Tweak.x
TheosGUIUnlock_CFLAGS = -fobjc-arc -Wno-error
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
