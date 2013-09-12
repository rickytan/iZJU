package org.izju.activity;

import java.util.ArrayList;
import java.util.Collections;
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

public class BaikeActivity extends StatActivity {
    private final String TAG = "org.izju.activity.BaikeActivity";
    private final String path = "baike";
    
    List<HashMap<String, Object>> data;
    

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
        setContentView(R.layout.list_type_1);
        
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
        
        ListView listView = (ListView) findViewById(R.id.listView_list_1);
        //set content
        
        data = getData();
        Collections.shuffle(data);
        data = data.subList(0, 15);
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.list_type_2_item, 
        		new String[]{"title"}, 
        		new int[]{R.id.jiaoliu_title_txt});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
				Intent intent = new Intent(BaikeActivity.this, BaikeDetailActivity.class);
				intent.putExtra("title", (String)data.get(pos).get("title"));
				intent.putExtra("detail", (String)data.get(pos).get("detail"));
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
        try{
            int len = jsonData.length();
            for(int i=0; i<len; i++){
                JSONObject jsonItem = jsonData.getJSONObject(i);
                HashMap<String, Object> item = new HashMap<String, Object>();
                item.put("title", jsonItem.getString("title"));
                item.put("detail", jsonItem.getString("detail"));
                data.add(item);
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
