/*
 * CallKeyboard.cpp
 *
 *  Created on: 19/12/2014
 *      Author: gualberto
 */

#include "CallKeyboard.h"

#include<iostream.h>
#include <QThread>

namespace webworks {
CallKeyboard::CallKeyboard(Keyboard_JS *parent):bb::AbstractBpsEventHandler(),m_pParent(parent)
{


    // TODO Auto-generated constructor stub
    bps_initialize();

    // Subscribe to domains
  //  subscribe(netstatus_get_domain());
  //  subscribe(locale_get_domain());
    subscribe(virtualkeyboard_get_domain());
    subscribe(navigator_get_domain());

    // Request events


    virtualkeyboard_request_events(0);
    navigator_request_events(0);


  //  netstatus_request_events(0);
  //  locale_request_events(0);

    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_EMAIL,VIRTUALKEYBOARD_ENTER_SEND);
    virtualkeyboard_show();
    //qDebug() << "asdasd";
    //m_pParent->getLog()->info("Keyboard Created");


}

CallKeyboard::~CallKeyboard()
{
    bps_shutdown();
    // TODO Auto-generated destructor stub
}
void CallKeyboard::event(bps_event_t *event) {

    int domain = bps_event_get_domain(event);
      if (domain == virtualkeyboard_get_domain()) {
          int code = bps_event_get_code(event);
          switch(code) {
              case VIRTUALKEYBOARD_EVENT_VISIBLE:
                  // Do something
//m_pParent->NotifyEvent("teste");
                  break;
              case VIRTUALKEYBOARD_EVENT_HIDDEN:

                  break;
          }
      }

}
void CallKeyboard::callKeyboardEmail(){
    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_EMAIL,VIRTUALKEYBOARD_ENTER_SEND);
    virtualkeyboard_show();
}

void CallKeyboard::callKeyboardNumber(){

    virtualkeyboard_change_options(VIRTUALKEYBOARD_LAYOUT_NUMBER,VIRTUALKEYBOARD_ENTER_SEND);
    virtualkeyboard_show();
}
void CallKeyboard::cancelKeyboard(){
    virtualkeyboard_hide();
}

}
