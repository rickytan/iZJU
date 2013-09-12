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

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class JiaoliuDetailActivity extends StatActivity {
	private final String TAG = "org.izju.activity.JiaoliuDetailActivity";
	private final String URL = "http://www.izju.org/data/jiaoliu.php";
	private String id;
	private List<HashMap<String, Object>> data = new ArrayList<HashMap<String, Object>>();

	
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
        setContentView(R.layout.list_type_2);
        
        
        //get id
        id = getIntent().getStringExtra("id");
        Log.d(TAG, "id " + id);
        
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
        titleText.setText(R.string.jiaoliu);
        
        ListView listView = (ListView) findViewById(R.id.listView_list_2);
        //set content
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.jiaoliu_detail_list_item, 
        		new String[]{"key", "value"}, 
        		new int[]{R.id.jiaoliu_detail_key, R.id.jiaoliu_detail_value});
        
        listView.setAdapter(adapter);
        
        DataChangeHandler dataChangeHandler = new DataChangeHandler(){
            final List<HashMap<String, Object>> data = JiaoliuDetailActivity.this.data;
			@Override
			public void changeData(String strData) {
				if(strData == null){
				    //finish();
				    return;
				}
				data.clear();
				try{
				    JSONObject jsonData = new JSONObject(strData);
				    String title = jsonData.getString("title");
				    ((TextView)findViewById(R.id.list_type_2_title_txt)).setText(title);
				    JSONArray jsonDetail = jsonData.getJSONArray("detail");
					int len = jsonDetail.length();
					for(int i=0; i<len; i++){
						JSONObject jsonItem = jsonDetail.getJSONObject(i);
						HashMap<String, Object> item = new HashMap<String, Object>();
						item.put("key", jsonItem.getString("key"));
						item.put("value", jsonItem.getString("value"));
						data.add(item);
					}
				} catch (JSONException e){
					Log.d(TAG, "json data parse error!");
					Log.e(TAG, e.getMessage());
				}
			}
		};
		
		new UpdateListTask(this, adapter, dataChangeHandler).execute(URL + "?id=" + id);
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
