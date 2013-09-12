package org.izju.common;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.util.Log;

public class NetCheckReceiver extends BroadcastReceiver{ 
         
        public static final String netACTION = "android.net.conn.CONNECTIVITY_CHANGE";
		private static final String TAG = "NetCheckReceiver"; 
        @Override 
        public void onReceive(Context context, Intent intent){ 
     
            if(intent.getAction().equals(netACTION)){ 
                Log.e(TAG, "ACTION:" + intent.getAction());
                boolean isBreak = intent.getBooleanExtra(
                		ConnectivityManager.EXTRA_NO_CONNECTIVITY, false); 
                Log.e(TAG, "is break:" + isBreak);
                if (isBreak) {
					context.sendBroadcast(new Intent(Constants.NETWORK_INACCESSIBLE));
                } else {
                	context.sendBroadcast(new Intent(Constants.NETWORK_ACCESSIBLE));
                }
            } 
       
      }
}