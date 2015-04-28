#import "IonicKeyboard.h"
#import "UIWebViewExtension.h"
#import <Cordova/CDVAvailability.h>
#import <objc/runtime.h>

@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize disableScroll = _disableScroll;
//@synthesize styleDark = _styleDark;

UITextField *textField;

- (void)pluginInitialize {
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;
    
    //set defaults
    self.hideKeyboardAccessoryBar = NO;
    self.disableScroll = NO;
    //self.styleDark = NO;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:15];
    textField.placeholder = @"enter text";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    [self.webView addSubview:textField];
    
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    _keyboardDidShowObserver = [nc addObserverForName:UIKeyboardDidShowNotification
                                               object:nil
                                                queue:[NSOperationQueue mainQueue]
                                           usingBlock:^(NSNotification* notification) {
                                               
                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                   [self addButtonToKeyboard];
                                               });
                                           }];
    
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

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    for (UIView *subview in subviews) {
        /*int i=0;
        unsigned int mc = 0;
        Method * mlist = class_copyMethodList(object_getClass(subview), &mc);
        NSLog(@"%d methods", mc);
        for(i=0;i<mc;i++){
            NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
        }*/
        
        if ([subview respondsToSelector:@selector(key)]){
            NSLog(@"woot");
            
            NSString *s = (NSString*)[[subview performSelector:@selector(key)] performSelector:@selector(name)];
            
            if ([s isEqualToString:@"Return-Key"]){
                NSLog(@"found it");
                [[subview performSelector:@selector(key)] performSelector:@selector(setName:) withObject:@"Next"];
                [[subview performSelector:@selector(key)] performSelector:@selector(setDisplayString:) withObject:@"Next"];
                [[subview performSelector:@selector(key)] performSelector:@selector(setOverrideDisplayString:) withObject:@"Next"];
                [self.webView reloadInputViews];
            }
            else if ([s isEqualToString:@"Next"]){
                [[subview performSelector:@selector(key)] performSelector:@selector(setName:) withObject:@"Next"];
                [[subview performSelector:@selector(key)] performSelector:@selector(setDisplayString:) withObject:@"Next"];
                [[subview performSelector:@selector(key)] performSelector:@selector(setOverrideDisplayString:) withObject:@"Next"];
            }
        }
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}


- (void)addButtonToKeyboard
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // create custom button
        UIButton * doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(243, 169, 75, 43);
        doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [doneButton setTitle:@"Hello" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setBackgroundColor:[UIColor blueColor]];
        doneButton.layer.cornerRadius = 5.0f;
        doneButton.adjustsImageWhenHighlighted = NO;
        [doneButton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
        
        // locate keyboard view
        UIWindow * tempWindow = [[[UIApplication sharedApplication] windows]objectAtIndex:1];
        //UIView* keyboard;
        
        [self listSubviewsOfView:tempWindow];
        /*
        for(int i=0; i<[tempWindow.subviews count]; i++)
        {
            keyboard = [tempWindow.subviews objectAtIndex:i];
            keyboard = [[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:1] subviews] objectAtIndex:0];
            keyboard = [[keyboard subviews] objectAtIndex:0];
            
            if ([keyboard respondsToSelector:@selector(returnKeyType)]){
                int keyboardType = (int)[keyboard performSelector:@selector(returnKeyType)];
                NSLog(@"performed returnKey selector: %@", [@(keyboardType) stringValue]);
            }
            if ([keyboard respondsToSelector:@selector(setReturnKeyType:)]){
                [keyboard performSelector:@selector(setReturnKeyType:) withObject:[NSNumber numberWithInt:7]];
                NSLog(@"performed setReturnKey selector");
            }
            if ([keyboard respondsToSelector:@selector(returnKeyType)]){
                int keyboardType = (int)[keyboard performSelector:@selector(returnKeyType)];
                NSLog(@"performed returnKey selector: %@", [@(keyboardType) stringValue]);
            }
         
            
            
            
        }*/
    }
    
}

-(void) test:(id)sender {
    NSLog(@"Done clicked");
}

/*-(void) removeSearchButtonFromKeypad {
    
    int windowCount = [[[UIApplication sharedApplication] windows] count];
    if (windowCount < 2) {
        return;
    }
    
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    
    for(int i = 0 ; i < [tempWindow.subviews count] ; i++)
    {
        UIView* keyboard = [tempWindow.subviews objectAtIndex:i];
        
        if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES){
            [self removeButton:keyboard];
            
        }else if([[keyboard description] hasPrefix:@"<UIInputSetContainerView"] == YES){
            
            for(int i = 0 ; i < [keyboard.subviews count] ; i++)
            {
                UIView* hostkeyboard = [keyboard.subviews objectAtIndex:i];
                
                if([[hostkeyboard description] hasPrefix:@"<UIInputSetHost"] == YES){
                    //[self removeButton:hostkeyboard];
                    //UIView* kb = [[[[hostkeyboard subviews] objectAtIndex:1] subviews] objectAtIndex:0];
                    UIView* kb = [[[[[[hostkeyboard subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
                    
                    if ([kb respondsToSelector:@selector(returnKeyType)]) {
                        
                    }
                    
                }
            }
        }
    }
}


-(void) removeButton:(UIView*)keypadView{
    UIButton* donebtn = (UIButton*)[keypadView viewWithTag:67123];
    if(donebtn){
        [donebtn removeFromSuperview];
        donebtn = nil;
    }
}*/


- (void)textFieldDidChange:(NSNotification *)notification {
    NSLog(@"lol");
    UITextField *textField = (UITextField*)notification;
    
    
    NSString *text = [textField text];
    //NSString *text = [notification
    // Do whatever you like to respond to text changes here.
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"cordova.plugins.Keyboard.updateInput({'text': '%@'})", text]];
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


- (BOOL)hideKeyboardAccessoryBar {
    return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar {
    if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar) {
        return;
    }
    if (hideKeyboardAccessoryBar) {
        self.webView.hackishlyHidesInputAccessoryView = YES;
    }
    else {
        self.webView.hackishlyHidesInputAccessoryView = NO;
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
    
    self.disableScroll = [value boolValue];
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
        return;
    }
    id value = [command.arguments objectAtIndex:0];
    
    self.hideKeyboardAccessoryBar = [value boolValue];
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


