cordova.define("org.apache.cordova.keyboard.keyboard", function(require, exports, module) {/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');
   
var Keyboard = function() {
};

Keyboard.resizeView = function(scroll) {
    exec(null, null, "Keyboard", "resizeView", [scroll]);
};

Keyboard.hideKeyboardAccessoryBar = function(hide) {
    exec(null, null, "Keyboard", "hideKeyboardAccessoryBar", [hide]);
};

Keyboard.close = function() {
 exec(null, null, "Keyboard", "closeKeyboard", []);
};

Keyboard.close = function() {
 exec(null, null, "Keyboard", "closeKeyboard", []);
};

module.exports = Keyboard;
});

