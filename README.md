Keyboard
======

> The `Keyboard` object provides some functions to customize the iOS keyboard.


Methods
-------

- Keyboard.scrollWhenKeyboardOpens
- Keyboard.hideKeyboardAccessoryBar

Permissions
-----------

#### config.xml

            <feature name="Keyboard">
                <param name="ios-package" value="IonicKeyboard" onload="true" />
            </feature>


Keyboard.scrollWhenKeyboardOpens
=================

Shrink the WebView by the specified amount when the keyboard comes up, effectively "scrolling" the page by the specified amount.

    Keyboard.scrollWhenKeyboardOpens(93.0);

To keep the WebView from scrolling when selecting inputs:
    
    Keyboard.scrollWhenKeyboardOpens(0.0);

To return to default WebView behavior, specify any negative value.
   
    Keyboard.scrollWhenKeyboardOpens(-1.0);
  

Supported Platforms
-------------------

- iOS

Keyboard.hideKeyboardAccessoryBar
=================

Hide the keyboard accessory bar with the next, previous and done buttons.

    Keyboard.hideKeyboardAccessoryBar(true);
    Keyboard.hideKeyboardAccessoryBar(false);

Supported Platforms
-------------------

- iOS

    
