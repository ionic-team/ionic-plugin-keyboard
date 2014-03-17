#import "IonicKeyboard.h"
#import "UIWebViewAccessoryHiding.h"
#import <Cordova/CDVAvailability.h>


@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize scrollWhenKeyboardOpens = _scrollWhenKeyboardOpens;

- (void)pluginInitialize
{
    self.scrollWhenKeyboardOpens = -1.0;
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

- (CGFloat)scrollWhenKeyboardOpens
{
    return _scrollWhenKeyboardOpens;
}

- (void)setscrollWhenKeyboardOpens:(CGFloat)scrollAmount
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;

    if (scrollAmount == _scrollWhenKeyboardOpens) {
        return;
    }
    
    if (scrollAmount >= 0) {
        [nc removeObserver:_scrollWhenKeyboardOpensKeyboardShowObserver];
        _scrollWhenKeyboardOpensKeyboardShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification* notification) {
                [weakSelf performSelector:@selector(scrollWhenKeyboardOpensKeyboardWillShow:) withObject:notification afterDelay:0];
            }];
    }

    _scrollWhenKeyboardOpens = scrollAmount;
}

/* ------------------------------------------------------------- */

- (void)scrollWhenKeyboardOpensKeyboardWillShow:(NSNotification*)notif
{
    if (_scrollWhenKeyboardOpens < 0) {
        return;
    }
    
    CGPoint bottomOffset;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.scrollWhenKeyboardOpens, 0.0);
    bottomOffset = CGPointMake(0.0, self.scrollWhenKeyboardOpens);

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

- (void) scrollWhenKeyboardOpens:(CDVInvokedUrlCommand*)command
{
    id value = [command.arguments objectAtIndex:0];
    if (!([value isKindOfClass:[NSNumber class]])) {
        value = [NSNumber numberWithFloat:-1.0];
    }
    
    self.scrollWhenKeyboardOpens = [value floatValue];
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


@end
