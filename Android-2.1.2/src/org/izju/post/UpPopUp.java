package org.izju.post;

import java.util.Timer;
import java.util.TimerTask;

import org.izju.R;
import org.izju.common.Constants;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

public class UpPopUp {
	
	private PopupTimer popupTimer = new PopupTimer(); 
    private PopupWindow floatingWindow;
    private LinearLayout floatingContainer;
	
	public UpPopUp(Activity activity) {
		floatingContainer = (LinearLayout) activity.getLayoutInflater()
											.inflate(R.layout.up_popup, null);
        floatingWindow = new PopupWindow(activity);
        floatingWindow.setClippingEnabled(false);
        floatingWindow.setBackgroundDrawable(null);
        floatingWindow.setInputMethodMode(PopupWindow.INPUT_METHOD_NOT_NEEDED);
        
        floatingContainer.measure(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        floatingWindow.setContentView(floatingContainer);
        floatingWindow.setWidth(floatingContainer.getMeasuredWidth());
        floatingWindow.setHeight(floatingContainer.getMeasuredHeight());
	}
	
	public void show(View v, int x, int y) {
		popupTimer.postShowFloatingWindow(v, x, y);
	}
	
    private class PopupTimer extends Handler implements Runnable {
    	
        protected static final String TAG = "PopupTimer";
		private int mParentLocation[] = new int[2];
        private View view;
        private int x, y;
        
        Handler handler = new Handler() {
   		 public void handleMessage(Message msg) {
 		 	switch (msg.what) {
 		 	case 0: // dismiss floating window
 		 		Log.d(TAG, "dismiss floating window");
 		 		cancelShowing();
 		 		break;
 		 	}
 	    }
        };

        void postShowFloatingWindow() {
            floatingWindow.setAnimationStyle(R.style.Animation);
            post(this);
        }
        
        void postShowFloatingWindow(View view, int x, int y) {
        	this.view = view;
        	this.x = x;
        	this.y = y;
        	
        	postShowFloatingWindow();
        	Timer timer = new Timer(false);
        	timer.schedule(new TimerTask() {

				@Override
				public void run() {
					handler.sendEmptyMessage(0);
				}
        		
        	}, Constants.POPUP_TIME);
        }

        void cancelShowing() {
            if (null != floatingWindow && floatingWindow.isShowing()) {
            	floatingWindow.dismiss();
            	floatingWindow = null;
            }
            removeCallbacks(this);
        }

        public void run() {
            view.getLocationInWindow(mParentLocation);
            
            if (null == floatingWindow)
            	return;

            if (!floatingWindow.isShowing()) {
            	floatingWindow.showAtLocation(view, Gravity.LEFT | Gravity.TOP, 
            			                      x, y);
            } else {
            	floatingWindow.update(x, y, floatingWindow.getWidth(), 
            			              floatingWindow.getHeight());
            }
        }
    }
}
