#import <Cordova/CDVPlugin.h>

@interface IonicKeyboard : CDVPlugin {
    @protected
    id _scrollWhenKeyboardOpensKeyboardShowObserver, _scrollWhenKeyboardOpensKeyboardHideObserver;
}

@property (readwrite, assign, getter = scrollWhenKeyboardOpens, setter = setscrollWhenKeyboardOpens:) CGFloat scrollWhenKeyboardOpens;
@property (readwrite, assign, getter = hideKeyboardAccessoryBar, setter = setHideKeyboardAccessoryBar:)  BOOL hideKeyboardAccessoryBar;

- (void) scrollWhenKeyboardOpens:(CDVInvokedUrlCommand*)command;
- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command;

@end

