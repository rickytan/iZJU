package org.izju.push;

import org.izju.R;
import org.izju.common.Constants;

import cn.jpush.android.api.JPushInterface;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class NotificationDetailActivity extends Activity {

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
    protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        setContentView(R.layout.notification_detail);
        
        //initialize back button
        Button bakBtn = (Button) findViewById(R.id.top_bak_btn);
        bakBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				back();
			}
		});
        
        //initialize the view
        TextView titleText = (TextView) findViewById(R.id.top_title_txt);
        titleText.setText(R.string.notification);
        
		String title = getIntent().getStringExtra(
				Constants.EXTRA_NAME_NOTIFCATION_TITLE);
		String content = getIntent().getStringExtra(
				Constants.EXTRA_NAME_NOTIFCATION_CONTENT);
        
        TextView ntfTitleText = (TextView) findViewById(
        								R.id.notification_detail_title);
        ntfTitleText.setText(title);
        
        TextView contentText = (TextView) findViewById(R.id.textview_content);
        contentText.setText(content);
    }

	private void back(){
		super.onBackPressed();
	}
}
