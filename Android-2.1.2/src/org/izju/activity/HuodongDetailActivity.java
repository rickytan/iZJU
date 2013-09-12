package org.izju.activity;

import java.util.Timer;
import java.util.TimerTask;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.common.RequestFocusListener;
import org.izju.post.PostZone;
import org.izju.utility.DataChangeHandler;
import org.izju.utility.UpdateListTask;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;
import com.parse.ParseQuery;

public class HuodongDetailActivity extends StatActivity {
	
	/**
	 * the messages handled by handler
	 */
	private final static int MSG_UPDATE_POST_NUM = 1;
	
	private final String TAG = "HuodongDetailActivity";
	private final String URL = "http://www.izju.org/data/huodong.php";
	private String id;
	private int postNum;
	
	private Button bakBtn;
	private Button postCountBtn;
	private PostZone postZone;
	
	private DataChangeHandler dataChangeHandler;
	
	/**
	 * Used to refresh the upCount at fixed rate
	 */
	private Timer timer;
	private boolean enterBackground;
	
	Handler handler = new Handler() {
		 public void handleMessage(Message msg) {
		 	switch (msg.what) {
		 	case MSG_UPDATE_POST_NUM:
		 		String post = HuodongDetailActivity.this.getString(R.string.post);
		 		Log.d(TAG, "post num: " + msg.arg1);
		 		if (msg.arg1 >= 0) {
		 			postCountBtn.setText("" + msg.arg1 + post);
		 		}
		 		
		 		if (!enterBackground) {
		 			scheduleRefreshTask(false);
		 		}
		 		break;
		 	}
	    }
	};
	
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
        setContentView(R.layout.huodong_detail);
        
        loadResources();
        registerListener();
        
        init();
        
        // avoid the post content EditText being covered by the input method
        getWindow().setSoftInputMode(
        		WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        
        new UpdateListTask(this, null, dataChangeHandler)
        								.execute(URL + "?id=" + id, id);
	}
	
	public void onPause() {
		super.onPause();
		enterBackground = true;
	}
	
	public void onResume() {
		super.onResume();
		enterBackground = false;
		scheduleRefreshTask(true);
	}
	
	private void init() {
        dataChangeHandler = new DataChangeHandler() {

			@Override
			public void changeData(String strData) {
				if(strData == null){
		            back();
		            return;
		        }
				try {
		            JSONObject jsonData = new JSONObject(strData);
		            ((TextView) findViewById(R.id.huodong_detail_title)).setText(jsonData.getString("title"));
		            ((TextView)findViewById(R.id.huodong_detail_time)).setText(jsonData.getString("time"));
		            ((TextView)findViewById(R.id.huodong_detail_introduction)).setText(jsonData.getString("detail"));
		            ((TextView)findViewById(R.id.huodong_detail_zhuban)).setText(jsonData.getString("host"));
		            ((TextView)findViewById(R.id.huodong_detail_chengban)).setText(jsonData.getString("contractor"));
		            ((TextView)findViewById(R.id.huodong_detail_place)).setText(jsonData.getString("place"));
		        } catch (JSONException e){
		            Log.d(TAG, "json data parse error!");
		            Log.e(TAG, e.getMessage());
		        }
			}
		};
		
        //get id
        id = getIntent().getStringExtra("id");        
        
        String post = this.getString(R.string.post);
        postCountBtn.setText("…" + post);  
        
        // request the number of posts asynchronously
        timer = new Timer(true);
        scheduleRefreshTask(true);
        
        postZone.setArticleId(id);
	}

	private void loadResources() {
        ((TextView) findViewById(R.id.top_title_txt)).setText(R.string.huodong);
        
        bakBtn = (Button) findViewById(R.id.top_bak_btn);
        postCountBtn = (Button) findViewById(R.id.top_btn_2);
        postZone = (PostZone) findViewById(R.id.include2);
	}

	
	private void registerListener() {
		OnClickListener l1 = new ClickListener();
		bakBtn.setOnClickListener(l1);
		postCountBtn.setOnClickListener(l1);
        
        // other widgets request focus to make post content TextEdit lost focus
        RequestFocusListener l3 = new RequestFocusListener();
        findViewById(R.id.layout_huodong_content).setOnTouchListener(l3);
        findViewById(R.id.scrollView_activity_detail).setOnTouchListener(l3);
        findViewById(R.id.include1).setOnTouchListener(l3);
	}

	private void scheduleRefreshTask(boolean immediately) {
		if (null == timer)
			return;
		
		TimerTask refreshTask = new TimerTask() {
			public void run() {
				ParseQuery query = new ParseQuery(Constants.PARSE_NAME_COMMENT);
				query.whereEqualTo(Constants.PARSE_KEY_ARTICLE_ID, id);
				int count = -1;
				try {
					count = query.count();
				} catch (Exception e) {

				}

				Message message = new Message();
				message.what = MSG_UPDATE_POST_NUM;
				message.arg1 = count;
				postNum = count;
				handler.sendMessage(message);
			}
		};
    	
		Log.d(TAG, "schedule refresh task");
    	try {
    		long delay = Constants.REFRESH_INTERVAL;
    		if (immediately) {
    			delay = 0;
    		}
    		timer.schedule(refreshTask, delay);
    	} catch (IllegalStateException e) {
    		e.printStackTrace();
    		Log.d(TAG, "the timer has been canceled");
    	}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event){
		Log.d(TAG, "key down back");
		if(keyCode == KeyEvent.KEYCODE_BACK){
			back();
			return true;
		} else {
			return super.onKeyDown(keyCode, event);
		}
	}
	
	public void onBackPressed() {
		back();
	}
	
	private void back(){
		Log.d(TAG, "back");
		if (null != timer) {
			timer.cancel();
			timer = null;
		}
		super.onBackPressed();
	}
	
	private void switchToPost() {
		Intent intent = new Intent(HuodongDetailActivity.this, 
				   PostActivity.class);
		intent.putExtra(Constants.EXTRA_NAME_ARTICLE_ID, id);
		intent.putExtra(Constants.EXTRA_NAME_POST_NUM, postNum);
		HuodongDetailActivity.this.startActivity(intent);
	}
	
	private class ClickListener implements OnClickListener {

		@Override
		public void onClick(final View v) {
			switch (v.getId()) {
			case R.id.top_bak_btn:
					back();
					break;
			case R.id.top_btn_2:
				switchToPost();
				break;
			}
		}
	}
}
