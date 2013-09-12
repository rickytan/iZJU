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

public class DianhuaActivity extends StatActivity {
	private final String TAG = "org.izju.activity.DianhuaActivity";
	private ListView listView;
	
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
        setContentView(R.layout.dianhua);
        
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
        titleText.setText(R.string.dianhua);
        
        listView = (ListView) findViewById(R.id.listView_dianhua);
        
        final List<HashMap<String, String>> data = getDianhuaList();
        
        SimpleAdapter adapter = new SimpleAdapter(this, data, R.layout.dianhua_item, 
        		new String[]{"name", "number"}, 
        		new int[]{R.id.dianhua_name_txt, R.id.dianhua_number_txt});
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int pos,
					long arg3) {
				Intent intent = new Intent(Intent.ACTION_DIAL, 
						Uri.parse("tel:"+data.get(pos).get("number")));
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
	
	private List<HashMap<String, String>> getDianhuaList(){
		List<HashMap<String, String>> data = new ArrayList<HashMap<String, String>>();
		JSONArray jsonData = DataUtility.getArrData(this, "dianhua");
		try {
			int len = jsonData.length();
			for(int i=0; i<len; i++){
				JSONObject jsonItem = jsonData.getJSONObject(i);
				HashMap<String, String> item = new HashMap<String, String>();
				item.put("name", jsonItem.getString("name"));
				item.put("number", jsonItem.getString("number"));
				data.add(item);
			}
		} catch (JSONException e) {
			Log.d(TAG, "json data parse error!");
			Log.e(TAG, e.getMessage());
		}
		return data;
	}
	
	private void back(){
		super.onBackPressed();
	}
	
}
