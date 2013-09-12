package org.izju.activity;

import java.util.Random;

import org.izju.R;
import org.izju.utility.DataUtility;
import org.izju.utility.UpdateManager;

import cn.jpush.android.api.JPushInterface;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.TextView;

public class SplashActivity extends Activity {
	private final String TAG = "org.izju.activity.SplashActivity";
	private final int DELAY_TIME = 1000;
	private long startTime = 0;
    

    @Override
    public void onStart() {
        super.onStart();
        JPushInterface.activityStarted(this);
    }
     
    @Override
    public void onStop() {
        super.onStop();
        JPushInterface.activityStopped(this);
    }
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.splash);
        
        //显示version在启动页上
		try {
			PackageManager pm = getPackageManager();
			PackageInfo pi = pm.getPackageInfo(getPackageName(), 0);
			if(pi.versionName != null){
				Log.d(TAG, "Version: " + pi.versionName);
				TextView version = (TextView)findViewById(R.id.splash_version_txt);
				version.setText("Version: " + pi.versionName);
			} else {
				Log.e(TAG, "Version not founded");
			}
		} catch (NameNotFoundException e) {
			Log.e(TAG, "getPackageInfo exception");
		}
        
		/*
		 * 判断是否第一次启动
		 * 如果是第一次启动，则复制数据文件
		 */
		/*
		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
		boolean firstTime = prefs.getBoolean("first_time", true);
		if(firstTime){
			Log.d(TAG, "first time");
			if(DataUtility.copyDataFile(this)){
				Editor pEdit = prefs.edit();
				pEdit.putBoolean("first_time", false);
				pEdit.commit();
			}
			delayTime = 2000;
		}
		*/
		startTime = System.currentTimeMillis();
//		if(new Random().nextInt(10) == 7){
            checkUpdate();
//        }
//        else {
//            next();
//        }
    }
    
    @Override
	public boolean onKeyDown(int keyCode, KeyEvent event){
		if(keyCode == KeyEvent.KEYCODE_BACK){
			finish();
			return true;
		} else {
			return super.onKeyDown(keyCode, event);
		}
	}
    
    public void next(){
        next(false);
    }
    
    public void next(final boolean doUpdate){
        long endTime = System.currentTimeMillis();
        int delayTime = 0;
        if((endTime - startTime) < DELAY_TIME){
            delayTime = DELAY_TIME - (int)(endTime - startTime);
        }
        delayTime += 200;
        new Handler().postDelayed(new Runnable(){
            @Override
            public void run() {
                Intent intent = new Intent(SplashActivity.this, MainActivity.class);
                intent.putExtra("doUpdate", doUpdate);
                startActivity(intent);
                finish();
            }
        }, delayTime);
    }
    
    private void checkUpdate(){
    	if(DataUtility.isNetworkAvailable(this)){
	    	UpdateManager um = new UpdateManager(this);
	    	um.doUpdate();
    	}
    	else {
    		next();
    	}
    }
    
}