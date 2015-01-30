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

#include <string>
#include <sstream>
#include <json/reader.h>
#include <json/writer.h>
#include <pthread.h>
#include "keyboard_ndk.hpp"
#include "keyboard_js.hpp"
#include <QtCore>
namespace webworks {

Keyboard_NDK::Keyboard_NDK(Keyboard_JS *parent):
	m_pParent(parent),
	keyboardProperty(50),
	keyboardThreadCount(1),
	threadHalt(true),
	m_thread(0) {
		pthread_cond_t cond  = PTHREAD_COND_INITIALIZER;
		pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
	   bps_initialize();
	  // subscribe(virtualkeyboard_get_domain());
	    //subscribe(navigator_get_domain());
	    virtualkeyboard_request_events(0);
	    //navigator_request_events(0);
	    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_EMAIL,VIRTUALKEYBOARD_ENTER_SEND);
	   //virtualkeyboard_show();
		m_pParent->getLog()->info("Keyboard Created");


}


Keyboard_NDK::~Keyboard_NDK() {
    //bps_shutdown();
}

// These methods are the true native code we intend to reach from WebWorks
std::string Keyboard_NDK::keyboardTest() {
	m_pParent->getLog()->debug("testString");
	return "Keyboard Test Function";
}

// Take in input and return a value
std::string Keyboard_NDK::keyboardTest(const std::string& inputString) {
	m_pParent->getLog()->debug("testStringInput");
	//m_pParent->NotifyEvent("Teste");

	return "Keyboard Test Function, got: " + inputString;
}

// Get an integer property
std::string Keyboard_NDK::getKeyboardProperty() {
	m_pParent->getLog()->debug("getKeyboardProperty");
	stringstream ss;
	ss << keyboardProperty;
	return ss.str();
}

// set an integer property
void Keyboard_NDK::setKeyboardProperty(const std::string& inputString) {
	m_pParent->getLog()->debug("setKeyboardProperty");
	keyboardProperty = (int) strtoul(inputString.c_str(), NULL, 10);
}

// Asynchronous callback with JSON data input and output
void Keyboard_NDK::keyboardTestAsync(const std::string& callbackId, const std::string& inputString) {
	m_pParent->getLog()->debug("Async Test");
	// Parse the arg string as JSON
	Json::FastWriter writer;
	Json::Reader reader;
	Json::Value root;
	bool parse = reader.parse(inputString, root);

	if (!parse) {
		m_pParent->getLog()->error("Parse Error");
		Json::Value error;
		error["result"] = "Cannot parse JSON object";
		m_pParent->NotifyEvent(callbackId + " " + writer.write(error));
	} else {
		root["result"] = root["value1"].asInt() + root["value2"].asInt();
		m_pParent->NotifyEvent(callbackId + " " + writer.write(root));
	}
}

// Thread functions
// The following functions are for controlling a Thread in the extension

// The actual thread (must appear before the startThread method)
// Loops and runs the callback method
void* KeyboardThread(void* parent) {
	Keyboard_NDK *pParent = static_cast<Keyboard_NDK *>(parent);

	// Loop calls the callback function and continues until stop is set
/*	while (!pParent->isThreadHalt()) {
		sleep(1);
		pParent->keyboardThreadCallback();
	}
*/
/*	while(1){
pParent->event()
	}
	return NULL;*/
	sleep(1);

	 // 1. Start the library
	 bps_initialize();

	 // 2. Request events to flow into the event queue
	 virtualkeyboard_request_events(0);

	 sleep(3);
	 // 3. Use any service at any time
	 //virtualkeyboard_show(); // Show the virtual keyboard

	 // 4. Listen for events
	 for (;;) {
	   // get an event
	    bps_event_t *event;
	    bps_get_event(&event, -1); // blocking

	    // handle the event
	    pParent->event(event);
	 }
	 return NULL;
}

// Starts the thread and returns a message on status
std::string Keyboard_NDK::keyboardStartThread() {
    m_pParent->NotifyEvent("Teste");
    if (!m_thread) {
	    m_pParent->NotifyEvent("Teste");
		int rc;
	    rc = pthread_mutex_lock(&mutex);
	    threadHalt = false;
	    rc = pthread_cond_signal(&cond);
	    rc = pthread_mutex_unlock(&mutex);

		pthread_attr_t thread_attr;
		pthread_attr_init(&thread_attr);
		pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_JOINABLE);

		pthread_create(&m_thread, &thread_attr, KeyboardThread,
				static_cast<void *>(this));
		pthread_attr_destroy(&thread_attr);
		//threadCallbackId = callbackId;
		m_pParent->getLog()->info("Thread Started");
		return "Thread Started";
	} else {
		m_pParent->getLog()->warn("Thread Started but already running");
		return "Thread Running";
	}
}

// Sets the stop value
std::string Keyboard_NDK::keyboardStopThread() {
	int rc;
	// Request thread to set prevent sleep to false and terminate
	rc = pthread_mutex_lock(&mutex);
	threadHalt = true;
	rc = pthread_cond_signal(&cond);
	rc = pthread_mutex_unlock(&mutex);

    // Wait for the thread to terminate.
    void *exit_status;
    rc = pthread_join(m_thread, &exit_status) ;

	// Clean conditional variable and mutex
	pthread_cond_destroy(&cond);
	pthread_mutex_destroy(&mutex);

	m_thread = 0;
	threadHalt = true;
	m_pParent->getLog()->info("Thread Stopped");
	return "Thread stopped";
}

// The callback method that sends an event through JNEXT
void Keyboard_NDK::keyboardThreadCallback() {
	Json::FastWriter writer;
	Json::Value root;
	root["threadCount"] = keyboardThreadCount++;
	m_pParent->NotifyEvent(threadCallbackId + " " + writer.write(root));
}

// getter for the stop value
bool Keyboard_NDK::isThreadHalt() {
	int rc;
	bool isThreadHalt;
	rc = pthread_mutex_lock(&mutex);
	isThreadHalt = threadHalt;
	rc = pthread_mutex_unlock(&mutex);
	return isThreadHalt;
}

void Keyboard_NDK::event(bps_event_t *event) {
    Json::FastWriter writer;
    Json::Value root;
    root["threadCount"] = "10";
    int domain = bps_event_get_domain(event);
      if (domain == virtualkeyboard_get_domain()) {
          int code = bps_event_get_code(event);
          int a;
          std::string str;
          std::string eventString;
          std::ostringstream strs;
          switch(code) {
              case VIRTUALKEYBOARD_EVENT_VISIBLE:
                 // m_pParent->getLog()->debug("Visible");
                 // m_pParent->NotifyEvent("Visi");
                  eventString = "native.keyboardshow";
                  eventString.append(" ");
                  virtualkeyboard_get_height(&a) ;
                  strs << a;
                  str = strs.str();
                  eventString.append("{\"keyboardHeight\":\""+str+"\"}");
                  m_pParent->NotifyEvent(eventString);

                  break;
              case VIRTUALKEYBOARD_EVENT_HIDDEN:

                  m_pParent->NotifyEvent("native.keyboardhide");
                  break;
          }
      }

}
void Keyboard_NDK::callKeyboardEmail(){
    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_EMAIL,VIRTUALKEYBOARD_ENTER_SEND);
    virtualkeyboard_show();
}

void Keyboard_NDK::callKeyboardNumber(){

    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_NUMBER,VIRTUALKEYBOARD_ENTER_SEND);
    virtualkeyboard_show();
}
void Keyboard_NDK::cancelKeyboard(){
    virtualkeyboard_hide();
}




} /* namespace webworks */
