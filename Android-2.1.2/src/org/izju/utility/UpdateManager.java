package org.izju.utility;

import java.io.File;
import java.io.IOException;
import java.util.Random;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.util.EntityUtils;
import org.izju.activity.SplashActivity;
import org.izju.service.UpdateService;
import org.json.JSONException;
import org.json.JSONObject;

import com.baidu.mobstat.StatService;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public final class UpdateManager {
	private static final long UPDATE_TIMEOUT = 3000;
	private SplashActivity context = null;
	private final String TAG = "org.izju.utility.UpdateManager";
	private final String URL = IZjuConfig.URL;
	private final String VER = "android_version.php";
	private final String apkFile = "izju.apk";
	
	private int appVer, serVer = -1;
	private Handler getSerVerHandler;
	
	private String updateInfo;
	
	public UpdateManager(SplashActivity context){
		this.context = context;
	}
	
	public void doUpdate(){
	    Log.i(TAG, "start check update");
	    getSerVerHandler = new Handler(){
	        @Override
	        public void handleMessage(Message msg) {
	            if(msg.what == 0){
	                String serData = msg.getData().getString("result");
	                try {
	                    JSONObject json = new JSONObject(serData);
	                    serVer = json.getInt("versonCode");
	                    Log.i(TAG, "serVer: " + serVer);
	                    check();
	                } catch (JSONException e) {
	                    Log.e(TAG, "Version info on Server error!");
	                    context.next(false);
	                }
	            } else { // network error
	            	context.next(false);
	            }
	        }
	    };
	    
	    getAppVer();
	    new UpdateAsyncTask().execute(UPDATE_TIMEOUT);
	}
	
	private void check(){
	    if(serVer > appVer && new Random().nextInt(3) == 1){
	    	showUpdateDialog();
        }
        else {
            File apk = new File(Environment.getExternalStorageDirectory(), apkFile);
            if(apk.exists()){
                apk.delete();
            }
            context.next(false);
        }
	}
	
	private class UpdateAsyncTask extends AsyncTask<Long, Void, Void> {

		@Override
		protected Void doInBackground(Long... params) {
			getSerVercode(params[0]);
			return null;
		}
		
	    private void getSerVercode(long timeout){
		    Thread thread = new Thread(new Runnable(){
	            @Override
	            public void run() {
	            	updateInfo = null;
	                if(DataUtility.isNetworkAvailable(context)){
	                    BasicHttpParams httpParams = new BasicHttpParams();
	                    HttpConnectionParams.setConnectionTimeout(httpParams, 3000);
	                    HttpConnectionParams.setSoTimeout(httpParams, 3000);
	                    HttpClient client = new DefaultHttpClient(httpParams);
	                    try {
	                        HttpResponse response = client.execute(new HttpGet(URL + VER));
	                        if(response.getStatusLine().getStatusCode() == HttpStatus.SC_OK){
	                            updateInfo = EntityUtils.toString(response.getEntity());
	                        }
	                    } catch (IOException e) {
	                        Log.e(TAG, "network error.");
	                    }
	                }
	            }
	        });
		    thread.start();
		    
		    try {
				thread.join(timeout);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		    thread.interrupt();
		    
            Message msg = getSerVerHandler.obtainMessage();
            msg.what = 1;
            if (null != updateInfo) {
                Bundle bundle = new Bundle();
                bundle.putString("result", updateInfo);
                msg.what = 0;
                msg.setData(bundle);
            }
            getSerVerHandler.sendMessage(msg);
		}
	}
	
	private void getAppVer(){
		try {
			PackageManager pm = context.getPackageManager();
			PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);
			appVer = pi.versionCode;
		} catch (NameNotFoundException e) {
			Log.e(TAG, e.getMessage());
		}
	}
	
	private void showUpdateDialog(){
		AlertDialog.Builder alert = new AlertDialog.Builder(context);
		alert.setTitle("软件更新")
			.setMessage("发现新版本，是否现在更新？")
			.setPositiveButton("更新", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
					StatService.onEvent(context, "update", "ok");
					Intent updateIntent = new Intent(context, UpdateService.class);
					updateIntent.putExtra("file", apkFile);
					updateIntent.putExtra("url", URL + "download/" + apkFile);
					context.startService(updateIntent);
					context.next(true);
				}
			})
			.setNegativeButton("取消", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
					StatService.onEvent(context, "update", "cancel");
					context.next(false);
				}
			});
		alert.create().show();
	}
}