#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>

@interface NSObject (TGU)
@end

static NSString *tgu_notif_name(void) {
    void *sym = dlsym(RTLD_DEFAULT, "kDeviceActivatedNotification");
    if (sym) {
        NSString *__unsafe_unretained *p = (NSString *__unsafe_unretained *)sym;
        if (p && *p) return *p;
    }
    return @"kDeviceActivatedNotification";
}

static void tgu_post(const char *why) {
    NSString *name = tgu_notif_name();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
        NSLog(@"[TGU] posted %@ (%s)", name, why);
    });
}

static IMP tgu_orig_vdl;
static void tgu_vdl(id self, SEL _cmd) {
    if (tgu_orig_vdl) ((void (*)(id, SEL))tgu_orig_vdl)(self, _cmd);
    tgu_post("viewDidLoad");
}

static IMP tgu_orig_vda;
static void tgu_vda(id self, SEL _cmd, BOOL animated) {
    if (tgu_orig_vda) ((void (*)(id, SEL, BOOL))tgu_orig_vda)(self, _cmd, animated);
    tgu_post("viewDidAppear");
    SEL sel = NSSelectorFromString(@"handleDeviceActivated");
    if ([self respondsToSelector:sel]) {
        ((void (*)(id, SEL))objc_msgSend)(self, sel);
        NSLog(@"[TGU] called handleDeviceActivated");
    }
}

__attribute__((constructor))
static void tgu_init(void) {
    NSLog(@"[TGU] loaded");
    Class cls = objc_getClass("SponsorshipViewController");
    if (cls) {
        Method m1 = class_getInstanceMethod(cls, @selector(viewDidLoad));
        if (m1) tgu_orig_vdl = method_setImplementation(m1, (IMP)tgu_vdl);
        Method m2 = class_getInstanceMethod(cls, @selector(viewDidAppear:));
        if (m2) tgu_orig_vda = method_setImplementation(m2, (IMP)tgu_vda);
        NSLog(@"[TGU] hooked %@ (vdl=%p vda=%p)", cls, (void*)m1, (void*)m2);
    } else {
        NSLog(@"[TGU] class not found");
    }
    tgu_post("ctor");
}
