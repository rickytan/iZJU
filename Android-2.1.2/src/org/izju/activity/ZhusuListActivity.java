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
import android.net.Uri;
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

public class ZhusuListActivity extends StatActivity {
	private final String TAG = "org.izju.activity.ZhusuListActivity";
	private String path = null;

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
        
        //get path
        path = getIntent().getStringExtra("path");
        
        //init back button
        Button bakBtn = (Button) findViewById(R.id.top_bak_btn);
        bakBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				back();
			}
		});
        
        //init the view
        TextView titleText = (TextView) findViewById(R.id.top_title_txt);
        if(path.equals("zhusu"))
        	titleText.setText(R.string.zhusu);
        else if(path.equals("rizu"))
        	titleText.setText(R.string.rizu);
        
        ListView listView = (ListView) findViewById(R.id.listView_list_1);
        //set content
        final List<HashMap<String, Object>> data = getData();
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.zhusu_list_item, 
        		new String[]{"name", "contact", "price"}, 
        		new int[]{R.id.zhusu_name_txt, R.id.zhusu_contact_txt, R.id.zhusu_price_txt});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
			    Log.d(TAG, "on item click");
				Intent intent = new Intent(Intent.ACTION_DIAL, 
						Uri.parse("tel:"+data.get(pos).get("contact")));
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
		JSONArray jsonData = DataUtility.getArrData(this, "zhusu/"+path);
		try{
			int len = jsonData.length();
			for(int i=0; i<len; i++){
				JSONObject jsonItem = jsonData.getJSONObject(i);
				HashMap<String, Object> item = new HashMap<String, Object>();
				item.put("name", jsonItem.getString("name"));
				item.put("contact", jsonItem.getString("contact"));
				item.put("price", jsonItem.getString("price"));
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
