
/*global Windows, WinJS, cordova, module, require*/

var inputPane = Windows.UI.ViewManagement.InputPane.getForCurrentView();
var keyboardScrollDisabled = false;

inputPane.addEventListener('hiding', function() {
    cordova.fireDocumentEvent('native.keyboardhide');
    cordova.plugins.Keyboard.isVisible = false;
});

inputPane.addEventListener('showing', function(e) {
    if (keyboardScrollDisabled) {
        // this disables automatic scrolling of view contents to show focused control
        e.ensuredFocusedElementInView = true;
    }
    cordova.fireDocumentEvent('native.keyboardshow', { keyboardHeight: e.occludedRect.height });
    cordova.plugins.Keyboard.isVisible = true;
});

module.exports.disableScroll = function (win, fail, args) {
    var disable = args[0];
    keyboardScrollDisabled = disable;
};

module.exports.show = function () {
    if (typeof inputPane.tryShow === 'function') {
        inputPane.tryShow();
    }
};

module.exports.close = function () {
    if (typeof inputPane.tryShow === 'function') {
        inputPane.tryHide();
    }
};

require("cordova/exec/proxy").add("Keyboard", module.exports);
