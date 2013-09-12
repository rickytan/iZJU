package org.izju.activity;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.common.RequestFocusListener;
import org.izju.db.DataBaseOpenHelper;
import org.izju.db.UpPostIdDao;
import org.izju.parse.ParseUtil;
import org.izju.parse.SaveCallback;
import org.izju.post.Post;
import org.izju.post.PostEntryAdapter;
import org.izju.post.PostZone;
import org.izju.post.UpPopUp;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ListView;
import android.widget.Toast;
import android.widget.ViewFlipper;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

public class PostActivity extends StatActivity {
	private final String TAG = "PostActivity";

	private String id;
	private List<Post> postList;
	
	private List<Post> preRequestResult;
	
	private List<Post> hotPostList;
	private List<Post> latestPostList;
	
	/**
	 * Used to avoid taking post up repeatly.
	 */
	private List<String> upPostList;
	
	private UpPostIdDao upPostIdDao;
	

//    private Post referencePost;
    
    /**
     * Used to locate the popup window
     */
    private int popupWindowLocation[] = new int[2];
    
	
//	private EditText postContentEdt;
	private ListView postListView;
//	private Button sendPostBtn;
	private Button bakBtn;
	private View footerView;
	private Button moreBtn;
	
    private PostEntryAdapter adapter;
    
    private View preVisibleOperationView;
    
    private Resources resources;
    
    private PostZone postZone;
    
	/**
	 * the messages handled by handler
	 */
    private static final int MESSAGE_TYPE_REFRESH_VIEW = 1;
	private static final int MESSAGE_TYPE_REFRESH_VIEW2 = 2;
	private static final int MSG_ONE_NEW_POST = 3;
	
