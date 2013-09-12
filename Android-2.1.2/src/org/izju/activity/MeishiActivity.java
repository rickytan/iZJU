package org.izju.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.izju.R;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class MeishiActivity extends StatActivity {
	
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
        setContentView(R.layout.index_type_1);
        
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
        ImageView bgImg = (ImageView) findViewById(R.id.index_bg_img);
        titleText.setText(R.string.meishi);
        bgImg.setImageResource(R.drawable.bg_food);
        
        ListView listView = (ListView) findViewById(R.id.listview_index);
        
        //set content
        final List<HashMap<String, Object>> data = getData();
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.index_type_1_item, 
        		new String[]{"icon", "name"}, 
        		new int[]{R.id.zhusu_index_icon, R.id.zhusu_index_txt});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				Intent intent = null;
				switch(arg2){
				case 0:
					intent = new Intent(MeishiActivity.this, MeishiMeishiListActivity.class); break;
				case 1:
					intent = new Intent(MeishiActivity.this, MeishiWaimaiListActivity.class); break;
				}
				startActivity(intent);
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
	
	private List<HashMap<String, Object>> getData(){
		List<HashMap<String, Object>> data = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> item0 = new HashMap<String, Object>();
		item0.put("icon", R.drawable.icon_home);
		item0.put("name", "热门美食");
		data.add(item0);
		
		HashMap<String, Object> item1 = new HashMap<String, Object>();
		item1.put("icon", R.drawable.icon_rizu);
		item1.put("name", "热门外卖");
		data.add(item1);

		return data;
	}
	
	private void back(){
		super.onBackPressed();
	}
}
