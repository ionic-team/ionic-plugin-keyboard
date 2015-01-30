/*
 * CallKeyboard.h
 *
 *  Created on: 19/12/2014
 *      Author: gualberto
 */

#ifndef CALLKEYBOARD_H_
#define CALLKEYBOARD_H_
#include <bb/AbstractBpsEventHandler>
#include <bps/bps.h>
#include<bps/netstatus.h>
#include<bps/locale.h>
#include<bps/virtualkeyboard.h>
#include<bps/navigator.h>
#include <bps/event.h>
#include "keyboard_ndk.hpp"
#include <pthread.h>

class Keyboard_JS;

namespace webworks {

class CallKeyboard : public bb::AbstractBpsEventHandler
{


public:
    CallKeyboard(Keyboard_JS *parent = NULL);
    virtual ~CallKeyboard();
    virtual void event(bps_event_t *event);
    void callKeyboardEmail();
    void callKeyboardNumber();
    void cancelKeyboard();
private:
    Keyboard_JS *m_pParent;
};
}

#endif /* CALLKEYBOARD_H_ */
