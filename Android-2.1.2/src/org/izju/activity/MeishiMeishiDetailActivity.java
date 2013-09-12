package org.izju.activity;

import org.izju.R;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class MeishiMeishiDetailActivity extends StatActivity {
	private final String TAG = "org.izju.activity.MeishiMeishiDetailActivity";
	
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
        setContentView(R.layout.meishi_meishi_detail);
        
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
        
        try {
			JSONObject data = new JSONObject(getIntent().getStringExtra("data"));
			final String mobile = data.getString("mobile");
			titleText.setText(data.getString("shop"));
			((TextView) findViewById(R.id.meishi_meishi_detail_address)).setText(data.getString("address"));
			((TextView) findViewById(R.id.meishi_meishi_detail_mobile)).setText(data.getString("mobile"));
			((TextView) findViewById(R.id.meishi_meishi_detail_price)).setText(data.getString("price"));
			((TextView) findViewById(R.id.meishi_meishi_detail_recommond)).setText(data.getString("recommond"));
			((TextView) findViewById(R.id.meishi_meishi_detail_discount)).setText(data.getString("discount"));
			((TextView) findViewById(R.id.meishi_meishi_detail_scale)).setText(data.getString("scale"));
			((TextView) findViewById(R.id.meishi_meishi_detail_remark)).setText(data.getString("remark"));
			
			findViewById(R.id.meishi_meishi_detail_dail).setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent intent = new Intent(Intent.ACTION_DIAL, 
							Uri.parse("tel:"+ mobile));
					startActivity(intent);
				}
			});
			
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
