#import <Cordova/CDVPlugin.h>

@interface IonicKeyboard : CDVPlugin <UIScrollViewDelegate> {
    @protected
    id _keyboardShowObserver, _keyboardHideObserver;
}

@property (readwrite, assign, getter = hideKeyboardAccessoryBar, setter = setHideKeyboardAccessoryBar:)  BOOL hideKeyboardAccessoryBar;
@property (readwrite, assign) BOOL disableScroll;

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command;
- (void) close:(CDVInvokedUrlCommand*)command;

@end

