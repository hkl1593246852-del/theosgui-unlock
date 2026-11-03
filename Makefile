TWEAK_NAME = TheosGUIUnlock
TheosGUIUnlock_FILES = Tweak.x
TheosGUIUnlock_CFLAGS = -fobjc-arc
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
