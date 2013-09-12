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
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.TabHost.OnTabChangeListener;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class MeishiWaimaiListActivity extends StatActivity {
	private final String TAG = "org.izju.activity.MeishiWaimaiListActivity";
	private final String path = "meishi/waimai";

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
        setContentView(R.layout.list_type_3);
        
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
        titleText.setText(R.string.remenwaimai);
        
        final ListView listView = (ListView) findViewById(R.id.listView_tab_1);
        //set content
        getData("zjg");
        
        final SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.meishi_waimai_item, 
        		new String[]{"shop", "mobile", "condition"}, 
        		new int[]{R.id.meishi_waimai_shop, R.id.meishi_waimai_mobile, 
        		R.id.meishi_waimai_condition});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
				Intent intent = new Intent(MeishiWaimaiListActivity.this, MeishiWaimaiDetailActivity.class);
				intent.putExtra("shop", (String)data.get(pos).get("shop"));
				intent.putExtra("dish", (String)data.get(pos).get("dish"));
				intent.putExtra("mobile", (String)data.get(pos).get("mobile"));
				startActivity(intent);	
			}
        	
        });
        
        
        TabHost tabHost = (TabHost) findViewById(R.id.list_type_3_tabhost);
        tabHost.setup();
        tabHost.addTab(tabHost.newTabSpec("zjg").setIndicator(newTextView("紫金港校区")).setContent(R.id.listView_tab_1));
        tabHost.addTab(tabHost.newTabSpec("yq").setIndicator(newTextView("玉泉校区")).setContent(R.id.listView_tab_1));
        tabHost.setCurrentTab(1);
        tabHost.setCurrentTab(0);
        //adapter.notifyDataSetChanged();
        tabHost.setOnTabChangedListener(new OnTabChangeListener() {
            
            @Override
            public void onTabChanged(String tabId) {
                getData(tabId);
                adapter.notifyDataSetChanged();
                
                Animation animation = new AlphaAnimation(0,1);
                animation.setDuration(500);
                listView.startAnimation(animation);
            }
        });
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
	
	private void getData(String campus){
	    data.clear();
		JSONArray jsonData = DataUtility.getArrData(this, path+"/"+campus);
		try{
			int len = jsonData.length();
			for(int i=0; i<len; i++){
				JSONObject jsonItem = jsonData.getJSONObject(i);
				HashMap<String, Object> item = new HashMap<String, Object>();
				item.put("shop", jsonItem.getString("shop"));
				item.put("mobile", jsonItem.getString("mobile"));
				item.put("condition", jsonItem.getString("condition"));
				item.put("dish", jsonItem.getJSONArray("dish").toString());
				data.add(item);
			}
		} catch (JSONException e){
			Log.d(TAG, "json data parse error!");
			Log.e(TAG, e.getMessage());
		}
	}
	
	private TextView newTextView(String text){
        TextView view = new TextView(this);
        view.setText(text);
        view.setGravity(Gravity.CENTER);
        view.setPadding(0, 10, 0, 10);
        view.setBackgroundResource(R.drawable.bg_tab);
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        return view;
    }
	
	private void back(){
		super.onBackPressed();
	}
}
