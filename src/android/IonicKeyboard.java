package com.ionic.keyboard;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.inputmethod.InputMethodManager;

public class IonicKeyboard extends CordovaPlugin {
	
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        //calculate density-independent pixels (dp)
        //http://developer.android.com/guide/practices/screens_support.html
        DisplayMetrics dm = new DisplayMetrics();
        cordova.getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);
        final float density = dm.density;
        
        //http://stackoverflow.com/a/4737265/1091751 detect if keyboard is showing
        final View rootView = cordova.getActivity().getWindow().getDecorView().findViewById(android.R.id.content).getRootView();
        OnGlobalLayoutListener list = new OnGlobalLayoutListener() {
            int previousHeightDiff = 0;
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();
                //r will be populated with the coordinates of your view that area still visible.
                rootView.getWindowVisibleDisplayFrame(r);

                int heightDiff = rootView.getRootView().getHeight() - (r.bottom - r.top);
                int pixelHeightDiff = (int)(heightDiff / density);
                
                if (pixelHeightDiff > 100 && pixelHeightDiff != previousHeightDiff) { // if more than 100 pixels, its probably a keyboard...
                    sendJavascript("cordova.plugins.Keyboard.isVisible = true");
                    sendJavascript("cordova.fireWindowEvent('native.keyboardshow', { 'keyboardHeight':" + Integer.toString(pixelHeightDiff)+"});");

                    //deprecated
                    sendJavascript("cordova.fireWindowEvent('native.showkeyboard', { 'keyboardHeight':" + Integer.toString(pixelHeightDiff)+"});");
                }
                else if ( pixelHeightDiff != previousHeightDiff && ( previousHeightDiff - pixelHeightDiff ) > 100 ){
                    sendJavascript("cordova.plugins.Keyboard.isVisible = false");
                    sendJavascript("cordova.fireWindowEvent('native.keyboardhide')");

                    //deprecated
                    sendJavascript("cordova.fireWindowEvent('native.hidekeyboard')");
                }
                previousHeightDiff = pixelHeightDiff;
             }
        };

        rootView.getViewTreeObserver().addOnGlobalLayoutListener(list);
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if ("close".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    //http://stackoverflow.com/a/7696791/1091751
                    InputMethodManager inputManager = (InputMethodManager) cordova.getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                    View v = cordova.getActivity().getCurrentFocus();

                    if (v == null) {
                        callbackContext.error("No current focus");
                    }
                    inputManager.hideSoftInputFromWindow(v.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                    callbackContext.success(); // Thread-safe.
                }
            });
            return true;
        }
        if ("show".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    ((InputMethodManager) cordova.getActivity().getSystemService(Context.INPUT_METHOD_SERVICE)).toggleSoftInput(0, InputMethodManager.HIDE_IMPLICIT_ONLY);
                    callbackContext.success(); // Thread-safe.
                }
            });
            return true;
        }
        return false;  // Returning false results in a "MethodNotFound" error.
    }

	@TargetApi(Build.VERSION_CODES.KITKAT)
	private void sendJavascript(final String javascript) {

		webView.post(new Runnable() {
		    @Override
		    public void run() {
				// See: https://github.com/GoogleChrome/chromium-webview-samples/blob/master/jsinterface-example/src/com/google/chrome/android/example/jsinterface/MainActivity.java
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
					webView.evaluateJavascript(javascript, null);
				} else {
					webView.loadUrl("javascript:" + javascript);
				}
		    }
		});
	}
}

