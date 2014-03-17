#import <Cordova/CDVPlugin.h>

@interface IonicKeyboard : CDVPlugin {
    @protected
    id _resizeViewShowObserver; 
}

@property (readwrite, assign, getter = resizeView, setter = setResizeView:) CGFloat resizeView;
@property (readwrite, assign, getter = hideKeyboardAccessoryBar, setter = setHideKeyboardAccessoryBar:)  BOOL hideKeyboardAccessoryBar;

- (void) resizeView:(CDVInvokedUrlCommand*)command;
- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command;
- (void) close:(CDVInvokedUrlCommand*)command;
- (void) disableScroll:(CDVInvokedUrlCommand*)command;

@end

