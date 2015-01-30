/*
* Copyright (c) 2013 BlackBerry Limited
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

var keyboard,
	resultObjs = {},
	threadCallback = null,
   _utils = require("../../lib/utils");
   _event = require("../../lib/event");
    _webview = require("../../lib/webview");




module.exports = {

	// Code can be declared and used outside the module.exports object,
	// but any functions to be called by client.js need to be declared
	// here in this object.

	// These methods call into JNEXT.Keyboard which handles the
	// communication through the JNEXT plugin to keyboard_js.cpp
	startService: function (success, fail, args, env) {
	var result = new PluginResult(args, env);
		
	result.ok(keyboard.getInstance().startService(), false);
	},
	show: function (success, fail, args, env) {
		var result = new PluginResult(args, env);
		
		result.ok(keyboard.getInstance().showKeyboard(), false);
	},
	close: function (success, fail, args, env) {
	var result = new PluginResult(args, env);
		
	result.ok(keyboard.getInstance().closeKeyboard(), false);
	}
};

keyboardShow = function(a){

	_webview.executeJavascript("cordova.fireDocumentEvent('native.keyboardshow',"+a+")");
}
keyboardHide = function(){

	_webview.executeJavascript("cordova.fireDocumentEvent('native.keyboardhide','')");
}
onStart = function() {
		_webview.executeJavascript("cordova.exec("+null+", "+null+", 'com.ionic.keyboard', 'startService', '')");
	}

setTimeout(onStart,2000);

///////////////////////////////////////////////////////////////////
// JavaScript wrapper for JNEXT plugin for connection
///////////////////////////////////////////////////////////////////

JNEXT.Keyboard = function () {
	var self = this,
		hasInstance = false;

	self.getId = function () {
		return self.m_id;
	};

	self.init = function () {
		if (!JNEXT.require("libKeyboard")) {
			return false;
		}

		self.m_id = JNEXT.createObject("libKeyboard.Keyboard_JS");

		if (self.m_id === "") {
			return false;
		}

		JNEXT.registerEvents(self);
	};

	// ************************
	// Enter your methods here
	// ************************

	// calls into InvokeMethod(string command) in keyboard_js.cpp
	self.startService = function () {
		return JNEXT.invoke(self.m_id, "startService");
	};
	self.showKeyboard = function () {
		return JNEXT.invoke(self.m_id, "showKeyboard");
	};
	self.closeKeyboard = function () {
		return JNEXT.invoke(self.m_id, "closeKeyboard");
	};
	self.keyboardTest = function () {
		return JNEXT.invoke(self.m_id, "keyboardTest");
	};
	self.keyboardTestInput = function (callbackId, input) {
		return JNEXT.invoke(self.m_id, "keyboardTestInput " + callbackId + " " + input);
	};
	self.keyboardTestAsync = function (callbackId, input) {
		return JNEXT.invoke(self.m_id, "keyboardTestAsync " + callbackId + " " + JSON.stringify(input));
	};
	self.keyboardProperty = function (callbackId, value) {
		if (value) {
			return JNEXT.invoke(self.m_id, "keyboardProperty " + callbackId + " " + value);
		} else {
			return JNEXT.invoke(self.m_id, "keyboardProperty");
		}
	};

	self.onEvent = function (strData) 	{ 	// Fired by the Event framework (used by asynchronous callbacks)
		var arData = strData.split(" "),
        strEventDesc = arData[0],
        jsonData;

	if (strEventDesc === "native.keyboardshow") {
		    	jsonData = arData.slice(1, arData.length).join(" ");
		    	keyboardShow(jsonData);
		    	
    }
    else if (strEventDesc === "native.keyboardhide") {		 
		    	keyboardHide();
    }

	};

	// Thread methods
	self.keyboardStartThread = function (callbackId) {
		return JNEXT.invoke(self.m_id, "keyboardStartThread " + callbackId);
	};
	self.keyboardStopThread = function () {
		return JNEXT.invoke(self.m_id, "keyboardStopThread");
	};

	// ************************
	// End of methods to edit
	// ************************
	self.m_id = "";

	self.getInstance = function () {
		if (!hasInstance) {
			hasInstance = true;
			self.init();
		}
		return self;
	};

};

keyboard = new JNEXT.Keyboard();

