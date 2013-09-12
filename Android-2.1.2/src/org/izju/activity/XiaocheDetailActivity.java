package org.izju.activity;

import org.izju.R;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class XiaocheDetailActivity extends StatActivity {
	private final String TAG = "org.izju.activity.XiaocheDetailActivity";
	
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
        setContentView(R.layout.xiaoche_detail);
        
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
        titleText.setText(R.string.xiaoche);
        
        try {
			JSONObject data = new JSONObject(getIntent().getStringExtra("data"));
			((TextView) findViewById(R.id.xiaoche_detail_from)).setText(data.getString("from"));
			((TextView) findViewById(R.id.xiaoche_detail_to)).setText(data.getString("to"));
			((TextView) findViewById(R.id.xiaoche_detail_type)).setText(data.getString("type"));
			((TextView) findViewById(R.id.xiaoche_detail_time)).setText(data.getString("start"));
			((TextView) findViewById(R.id.xiaoche_detail_duration)).setText(data.getString("duration"));
			((TextView) findViewById(R.id.xiaoche_detail_place)).setText(data.getString("place"));
			((TextView) findViewById(R.id.xiaoche_detail_remark)).setText(data.getString("remark"));
			
		} catch (JSONException e) {
			Log.e(TAG, e.getLocalizedMessage());
			Log.e(TAG, e.getMessage());
		}
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event){
		if(keyCode == KeyEvent.KEYCODE_BACK){
			Log.d(TAG, "back");
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
