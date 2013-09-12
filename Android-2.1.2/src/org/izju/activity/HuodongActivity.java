package org.izju.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.izju.R;
import org.izju.utility.DataChangeHandler;
import org.izju.utility.UpdateListTask;
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

public class HuodongActivity extends StatActivity {
	private final String TAG = "org.izju.activity.JiangzuoActivity";
	private final String URL = "http://www.izju.org/data/huodong.php";

	List<HashMap<String, Object>> data = new ArrayList<HashMap<String, Object>>();
	
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
        titleText.setText(R.string.huodong);
        
        ListView listView = (ListView) findViewById(R.id.listView_list_1);
        //set content
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.huodong_list_item, 
        		new String[]{"date", "title", "place"}, 
        		new int[]{R.id.huodong_item_date, R.id.huodong_item_title, R.id.huodong_item_place});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
				Intent intent = new Intent(HuodongActivity.this, HuodongDetailActivity.class);
				intent.putExtra("id", (String)data.get(pos).get("id"));
				startActivity(intent);	
			}
        	
        });
        
        DataChangeHandler dataChangeHandler = new DataChangeHandler(){
            final List<HashMap<String, Object>> data = HuodongActivity.this.data;

			@Override
			public void changeData(String strData) {
				if(strData == null){
				    //finish();
				    return;
				}
				data.clear();
				try{
				    JSONArray jsonData = new JSONArray(strData);
					int len = jsonData.length();
					for(int i=0; i<len; i++){
						JSONObject jsonItem = jsonData.getJSONObject(i);
						HashMap<String, Object> item = new HashMap<String, Object>();
						item.put("id", jsonItem.getString("id"));
						item.put("date", jsonItem.getString("date"));
						item.put("title", jsonItem.getString("title"));
						item.put("place", jsonItem.getString("place"));
						data.add(item);
					}
				} catch (JSONException e){
					Log.d(TAG, "json data parse error!");
					Log.e(TAG, e.getMessage());
				}
			}};
			
			new UpdateListTask(this, adapter, dataChangeHandler).execute(URL);
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
