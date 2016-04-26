#import "IonicKeyboard.h"
// #import "UIWebViewExtension.h"
#import <Cordova/CDVAvailability.h>
#import <objc/runtime.h>

NSString* const swizzled = @"swizzled_";

@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize disableScroll = _disableScroll;
//@synthesize styleDark = _styleDark;

- (void)pluginInitialize {

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;

    //set defaults
	_swizzledClassNameToClass = [[NSMutableDictionary alloc] init];
    self.hideKeyboardAccessoryBar = YES;
    self.disableScroll = NO;
    //self.styleDark = NO;

    _keyboardShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {

                                   CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                                   keyboardFrame = [self.viewController.view convertRect:keyboardFrame fromView:nil];

                                   [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.plugins.Keyboard.isVisible = true; cordova.fireWindowEvent('native.keyboardshow', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];

                                   //deprecated
                                   [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireWindowEvent('native.showkeyboard', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];
                               }];

    _keyboardHideObserver = [nc addObserverForName:UIKeyboardWillHideNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                   [weakSelf.commandDelegate evalJs:@"cordova.plugins.Keyboard.isVisible = false; cordova.fireWindowEvent('native.keyboardhide'); "];

                                   //deprecated
                                   [weakSelf.commandDelegate evalJs:@"cordova.fireWindowEvent('native.hidekeyboard'); "];
                               }];
}

- (BOOL)disableScroll {
    return _disableScroll;
}

- (void)setDisableScroll:(BOOL)disableScroll {
    if (disableScroll == _disableScroll) {
        return;
    }
    if (disableScroll) {
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.scrollView.delegate = self;
    }
    else {
        self.webView.scrollView.scrollEnabled = YES;
        self.webView.scrollView.delegate = nil;
    }

    _disableScroll = disableScroll;
}

-(id)nil_inputAccessoryView {
	return nil;
}

- (void)unswizzleInputAccessoryView {
	for (UIView* view in self.webView.scrollView.subviews) {
		NSString* currentClassName = NSStringFromClass(view.class);
		if ([currentClassName hasPrefix:swizzled]) {
			NSString *originalClassName = [currentClassName substringFromIndex:[swizzled length]];
			Class originalClass = NSClassFromString(originalClassName);
			object_setClass(view, originalClass);
		}
	}
}

- (Class)getSwizzledSubclassOfView:(Class)viewClass {
	NSString* swizzledClassName = [NSString stringWithFormat:@"%@%@", swizzled, NSStringFromClass(viewClass)];
	Class newClass = [_swizzledClassNameToClass objectForKey:swizzledClassName];
	if(newClass == nil) {
		newClass = objc_allocateClassPair(viewClass, [swizzledClassName UTF8String], 0);
		[_swizzledClassNameToClass setObject:newClass forKey:swizzledClassName];
		IMP nilImp = [self methodForSelector:@selector(nil_inputAccessoryView)];
		class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
		objc_registerClassPair(newClass);
	}
	return newClass;
}

- (void)swizzleInputAccessoryView {
	for (UIView* view in self.webView.scrollView.subviews) {
		//only swizzle unswizzled instances whose class starts with UIWeb
		if(![NSStringFromClass(view.class) hasPrefix:swizzled] && [NSStringFromClass(view.class) hasPrefix:@"UIWeb"]) {
			Class swizzledClass = [self getSwizzledSubclassOfView:view.class];
			object_setClass(view, swizzledClass);
		}
	}
}

- (BOOL)hideKeyboardAccessoryBar {
	return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar {
	if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar || ![self.webView isKindOfClass:[UIWebView class]]) {
		return;
	}
	if (hideKeyboardAccessoryBar) {
		[self swizzleInputAccessoryView];
	}
	else {
		[self unswizzleInputAccessoryView];
	}
	
	_hideKeyboardAccessoryBar = hideKeyboardAccessoryBar;
}

/*
- (BOOL)styleDark {
    return _styleDark;
}

- (void)setStyleDark:(BOOL)styleDark {
    if (styleDark == _styleDark) {
        return;
    }
    if (styleDark) {
        self.webView.styleDark = YES;
    }
    else {
        self.webView.styleDark = NO;
    }

    _styleDark = styleDark;
}
*/


/* ------------------------------------------------------------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView setContentOffset: CGPointZero];
}

/* ------------------------------------------------------------- */

- (void)dealloc {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/* ------------------------------------------------------------- */

- (void) disableScroll:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    if (value != [NSNull null]) {
      self.disableScroll = [value boolValue];
    }
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command {
	if (!command.arguments || ![command.arguments count]){
		return;
	}
	id value = [command.arguments objectAtIndex:0];
	if (value != [NSNull null]) {
		self.hideKeyboardAccessoryBar = [value boolValue];
	}
}

- (void) close:(CDVInvokedUrlCommand*)command {
    [self.webView endEditing:YES];
}

- (void) show:(CDVInvokedUrlCommand*)command {
    NSLog(@"Showing keyboard not supported in iOS due to platform limitations.");
}

/*
- (void) styleDark:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];

    self.styleDark = [value boolValue];
}
*/

@end

