#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static void postActivated(NSString *why) {
    NSString **sym = (NSString **)dlsym(RTLD_DEFAULT, "kDeviceActivatedNotification");
    NSString *name = (sym && *sym) ? *sym : @"kDeviceActivatedNotification";
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
        NSLog(@"[TGU] posted activation notification (%@)", why);
    });
}

%hook SponsorshipViewController
- (void)viewDidLoad { %orig; postActivated(@"viewDidLoad"); }
- (void)viewWillAppear:(BOOL)a { %orig; postActivated(@"viewWillAppear"); }
- (void)viewDidAppear:(BOOL)a {
    %orig;
    postActivated(@"viewDidAppear");
    if ([self respondsToSelector:NSSelectorFromString(@"handleDeviceActivated")]) {
        [(id)self performSelector:NSSelectorFromString(@"handleDeviceActivated")];
        NSLog(@"[TGU] invoked handleDeviceActivated");
    }
}
%end

%ctor {
    NSLog(@"[TGU] tweak loaded");
    postActivated(@"ctor");
}
