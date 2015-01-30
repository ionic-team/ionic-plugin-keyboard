
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    _ID = "com.ionic.keyboard";

var Keyboard = function() {
};

Keyboard.hideKeyboardAccessoryBar = function(hide) {
    exec(null, null, "Keyboard", "hideKeyboardAccessoryBar", [hide]);
};

Keyboard.close = function() {
	

 		exec(null, null, "Keyboard", "close", []);
 		exec(null, null, _ID, "close", []);
	
};

Keyboard.show = function() {

 		exec(null, null, "Keyboard", "show", []);
		exec(null, null, _ID, "show", []);
};

Keyboard.disableScroll = function(disable) {
 exec(null, null, "Keyboard", "disableScroll", [disable]);
};

/*
Keyboard.styleDark = function(dark) {
 exec(null, null, "Keyboard", "styleDark", [dark]);
};
*/

Keyboard.isVisible = false;

module.exports = Keyboard;



