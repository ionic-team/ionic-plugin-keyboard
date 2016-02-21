//
//  AppDelegate+IonicRestrictKeyboards.m
//
//
//  Created by Kurt Fickewirth on 10/7/15.
//
//  Swizzles a new 'shouldAllowExtensionPointIdentifier' method on the AppDelegate to
//  deny any custom keyboard from being used with this app.

#import "AppDelegate.h"
#import <objc/runtime.h>

@implementation AppDelegate(IonicRestrictKeyboards)

+(void)load {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(application:shouldAllowExtensionPointIdentifier:);
        SEL swizzledSelector = @selector(swizzled_application:ionicRestrictKeyboards_shouldAllowExtensionPointIdentifier:);
        SEL defaultSelector = @selector(default_application:ionicRestrictKeyboards_shouldAllowExtensionPointIdentifier:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method defaultMethod = class_getInstanceMethod(class, defaultSelector);
        
        // First try to add the our method as the original.  Returns YES if it didn't already exist and was added.
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        // If we added it, then replace our call with the original name.
        if (didAddMethod) {
            
            // There might not have been an original method, its optional on the delegate.
            if (originalMethod) {
                
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            }
            else {
                // There is no existing method, just swap in our default below.
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(defaultMethod),
                                    method_getTypeEncoding(defaultMethod));
            }
        } else {
            
            // The method was already there, swap methods.
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (BOOL) default_application:(UIApplication *)application ionicRestrictKeyboards_shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {

    return YES;
}

- (BOOL) swizzled_application:(UIApplication *)application ionicRestrictKeyboards_shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    
    // Do not allow any custom keyboard extensions.
    if ([extensionPointIdentifier isEqualToString: UIApplicationKeyboardExtensionPointIdentifier]) {
        return NO;
    }
    // Call our method name (it has been swapped out to actually point at the original method).
    // This gives the original implemenation a shot to say NO.
    return [self swizzled_application:application ionicRestrictKeyboards_shouldAllowExtensionPointIdentifier:extensionPointIdentifier];
}
@end


