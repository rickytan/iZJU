package org.izju.activity;

import org.izju.R;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class BaikeDetailActivity extends StatActivity {
	private final String TAG = "org.izju.activity.BaikeDetailActivity";
	
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

	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
        setContentView(R.layout.baike_detail);
        
        //get data
        String title = getIntent().getStringExtra("title");
        String detail = getIntent().getStringExtra("detail");
        
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
        titleText.setText(R.string.baike);
        
        TextView baikeTitleText = (TextView) findViewById(R.id.baike_detail_title);
        TextView baikedetailText = (TextView) findViewById(R.id.baike_detail_detail);
        baikedetailText.setMovementMethod(ScrollingMovementMethod.getInstance());
        
        baikeTitleText.setText(title);
        baikedetailText.setText(detail);
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
	
	private void back(){
		super.onBackPressed();
	}
}
