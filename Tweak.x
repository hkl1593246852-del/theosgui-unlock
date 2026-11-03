#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>

@interface SponsorshipViewController : UIViewController
@end

static NSString *notifName(void) {
    void *sym = dlsym(RTLD_DEFAULT, "kDeviceActivatedNotification");
    if (sym) {
        NSString *__unsafe_unretained *p = (NSString *__unsafe_unretained *)sym;
        if (*p) return *p;
    }
    return @"kDeviceActivatedNotification";
}

static void postActivated(NSString *why) {
    NSString *name = notifName();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
        NSLog(@"[TGU] posted %@ (%@)", name, why);
    });
}

%hook SponsorshipViewController
- (void)viewDidLoad { %orig; postActivated(@"viewDidLoad"); }
- (void)viewWillAppear:(BOOL)a { %orig; postActivated(@"viewWillAppear"); }
- (void)viewDidAppear:(BOOL)a {
    %orig;
    postActivated(@"viewDidAppear");
    SEL sel = NSSelectorFromString(@"handleDeviceActivated");
    if ([self respondsToSelector:sel]) {
        ((void (*)(id, SEL))objc_msgSend)(self, sel);
        NSLog(@"[TGU] called handleDeviceActivated");
    }
}
%end

%ctor { NSLog(@"[TGU] loaded"); postActivated(@"ctor"); }
