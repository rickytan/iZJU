package org.izju.push;

import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.izju.R;
import org.izju.common.Constants;

import cn.jpush.android.api.JPushInterface;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;

public class PushUtil {
    public static final String PREFS_NAME = "JPUSH_EXAMPLE";
    public static final String PREFS_DAYS = "JPUSH_EXAMPLE_DAYS";
    public static final String PREFS_START_TIME = "PREFS_START_TIME";
    public static final String PREFS_END_TIME = "PREFS_END_TIME";
    public static final String KEY_APP_KEY = "JPUSH_APPKEY";
    
    public static void init(Context context) {
        JPushInterface.setDebugMode(true);
        JPushInterface.init(context);
        
        SharedPreferences settings = context.getSharedPreferences(
        		Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
        String pushKey = context.getString(R.string.key_push);
        String pushTimeKey = context.getString(R.string.key_push_time);
        if (!(settings.contains(pushKey) && settings.contains(pushTimeKey))) {
        	PushUtil.setPushTime(context, Constants.DEFAULT_PUSH_TIME);
        	Editor editor = settings.edit();
        	editor.putBoolean(pushKey, true);
        	editor.putInt(pushTimeKey, Constants.DEFAULT_PUSH_TIME);
        	editor.commit();
        }
    }

    /**
     * legal tag can only contain Chinese characters, letters, underscore 
     * and dash
     */
    public static boolean isValidTagAndAlias(String s) {
        Pattern p = Pattern.compile("^[\u4E00-\u9FA50-9a-zA-Z_-]{0,}$");
        Matcher m = p.matcher(s);
        return m.matches();
    }

    public static String getAppKey(Context context) {
        Bundle metaData = null;
        String appKey = null;
        try {
            ApplicationInfo ai = context.getPackageManager().getApplicationInfo(
                    context.getPackageName(), PackageManager.GET_META_DATA);
            if (null != ai)
                metaData = ai.metaData;
            if (null != metaData) {
                appKey = metaData.getString(KEY_APP_KEY);
                if ((null == appKey) || appKey.length() != 24) {
                    appKey = null;
                }
            }
        } catch (NameNotFoundException e) {

        }
        return appKey;
    }

    public static void disablePush(Context context) {
    	JPushInterface.setPushTime(context, new HashSet<Integer>(), 0, 0);
    }
    
    public static void enablePush(Context context) {
		String pushTimePrefKey = context.getString(R.string.key_push_time);
		SharedPreferences settings = context.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		
		int pushTime = settings.getInt(pushTimePrefKey, 0x0816);
		int startHour = ((pushTime & 0x00ff00) >> 8);
		int endHour = (pushTime & 0x00ff);
		setPushTime(context, startHour, endHour);
    }
    
    public static void setPushTime(Context context, 
    							   int startHour, int endHour) {
    	Set<Integer> days = new HashSet<Integer>();
    	for (int i = 0; i < 7; i++)
    		days.add(i);
    	JPushInterface.setPushTime(context, days, startHour, endHour);
    }
    
    public static void setPushTime(Context context, int pushTime) {
		int startHour = ((pushTime & 0x00ff00) >> 8);
		int endHour = (pushTime & 0x00ff);
		setPushTime(context, startHour, endHour);
    }
}
