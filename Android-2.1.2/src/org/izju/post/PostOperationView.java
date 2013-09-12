package org.izju.post;


import org.izju.R;
import org.izju.common.Constants;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Message;
import android.text.ClipboardManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

/**
 * @author azure
 *
 */
public class PostOperationView extends View {

	private static final String TAG = "PostOperationView";
	private static final int OPERATION_UP_POST = 0;
	private static final int OPERATION_COPY_CONTENT = 1;
	private static final int OPERATION_REPLY = 2;
	
	private Context 		mContext;
	
	private Paint 			mPaint;
	private FontMetricsInt 	mFmi;
	
	/**
	 * Used to send message to {@link PostActivity}
	 */
	private Handler 		handler;
	
    /**
     * The Drawable used to display as separators between operations.
     */
    private Drawable mSeparatorDrawable;
	
	private Post post;
	
	private String upCountText;
	private String copyText;
	private String replyText;
	
	private boolean alreadyUp;
	
	public PostOperationView(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		mContext = context;
		mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setTextSize(Constants.OPERATION_VIEW_TEXT_SIZE);
        mFmi = mPaint.getFontMetricsInt();
        
        Resources r = context.getResources();
        mSeparatorDrawable = r.getDrawable(R.drawable.operation_vertical_line);
        
    	copyText = mContext.getString(R.string.copy);
    	replyText = mContext.getString(R.string.reply);
    	
    	alreadyUp = false;
	}
	
	public void setPost(Post post) {
    	// up one new post
    	if (null == this.post || !this.post.getId().equals(post.getId()))
    		alreadyUp = false;
    	
		this.post = post;
    	upCountText = String.format(mContext.getString(R.string.up_post_format), 
    			post.getUpCount());
	}
	
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) 
    {   
    	int measuredWidth = getPaddingLeft() + getPaddingRight();
    	measuredWidth += mPaint.measureText(upCountText);
    	measuredWidth += mPaint.measureText(copyText);
    	measuredWidth += mPaint.measureText(replyText);
    	int measuredHeight = getPaddingTop() + getPaddingBottom();
    	measuredHeight += mFmi.bottom - mFmi.top;
        setMeasuredDimension(measuredWidth, measuredHeight);
    }
    
    @Override
    public boolean onTouchEvent(MotionEvent event) {
    	Log.d(TAG, "onTouchEvent");

        if (MotionEvent.ACTION_UP == event.getAction()) {
        	
            int x, y;
            x = (int) event.getX();
            y = (int) event.getY();
            
            int operation = getOperation(x, y);
        	switch (operation) {
        	case OPERATION_UP_POST:
        		updateUpCount();
        		invalidate();
        		break;
        	case OPERATION_COPY_CONTENT:
        		copyContent();
        		break;
        	case OPERATION_REPLY:
        		reply();
        		break;
        	}
        }
        return true;
    }
    
    public void setHandler(Handler handler) {
    	this.handler = handler;
    }
    
    private void reply() {
    	if (null != handler) {
    		Message msg = new Message();
    		msg.obj = post;
    		msg.what = 2;
    		handler.sendMessage(msg);
    	}		
	}

	private void copyContent() {
    	if (null != handler) {
    		ClipboardManager cmb = (ClipboardManager) mContext.getSystemService(
    				Context.CLIPBOARD_SERVICE);
    		cmb.setText(post.getPostContent());
    		handler.sendEmptyMessage(1);
    	}
	}

	private void updateUpCount() {
    	if (null != handler) {
    		if (alreadyUp) 
    			return;
    		alreadyUp = true;
    		post.setUpCount(post.getUpCount() + 1);
    		upCountText = String.format(mContext.getString(
    				R.string.up_post_format), post.getUpCount());
    		this.measure(0, 0);
    		Message msg = new Message();
    		msg.obj = post;
    		msg.what = 0;
    		handler.sendMessage(msg);
    	}
	}

	private int getOperation(int x, int y) {
    	int w1 = (int) (getPaddingLeft() + mPaint.measureText(upCountText) 
    			+ mSeparatorDrawable.getIntrinsicWidth());
    	int w2 = (int) (w1 + mPaint.measureText(copyText) 
    			+ mSeparatorDrawable.getIntrinsicWidth());
    	if (x <= w1)
    		return OPERATION_UP_POST;
    	if (x <= w2)
    		return OPERATION_COPY_CONTENT;
    	return OPERATION_REPLY;
    }
    
    private float drawVerticalSeparator(Canvas canvas, float xPos) {
        mSeparatorDrawable.setBounds((int) xPos, getPaddingTop(), (int) xPos
                + mSeparatorDrawable.getIntrinsicWidth(), getMeasuredHeight()
                - getPaddingBottom());
        mSeparatorDrawable.draw(canvas);
        return mSeparatorDrawable.getIntrinsicWidth();
    }

	@Override
	protected void onDraw(Canvas canvas) 
	{
		Log.d(TAG, "onDraw");
		
		int xPos = getPaddingLeft();
		int yPos = (int) (getPaddingTop() + mFmi.bottom / 1.5 - mFmi.top);
		
		canvas.drawText(upCountText, xPos, yPos + 1 , mPaint);
		xPos += mPaint.measureText(upCountText);
        xPos += drawVerticalSeparator(canvas, xPos);
        
		canvas.drawText(copyText, xPos, yPos + 1, mPaint);
		xPos += mPaint.measureText(copyText);
		xPos += drawVerticalSeparator(canvas, xPos);
		
		canvas.drawText(replyText, xPos, yPos + 1, mPaint);
	}
}
