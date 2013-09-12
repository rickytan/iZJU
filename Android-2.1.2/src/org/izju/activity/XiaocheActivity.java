package org.izju.activity;

import java.util.ArrayList;
import java.util.List;

import org.izju.R;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class XiaocheActivity extends StatActivity {
	private final String TAG = "org.izju.activity.XiaocheActivity";
	
	Spinner s1, s2;
	
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
        setContentView(R.layout.xiaoche_select);
        
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
        
        //initialize spinner.
        List<String> data = new ArrayList<String>();
        data.add("紫金港");
        data.add("玉泉");
        data.add("西溪");
        data.add("华家池");
        data.add("之江");
        
        s1 = (Spinner) findViewById(R.id.xiaoche_select_from);
        s2 = (Spinner) findViewById(R.id.xiaoche_select_to);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, data);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        s1.setAdapter(adapter);
        s2.setAdapter(adapter);
        s2.setSelection(1);
        
        ImageButton btnExchange = (ImageButton) findViewById(R.id.xiaoche_change_btn);
        btnExchange.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				int tmp = s1.getSelectedItemPosition();
				s1.setSelection(s2.getSelectedItemPosition());
				s2.setSelection(tmp);
			}
		});
        
        Button btnQuery = (Button) findViewById(R.id.xiaoche_select_query);
        btnQuery.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Log.d(TAG, (String)s1.getSelectedItem());
				Log.d(TAG, (String)s2.getSelectedItem());
				Intent intent = new Intent(XiaocheActivity.this, XiaocheListActivity.class);
				intent.putExtra("from", (String)s1.getSelectedItem());
				intent.putExtra("to", (String)s2.getSelectedItem());
				startActivity(intent);
			}
		});
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
