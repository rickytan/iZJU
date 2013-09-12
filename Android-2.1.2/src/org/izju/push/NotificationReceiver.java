package org.izju.push;

import org.izju.activity.HuodongDetailActivity;
import org.izju.activity.JiaoliuDetailActivity;
import org.izju.common.Constants;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import cn.jpush.android.api.JPushInterface;

public class NotificationReceiver extends BroadcastReceiver {
	private static final String TAG = "NotificationReceiver";

	@Override
	public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
		Log.d(TAG, "onReceive - " + intent.getAction() + 
				   ", extras: " + printBundle(bundle));
		
        if (JPushInterface.ACTION_REGISTRATION_ID.equals(intent.getAction())) {
            Log.d(TAG, "register successfully");
        } else if (JPushInterface.ACTION_MESSAGE_RECEIVED
        		.equals(intent.getAction())) {
        	Log.d(TAG, "ACTION_MESSAGE_RECEIVED: ");
        
        } else if (JPushInterface.ACTION_NOTIFICATION_RECEIVED
        		.equals(intent.getAction())) {
            Log.d(TAG, "ACTION_NOTIFICATION_RECEIVED");
        } else if (JPushInterface.ACTION_NOTIFICATION_OPENED
        		.equals(intent.getAction())) {        	
        	Intent newIntent = new Intent();
        	newIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        	
        	String extra = bundle.getString(JPushInterface.EXTRA_EXTRA);
        	String channel = null, articleId = null;
        	if (null != extra) {
        		JSONObject jsonData = null;
				try {
					jsonData = new JSONObject(extra);
	            	channel = jsonData.getString(Constants.PUSH_KEY_CHANNEL);
	            	articleId = jsonData.getString(Constants.PUSH_KEY_ARITICLE_ID);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
        	}
        	
        	if (null == channel || null == articleId) {
        		newIntent.setClass(context, NotificationDetailActivity.class);
        		
        		String title = bundle.getString(
        				JPushInterface.EXTRA_NOTIFICATION_TITLE);
        		String content = bundle.getString(JPushInterface.EXTRA_ALERT);
        		newIntent.putExtra(Constants.EXTRA_NAME_NOTIFCATION_TITLE, 
        						   title);
        		newIntent.putExtra(Constants.EXTRA_NAME_NOTIFCATION_CONTENT, 
        						   content);
        	}else if (channel.equals(Constants.CHANNEL_NAME_ACTIVITY)) {
    			newIntent.setClass(context, HuodongDetailActivity.class);
    			newIntent.putExtra("id", articleId);
        	} else if (channel.equals(Constants.CHANNEL_NAME_EXCHANGE)) {
    			newIntent.setClass(context, JiaoliuDetailActivity.class);
    			newIntent.putExtra("id", articleId);
        	}
        	context.startActivity(newIntent);

        } else {
        	Log.d(TAG, "Unhandled intent - " + intent.getAction());
        }
	}

	// 352993053348421
	private static String printBundle(Bundle bundle) {
		StringBuilder sb = new StringBuilder();
		for (String key : bundle.keySet()) {
			sb.append("\nkey:" + key + ", value:" + bundle.getString(key));
		}
		return sb.toString();
	}
	

}
