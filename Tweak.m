#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

static const char *kKeys[] = {"Sponsor","sponsor","Activat","activat","Licen","licen",
                              "Vip","VIP","Purchas","purchas","Premium","premium","Paid","paid","Unlock","unlock"};

static BOOL nameMatches(const char *n) {
    if (!n) return NO;
    for (int i = 0; i < sizeof(kKeys)/sizeof(kKeys[0]); i++)
        if (strstr(n, kKeys[i])) return YES;
    return NO;
}

static BOOL selLooksBoolGetter(const char *n) {
    if (!n) return NO;
    return (strncmp(n, "is", 2) == 0) || (strncmp(n, "has", 3) == 0) ||
           (strncmp(n, "can", 3) == 0) || (strstr(n, "Enabled") != NULL);
}

__attribute__((constructor))
static void tgu_probe(void) {
    NSLog(@"[TGU] ==== probe start ====");
    int n = objc_getClassList(NULL, 0);
    Class *classes = (Class *)malloc(sizeof(Class) * n);
    n = objc_getClassList(classes, n);

    for (int i = 0; i < n; i++) {
        const char *cn = class_getName(classes[i]);
        if (!nameMatches(cn)) continue;
        NSLog(@"[TGU] CLASS %s", cn);

        unsigned int mc = 0;
        Method *ms = class_copyMethodList(classes[i], &mc);
        for (unsigned int k = 0; k < mc; k++) {
            const char *sn = sel_getName(method_getName(ms[k]));
            const char *te = method_getTypeEncoding(ms[k]);
            NSLog(@"[TGU]   - %s  (%s)", sn, te);
        }
        free(ms);

        Class meta = object_getClass(classes[i]);
        unsigned int cmc = 0;
        Method *cms = class_copyMethodList(meta, &cmc);
        for (unsigned int k = 0; k < cmc; k++) {
            const char *sn = sel_getName(method_getName(cms[k]));
            NSLog(@"[TGU]   + %s", sn);
        }
        free(cms);

        // 强制布尔 getter 返回 YES
        ms = class_copyMethodList(classes[i], &mc);
        for (unsigned int k = 0; k < mc; k++) {
            const char *sn = sel_getName(method_getName(ms[k]));
            const char *te = method_getTypeEncoding(ms[k]);
            if (!selLooksBoolGetter(sn)) continue;
            if (!te || (te[0] != 'c' && te[0] != 'B')) continue;
            IMP imp = imp_implementationWithBlock(^BOOL(id self) {
                NSLog(@"[TGU] force YES for %s", sn);
                return YES;
            });
            method_setImplementation(ms[k], imp);
        }
        free(ms);
    }
    free(classes);
    NSLog(@"[TGU] ==== probe end ====");
}
