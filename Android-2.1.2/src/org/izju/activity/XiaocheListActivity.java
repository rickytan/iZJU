package org.izju.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.izju.R;
import org.izju.utility.DataUtility;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class XiaocheListActivity extends StatActivity {
	private final String TAG = "org.izju.activity.XiaocheActivity";
	private String path = "xiaoche";
	
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
        setContentView(R.layout.xiaoche_list);
        
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
        
        ListView listView = (ListView) findViewById(R.id.xiaoche_list_listview);
        //set content
        final List<HashMap<String, Object>> data = getData();
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.xiaoche_list_item, 
        		new String[]{"time", "type", "remark"}, 
        		new int[]{R.id.xiaoche_list_time, R.id.xiaoche_list_type, R.id.xiaoche_list_remark});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
				Intent intent = new Intent(XiaocheListActivity.this, XiaocheDetailActivity.class);
				intent.putExtra("data", (String)data.get(pos).get("data"));
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
	
	private List<HashMap<String, Object>> getData(){
		List<HashMap<String, Object>> data = new ArrayList<HashMap<String, Object>>();
		JSONArray jsonData = DataUtility.getArrData(this, path);
		
		String from = getIntent().getStringExtra("from");
		String to = getIntent().getStringExtra("to");
		
		try{
			int len = jsonData.length();
			for(int i=0; i<len; i++){
				JSONObject jsonItem = jsonData.getJSONObject(i);
				if(jsonItem.getString("from").equals(from) && jsonItem.getString("to").equals(to)){
					HashMap<String, Object> item = new HashMap<String, Object>();
					item.put("time", jsonItem.getString("start"));
					item.put("type", jsonItem.getString("type"));
					item.put("remark", jsonItem.getString("remark"));
					item.put("data", jsonItem.toString());
					data.add(item);
				}
			}
		} catch (JSONException e){
			Log.d(TAG, "json data parse error!");
			Log.e(TAG, e.getMessage());
		}
		
		return data;
	}
	
	private void back(){
		super.onBackPressed();
	}
}
