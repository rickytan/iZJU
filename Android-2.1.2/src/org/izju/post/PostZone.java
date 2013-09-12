package org.izju.post;

import java.util.Date;

import org.izju.R;
import org.izju.parse.ParseUtil;
import org.izju.parse.SaveCallback;
import org.izju.user.User;

import com.parse.ParseObject;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

public class PostZone extends LinearLayout {
	private static final String TAG = "PostZone";

	private Context mContext;

	private EditText postContentEdt;
	private Button sendPostBtn;

	private String id;
	
    /**
     * Only used when user click some post to reply. Otherwise, it is null.
     */
	private Post referencePost;
	
	private SaveCallback saveCallback;

	/**
	 * the messages handled by handler
	 */
	private final static int MSG_SEND_POST_SUCCESS = 1;
	private final static int MSG_SEND_POST_FAIL = 2;

	Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case MSG_SEND_POST_SUCCESS:
				Toast.makeText(mContext, R.string.post_success,
						Toast.LENGTH_SHORT).show();
				enablePost();
				break;
			case MSG_SEND_POST_FAIL:
				Toast.makeText(mContext, R.string.network_error,
						Toast.LENGTH_SHORT).show();
				enablePost();
				break;
			}
		}
	};

	public PostZone(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
	}	
	
	@Override
	protected void onFinishInflate() {
		Log.d(TAG, "post zone children number: " + getChildCount());
		postContentEdt = (EditText) getChildAt(0);
		postContentEdt.setOnFocusChangeListener(new FocusChangeListener());
		sendPostBtn = (Button) getChildAt(1);
		sendPostBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				if (checkPostContent()) {
					view.setEnabled(false);
					((Button) view).setText(R.string.sending_post);

					sendPost();
				}
			}

		});
		
		super.onFinishInflate();
	}
	
	public void setArticleId(String id) {
		this.id = id;
	}
	
	public void setReferencePost(Post refPost) {
		this.referencePost = refPost;
	}
	
	public void setSaveCallback(SaveCallback saveCallback) {
		this.saveCallback = saveCallback;
	}
	
	public void requestEditFocus() {
		postContentEdt.requestFocus();
		
 		InputMethodManager imm = (InputMethodManager) mContext.getSystemService(
 				Context.INPUT_METHOD_SERVICE);
 		imm.showSoftInput(postContentEdt,InputMethodManager.SHOW_FORCED);
	}

	private void enablePost() {
		postContentEdt.setText("");
		postContentEdt.setEnabled(true);
		sendPostBtn.setText(R.string.send_post);
		sendPostBtn.setEnabled(true);
	}

	private boolean checkPostContent() {
		String postContent = postContentEdt.getText().toString().trim();
		if (postContent.length() < 1) {
			Toast.makeText(mContext, R.string.error_post_length,
					       Toast.LENGTH_SHORT).show();
			return false;
		}
		return true;
	}

	private void sendPost() {
		String postContent = postContentEdt.getText().toString().trim();
		postContentEdt.setEnabled(false);
		postContentEdt.clearFocus();

		final Post post = new Post();
		post.setArticleId(id);
		post.setPostContent(postContent);
		post.setPoster(User.getCurrentUser(mContext));
		post.setPostTime(new Date());
		if (null != referencePost) {
			post.setReference(referencePost);
		}
		final ParseObject parseObject = ParseUtil.obtainParseObject(post,
				mContext.getString(R.string.ref_description));

		new Thread(new Runnable() {

			@Override
			public void run() {
				Exception exception = null;
				try {
					parseObject.save();
					handler.sendEmptyMessage(MSG_SEND_POST_SUCCESS);
				} catch (Exception e) {
					Log.d(TAG, "save exception");
					handler.sendEmptyMessage(MSG_SEND_POST_FAIL);
					exception = e;
				}
				if (null != saveCallback)
					saveCallback.done(exception, post);
			}

		}).start();
		
		referencePost = null;
	}
	
	private class FocusChangeListener implements OnFocusChangeListener {

		@Override
		public void onFocusChange(View arg0, boolean hasFocus) {
			if (hasFocus) {
				Log.d(TAG, "huodong gain focus");
				postContentEdt
					.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
				postContentEdt.setBackgroundResource(R.drawable.bg_hl_post_content);
			} else {
				Log.d(TAG, "huodong lost focus");
				postContentEdt.setCompoundDrawablesWithIntrinsicBounds(
						R.drawable.icon_write_post, 0, 0, 0);
				postContentEdt.setBackgroundResource(R.drawable.bg_post_edt);
				
				// hide soft keyboard
				InputMethodManager imm = (InputMethodManager) 
						mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(
						postContentEdt.getWindowToken(), 0);
			}
			
		}
	}
}
