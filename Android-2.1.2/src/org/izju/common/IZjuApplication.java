package org.izju.common;

import org.izju.parse.ParseUtil;
import org.izju.push.PushUtil;

import android.app.Application;
import android.util.Log;

public class IZjuApplication extends Application {
    private static final String TAG = "IZjuApplication";

    @Override
    public void onCreate() {
    	 Log.d(TAG, "onCreate");
         super.onCreate();
         
         PushUtil.init(this);
         ParseUtil.init(this);
    }
}
