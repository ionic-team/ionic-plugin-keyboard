#import "IonicKeyboard.h"
#import "UIWebViewAccessoryHiding.h"
#import <Cordova/CDVAvailability.h>


@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize resizeView = _resizeView;

- (void)pluginInitialize
{
    self.resizeView = -1.0;
}

- (BOOL)hideKeyboardAccessoryBar
{
    return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar
{
    __weak IonicKeyboard* weakSelf = self;

    if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar) {
        return;
    }
    if (hideKeyboardAccessoryBar){
        weakSelf.webView.hackishlyHidesInputAccessoryView = YES;
    }
    else {
        weakSelf.webView.hackishlyHidesInputAccessoryView = NO;
    }

    _hideKeyboardAccessoryBar = hideKeyboardAccessoryBar;
}

/* ------------------------------------------------------------- */

- (CGFloat)resizeView
{
    return _resizeView;
}

- (void)setResizeView:(CGFloat)resizeOffset
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;

    if (resizeOffset == _resizeView) {
        return;
    }
    
    if (resizeOffset >= 0) {
        [nc removeObserver:_resizeViewShowObserver];
        _resizeViewShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification* notification) {
                [weakSelf performSelector:@selector(resizeViewWillShow:) withObject:notification afterDelay:0];
            }];
    }

    _resizeView = resizeOffset;
}

/* ------------------------------------------------------------- */

- (void)resizeViewWillShow:(NSNotification*)notif
{
    if (_resizeView < 0) {
        return;
    }
    
    CGPoint bottomOffset;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.resizeView, 0.0);
    bottomOffset = CGPointMake(0.0, self.resizeView);

    self.webView.backgroundColor = [UIColor whiteColor];

    [self.webView.scrollView setContentOffset:bottomOffset];
    
}

/* ------------------------------------------------------------- */

- (void)dealloc
{
    // since this is ARC, remove observers only

    //Left in because I'm a noob at Obj-C Memory management, not sure if
    // this needs to be implemented...
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //[nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/* ------------------------------------------------------------- */

#pragma Plugin interface

- (void) resizeView:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithFloat:-1.0];
    }
    
    self.resizeView = [value floatValue];
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithBool:NO];
    }
    
    self.hideKeyboardAccessoryBar = [value boolValue];
}

- (void) close:(CDVInvokedUrlCommand*)command
{
    [self.webView endEditing:YES];
}

- (void) disableScroll:(CDVInvokedUrlCommand*)command
{
    self.webView.scrollView.scrollEnabled = NO; 
}


@end
