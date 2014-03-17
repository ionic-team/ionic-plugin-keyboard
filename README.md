Keyboard
======

> The `Keyboard` object provides some functions to customize the iOS keyboard.


Methods
-------

- Keyboard.resizeView
- Keyboard.hideKeyboardAccessoryBar

Permissions
-----------

#### config.xml

            <feature name="Keyboard">
                <param name="ios-package" value="IonicKeyboard" onload="true" />
            </feature>


Keyboard.resizeView
=================

Shift the webview up by the specified offset amount.

    Keyboard.shrinkView(93.0);

To keep the WebView from shifting when selecting inputs:
    
    Keyboard.shrinkView(0.0);

To return to default WebView behavior, specify any negative value.
   
    Keyboard.shrinkView(-1.0);
  

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


Keyboard.close
=================

Close the keyboard if it is open.

    Keyboard.close();

Supported Platforms
-------------------

- iOS

    