	Handler handler = new Handler() {
		 public void handleMessage(Message msg) {
		 	switch (msg.what) {
		 	case MESSAGE_TYPE_REFRESH_VIEW:
		 		((TextView)msg.obj).setTextColor(msg.arg1);
		 		break;
		 	case MESSAGE_TYPE_REFRESH_VIEW2:
		 		((ImageView)msg.obj).setImageResource(msg.arg1);
		 		break;
		 	case MSG_ONE_NEW_POST:
				postList.add(msg.arg1, (Post) msg.obj);
				adapter.notifyDataSetChanged();
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
        setContentView(R.layout.post);
        
        loadResources();
        registerListener();
        
        init();
        
        // avoid the post content EditText being covered by the input method
        getWindow().setSoftInputMode(
        		WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        
        new SearchTask().execute();
	}
	
	private void init() {
		resources = this.getResources();
		id = getIntent().getStringExtra(Constants.EXTRA_NAME_ARTICLE_ID);
        
		postListView.addFooterView(footerView);
		adapter = new PostEntryAdapter(PostActivity.this);	
		
        upPostIdDao = new UpPostIdDao(this);
        upPostList = upPostIdDao.getScrollData(0, (int) upPostIdDao.getCount());
        
        postZone.setArticleId(id);
        postZone.setSaveCallback(new SaveCallback() {

			@Override
			public void done(Exception e, Post sentPost) {
				int pos = adapter.getLatestPostPosition();
				if (pos < 0)
					pos = 0;
				
				Message msg = new Message();
				msg.what = MSG_ONE_NEW_POST;
				msg.arg1 = pos;
				msg.obj = sentPost;
				handler.sendMessage(msg);
			}
        	
        });
	}
	
	private void loadResources() {
        bakBtn = (Button) findViewById(R.id.top_bak_btn);
        ((TextView) findViewById(R.id.top_title_txt)).setText(R.string.post);
        
        postListView = (ListView) findViewById(R.id.listView_latest_post);
		footerView = LayoutInflater.from(this).inflate(
				R.layout.post_footer, null);
		moreBtn = (Button) footerView.findViewById(R.id.btn_more);
		postZone = (PostZone) findViewById(R.id.include2);
	}
	
	private void registerListener() {
		OnClickListener l1 = new ClickListener();
		bakBtn.setOnClickListener(l1);
		moreBtn.setOnClickListener(l1);
        
        OnTouchListener l3 = new TouchListener();
        findViewById(R.id.listView_latest_post).setOnTouchListener(l3);
        
        // other widgets request focus to make post content TextEdit lost focus
        RequestFocusListener l4 = new RequestFocusListener();
        findViewById(R.id.include1).setOnTouchListener(l4);
	}


	private class SearchTask extends AsyncTask<Void, Integer, Void> {

		ProgressDialog progressDialog;

		@Override
		protected void onPreExecute() {
			String msg = PostActivity.this.getString(R.string.loading);
			progressDialog = ProgressDialog.show(PostActivity.this, null, msg, 
												 true, true);
			progressDialog.setCanceledOnTouchOutside(false);
			progressDialog.setOnCancelListener(new OnCancelListener() {

				@Override
				public void onCancel(DialogInterface dialog) {
					Toast.makeText(PostActivity.this, 
								   R.string.operation_canceled, 
								   Toast.LENGTH_LONG).show();
					back();
				}
			});
		}

		@Override
		protected Void doInBackground(Void... params) {
			Log.i(TAG, "Start to request data");
			
			Thread t1 = new Thread(new Runnable() {

				@Override
				public void run() {
					hotPostList = ParseUtil.requestHotPosts(id);
				}
				
			});
			t1.start();
			
			Thread t2 = new Thread(new Runnable() {

				@Override
				public void run() {
					latestPostList = ParseUtil.requestLatestPosts(id);
				}
				
			});
			t2.start();
			
			try {
				t1.join();
				t2.join();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			
			if (null == hotPostList && null == latestPostList) {
				adapter.setHotPostPosition(-1);
				adapter.setLatestPosition(-1);
				postList = null;
				return null;
			}
			
        	postList = new ArrayList<Post>();
        	if (null != hotPostList)
        		postList.addAll(hotPostList);
        	if (postList.size() > 0) {
        		adapter.setHotPostPosition(0);
        	} else { // there is no post whose up-count is greater than 0
        		adapter.setHotPostPosition(-1);
        	}
        	
        	preRequestResult = latestPostList;
        	if (null == postList) {
        		postList = new ArrayList<Post>();
        	}
        	adapter.setLatestPosition(postList.size());
        	if (null != preRequestResult)
        		postList.addAll(preRequestResult);

			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			if (null != postList && postList.size() > 0) {
				adapter.setList(postList);
				postListView.setAdapter(adapter);
				postListView.setOnItemClickListener(new ItemClickListener());
				moreBtn.setText(R.string.more_post);
				moreBtn.setEnabled(true);
			} else if (null == postList){
				Toast.makeText(PostActivity.this, R.string.network_error, 
							   Toast.LENGTH_LONG).show();
			} else {
				Toast.makeText(PostActivity.this, R.string.no_post, 
							   Toast.LENGTH_LONG).show();
				moreBtn.setText(R.string.no_post);
				moreBtn.setEnabled(false);
			}

			progressDialog.dismiss();
		}
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
	
	private class RequestMoreRescoucesTask extends
		AsyncTask<Object, Integer, Integer> {
	
		List<Post> addedPosts = null;
		
		@Override
		protected void onPreExecute() {
			moreBtn.setEnabled(false);
			moreBtn.setText(getResources().getString(
					R.string.loading_more_post));
		}
	
		@Override
		protected Integer doInBackground(Object... params) {
			Log.i(TAG, "Start to request data");
			if (null == preRequestResult || preRequestResult.size() < 1)
				return null;
			
		    ParseQuery query = new ParseQuery(Constants.PARSE_NAME_COMMENT);
		    query.whereEqualTo(Constants.PARSE_KEY_ARTICLE_ID, id);
		    query.orderByDescending("updatedAt");
		    query.whereLessThan(Constants.PARSE_KEY_UPDATED_AT, 
		    		preRequestResult.get(preRequestResult.size() - 1).getPostTime());
		    query.setLimit(10);
		    
		    List<ParseObject> parseObjectList;
			try {
				parseObjectList = query.find();
		        if (null != parseObjectList) {
		        	addedPosts = new ArrayList<Post>();
		        	for (ParseObject po : parseObjectList) {
		        		addedPosts.add(ParseUtil.parsePost(po));
		        	}
		        	
		        	if (addedPosts.size() > 0)
		        		checkOverLap(addedPosts);
		        	preRequestResult = addedPosts;
		        }
			} catch (ParseException e) {
				e.printStackTrace();
			}
		
			return null;
		}
	
		private void checkOverLap(List<Post> newPostList) {
			String objectId = newPostList.get(0).getId();
			int preListSize = preRequestResult.size();
			int i = preListSize - 1;
			for (; i >= 0; i--) {
				if (preRequestResult.get(i).getId().equals(objectId))
					break;
			}
			if (i < 0)
				return;
			while (i < preListSize) {
				newPostList.remove(0);
				i++;
			}
		}

		@Override
		protected void onPostExecute(Integer result) {
			if (addedPosts != null) {
				if (addedPosts.size() > 0) {
					postList.addAll(addedPosts);
					adapter.notifyDataSetChanged();
					moreBtn.setText(getResources().getString(
							R.string.more_post));
					moreBtn.setEnabled(true);
				} else {
					moreBtn.setText(getResources().getString(
							R.string.load_all_post));
				}
			}
		}
	}
	
	private class ClickListener implements OnClickListener {

		@Override
		public void onClick(final View v) {
			switch (v.getId()) {
			case R.id.top_bak_btn:
					back();
					break;
			case R.id.btn_more:
				new RequestMoreRescoucesTask().execute();
				break;
			}
		}
	}
	
	private class TouchListener implements OnTouchListener {
		
		@Override
		public boolean onTouch(View view, MotionEvent event) {
			view.requestFocus();
			if (MotionEvent.ACTION_DOWN == event.getAction()) {
	            	int loc[] = new int[2];
	            	postListView.getLocationInWindow(loc);
	            	popupWindowLocation[0] = (int) event.getX() + loc[0];
	            	popupWindowLocation[1] = (int) event.getY() + loc[1];
			}
			return false;
		}
	}
	
	private class ItemClickListener 
				implements AdapterView.OnItemClickListener, OnClickListener {
		
		private Post post;
		private View clickedItemView;
		
		@Override
		public void onItemClick(AdapterView<?> parent, final View itemView, 
							    int position, long id) {
			if (null != preVisibleOperationView && 
					preVisibleOperationView != itemView) {
				preVisibleOperationView.setVisibility(View.GONE);
				preVisibleOperationView = null;
				return;
			}
			
			clickedItemView = itemView;
			preVisibleOperationView = itemView.findViewById(
										R.id.layout_post_operation);
			preVisibleOperationView.setVisibility(View.VISIBLE);
			setReferencePost(postList.get(position));
			
			itemView.findViewById(R.id.tv_up_post).setOnClickListener(this);
			itemView.findViewById(R.id.imgv_up_post).setOnClickListener(this);
			itemView.findViewById(R.id.tv_reply_post).setOnClickListener(this);
			itemView.findViewById(R.id.imgv_reply_post).setOnClickListener(this);
		}

		@Override
		public void onClick(View v) {
			switch(v.getId()) {
			case R.id.tv_up_post:
			case R.id.imgv_up_post:
				if (checkRepeatUp(post.getId())) {
					ParseUtil.updateUpCount(post);
					highlightUpPost(clickedItemView, post);
					persistUpPost(post.getId());
				} else {
					Toast.makeText(PostActivity.this, R.string.already_up, Toast.LENGTH_SHORT).show();
				}
				break;
			case R.id.tv_reply_post:
			case R.id.imgv_reply_post:
				postZone.setReferencePost(post);
				postZone.requestEditFocus();
				break;
			}
		}
		
		private void persistUpPost(String postId) {
			upPostList.add(postId);
			upPostIdDao.save(postId);
		}

		private boolean checkRepeatUp(String postId) {
			if (upPostList.indexOf(postId) >= 0)
				return false;
			return true;
		}

		private void setReferencePost(Post post) {
			this.post = post;
		}
		
		private void highlightUpPost(View v, Post post) {
			post.setUpCount(post.getUpCount() + 1);
			new UpPopUp(PostActivity.this).show(v, v.getMeasuredWidth() / 2, 
											    popupWindowLocation[1]);
			
			int hlFontColor = resources.getColor(R.color.font_blue);
			ViewFlipper vflipper = (ViewFlipper) v.findViewById(R.id.flipper_up_count);
			int childCount = vflipper.getChildCount();
			int index = vflipper.getDisplayedChild();
			final TextView upCountTv = (TextView) vflipper.getChildAt(
					(index + 1) % childCount);
			upCountTv.setText("" + post.getUpCount());
			upCountTv.setTextColor(hlFontColor);
			vflipper.showNext();
			
			final ImageView upCountImgv = (ImageView) v.findViewById(R.id.imgv_up);
			upCountImgv.setImageResource(R.drawable.icon_hl_up_post);
			
			Timer timer = new Timer(false);
			timer.schedule(new TimerTask() {

				@Override
				public void run() {
					// restore the origin state
					int fontColor = resources.getColor(R.color.font_gray);
					Message msg1 = new Message();
					msg1.what = MESSAGE_TYPE_REFRESH_VIEW;
					msg1.obj = upCountTv;
					msg1.arg1 = fontColor;
					handler.sendMessage(msg1);
					
					Message msg2 = new Message();
					msg2.what = MESSAGE_TYPE_REFRESH_VIEW2;
					msg2.obj = upCountImgv;
					msg2.arg1 = R.drawable.icon_up_post;
					handler.sendMessage(msg2);
				}
				
			}, Constants.HIGH_LIGHT_TIME);
		}
	}
}
