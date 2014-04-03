package com.ionic.keyboard; 

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;

public class IonicKeyboard extends CordovaPlugin{

	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        
        //calculate density-independent pixels (dp)
        //http://developer.android.com/guide/practices/screens_support.html
        DisplayMetrics dm = new DisplayMetrics();
        cordova.getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);
        final int density = (int)(dm.density);
        
        final CordovaWebView appView = webView;
        
        final View rootView = cordova.getActivity().getWindow().getDecorView().findViewById(android.R.id.content).getRootView();
        OnGlobalLayoutListener list = new OnGlobalLayoutListener() {
        	int previousHeightDiff = 0;
            @Override
            public void onGlobalLayout() {
            	Rect r = new Rect();
                //r will be populated with the coordinates of your view that area still visible.
                rootView.getWindowVisibleDisplayFrame(r);

                int heightDiff = rootView.getRootView().getHeight() - (r.bottom - r.top);
                if (heightDiff > 200 && heightDiff != previousHeightDiff) { // if more than 100 pixels, its probably a keyboard...
                	 int keyboardHeight = (int)(heightDiff / density);
                     appView.sendJavascript("cordova.fireWindowEvent('ionic.showkeyboard', { 'keyboardHeight':" + Integer.toString(keyboardHeight)+"});");
                }
                previousHeightDiff = heightDiff;
             }
        }; 
        
        rootView.getViewTreeObserver().addOnGlobalLayoutListener(list);
    }

}
