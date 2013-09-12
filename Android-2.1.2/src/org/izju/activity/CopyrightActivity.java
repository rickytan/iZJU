package org.izju.activity;

import org.izju.R;
import org.izju.common.Constants;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class CopyrightActivity extends StatActivity {
    private final String TAG = "CopyrightActivity";
    
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
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.copyright);
        
        loadResources();
        registerListeners();
    }

    
    private void loadResources() {
        TextView titleText = (TextView) findViewById(R.id.top_title_txt);
        titleText.setText("");
        
		try {
			PackageManager pm = getPackageManager();
			PackageInfo pi = pm.getPackageInfo(getPackageName(), 0);
			if(pi.versionName != null){
				Log.d(TAG, "Version: " + pi.versionName);
				TextView version = (TextView)findViewById(
						R.id.textView_copyright_version);
				version.setText("Version " + pi.versionName);
			} else {
				Log.e(TAG, "Version not founded");
			}
		} catch (NameNotFoundException e) {
			Log.e(TAG, "getPackageInfo exception");
		}
    }
    
    private void registerListeners() {
    	OnClickListener l = new ClickListener();
    	findViewById(R.id.top_bak_btn).setOnClickListener(l);
    	findViewById(R.id.btn_download).setOnClickListener(l);
    	findViewById(R.id.btn_contact_us).setOnClickListener(l);
    }
    
    private void back(){
        super.onBackPressed();
    }
    
    
    private class ClickListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.top_bak_btn:
				back();
				break;
			case R.id.btn_download:
				Uri uri1 = Uri.parse(Constants.OFFICIAL_NET); 
				Intent intent1  = new Intent(Intent.ACTION_VIEW,uri1); 
				CopyrightActivity.this.startActivity(intent1);
				break;
			case R.id.btn_contact_us:
				Uri uri2 = Uri.parse(Constants.MAIL_TO_EMAIL); 
				Intent intent2 = new Intent(Intent.ACTION_SENDTO, uri2); 
				CopyrightActivity.this.startActivity(intent2);
				break;
			}
		}
    }
}
