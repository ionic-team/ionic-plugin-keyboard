
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');


var Keyboard = function() {
};

Keyboard.hideKeyboardAccessoryBar = function(hide, onSuccess, onError) {
    exec(onSuccess, onError, "Keyboard", "hideKeyboardAccessoryBar", [hide]);
};

Keyboard.close = function(onSuccess, onError) {
    exec(onSuccess, onError, "Keyboard", "close", []);
};

Keyboard.show = function(onSuccess, onError) {
    if(typeof onSuccess == 'function') onSuccess();
    console.warn('Showing keyboard not supported in iOS due to platform limitations.')
    console.warn('Instead, use input.focus(), and ensure that you have the following setting in your config.xml: \n');
    console.warn('    <preference name="KeyboardDisplayRequiresUserAction" value="false"/>\n');
    // exec(null, null, "Keyboard", "show", []);
};

Keyboard.disableScroll = function(disable, onSuccess, onError) {
    exec(onSuccess, onError, "Keyboard", "disableScroll", [disable]);
};

/*
Keyboard.styleDark = function(dark) {
 exec(null, null, "Keyboard", "styleDark", [dark]);
};
*/

Keyboard.isVisible = false;

module.exports = Keyboard;



