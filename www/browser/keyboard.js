
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');


var Keyboard = function() {
};

Keyboard.hideKeyboardAccessoryBar = function(hide, onSuccess) {
    if(typeof onSuccess == 'function') onSuccess();
    return null;
};

Keyboard.close = function(onSuccess) {
    if(typeof onSuccess == 'function') onSuccess();
    return null;
};

Keyboard.show = function(onSuccess) {
    if(typeof onSuccess == 'function') onSuccess();
    return null;
};

Keyboard.disableScroll = function(disable, onSuccess) {
    if(typeof onSuccess == 'function') onSuccess();
    return null;
};

/*
Keyboard.styleDark = function(dark) {
 exec(null, null, "Keyboard", "styleDark", [dark]);
};
*/

Keyboard.isVisible = false;

module.exports = Keyboard;
