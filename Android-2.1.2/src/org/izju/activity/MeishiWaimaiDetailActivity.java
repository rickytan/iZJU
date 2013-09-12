package org.izju.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.izju.R;
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
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class MeishiWaimaiDetailActivity extends StatActivity {
	private final String TAG = "org.izju.activity.MeishiWaimaiDetailActivity";
	
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
        setContentView(R.layout.list_type_4);
        
        String shop = getIntent().getStringExtra("shop");
        String dish = getIntent().getStringExtra("dish");
        final String mobile = getIntent().getStringExtra("mobile");
        
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
		titleText.setText(R.string.remenwaimai);
		
		TextView txtShop = (TextView) findViewById(R.id.list_type_4_title_txt);
		txtShop.setText(shop);
		
		ImageView imgYuding = (ImageView) findViewById(R.id.list_type_4_btn);
		imgYuding.setOnClickListener(new OnClickListener() {
            
            @Override
            public void onClick(View arg0) {
                Intent intent = new Intent(Intent.ACTION_DIAL, 
                        Uri.parse("tel:"+ mobile));
                startActivity(intent);
            }
        });
		
		ListView listView = (ListView) findViewById(R.id.listView_list_4);
        //set content
        final List<HashMap<String, Object>> data = getData(dish);
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.meishi_waimai_detail_item, 
        		new String[]{"name", "price"}, 
        		new int[]{R.id.meishi_waimai_detail_name, R.id.meishi_waimai_detail_price});
        
        listView.setAdapter(adapter);
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
	
	private List<HashMap<String, Object>> getData(String dish){
		List<HashMap<String, Object>> data = new ArrayList<HashMap<String, Object>>();
		
		try{
		    JSONArray jsonData = new JSONArray(dish);
			int len = jsonData.length();
			for(int i=0; i<len; i++){
				JSONObject jsonItem = jsonData.getJSONObject(i);
				HashMap<String, Object> item = new HashMap<String, Object>();
				item.put("name", jsonItem.getString("name"));
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
