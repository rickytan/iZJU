package org.izju.post;

import java.util.Date;

import org.izju.R;

import android.animation.LayoutTransition;
import android.content.Context;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ViewFlipper;

public class PostEntryAdapter extends ArrayListAdapter<Post> {

	private static final String TAG = "PostEntryAdapter";
	private LayoutInflater inflater;
	private Context mContext;
	private int hotPostPos, latestPostPos;

	public PostEntryAdapter(Context context) {
		super();
		mContext = context;
		inflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}
	
	public void setHotPostPosition(int pos) {
		this.hotPostPos = pos;
	}
	
	public void setLatestPosition(int pos) {
		this.latestPostPos = pos;
	}
	
	public int getLatestPostPosition() {
		return this.latestPostPos;
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;
		if (convertView == null) {
			convertView = inflater.inflate(R.layout.post_entry, null);

			holder = new ViewHolder();
			holder.postType
						= (ImageView) convertView.findViewById(R.id.imgv_post_type);
			holder.poster
						= (TextView) convertView.findViewById(R.id.poster);
			holder.postTime
						= (TextView) convertView.findViewById(R.id.post_time);
			holder.upCount
						= (ViewFlipper) convertView.findViewById(R.id.flipper_up_count);
			holder.postContent 
						= (TextView) convertView.findViewById(R.id.post_content);
			holder.refPoster 
						= (TextView) convertView.findViewById(R.id.ref_poster);
			holder.refPostUpCount
						= (TextView) convertView.findViewById(R.id.ref_post_time);
			holder.refPostContent
						= (TextView) convertView.findViewById(R.id.ref_post_content);
			holder.postOperationLayout 
						= (LinearLayout) convertView.findViewById(R.id.layout_post_operation);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		
		holder.postType.setVisibility(View.GONE);
		if (hotPostPos == position) {
			holder.postType.setVisibility(View.VISIBLE);
			holder.postType.setImageResource(R.drawable.bg_hot_post);
//			holder.postType.setText(R.string.hot_post);
//			Typeface font = Typeface.createFromAsset(mContext.getAssets(), 
//					"fonts/post.ttf");
//			holder.postType.setTypeface(font);
		} else if (latestPostPos == position) {
			holder.postType.setVisibility(View.VISIBLE);
			holder.postType.setImageResource(R.drawable.bg_latest_post);
//			holder.postType.setText(R.string.latest_post);
//			Typeface font = Typeface.createFromAsset(mContext.getAssets(), 
//					"fonts/post.ttf");
//			holder.postType.setTypeface(font);
		}

		Post post = mList.get(position);
		holder.poster.setText(post.getPoster().getName() + "：");
		((TextView)holder.upCount.getChildAt(0)).setText("" + post.getUpCount());
//		holder.upCount.setText("" + post.getUpCount());
		holder.postTime.setText(TimeDescription(post.getPostTime()));
		holder.postContent.setText(post.getPostContent());
		holder.postOperationLayout.setVisibility(View.GONE);

		Post refPost = post.getReference();
		if (null != refPost) {
			((ViewGroup)holder.refPostContent.getParent().getParent()).setVisibility(View.VISIBLE);
			holder.refPoster.setText(refPost.getPoster().getName());
			holder.refPostContent.setText(refPost.getPostContent());
		} else {
			((ViewGroup)holder.refPostContent.getParent().getParent()).setVisibility(View.GONE);
		}

		return convertView;
	}

	static class ViewHolder {
		ImageView postType;
		TextView poster;
		TextView postTime;
//		TextView upCount;
		ViewFlipper upCount;
		TextView postContent;
		TextView refPoster;
		TextView refPostUpCount;
		TextView refPostContent;
		
		LinearLayout postOperationLayout;
	}
	
	private String TimeDescription(Date date) {
		long interval = new Date().getTime() - date.getTime();
		interval /= 1000; // seconds
		
		
		/*
		 * transform {interval} seconds to the form "MM months DD days 
		 * HH hours mm minutes and ss seconds"
		 */
		long s = interval % 60;
		interval /= 60;
		
		long min = interval % 60;
		interval /= 60;
		
		long hour = interval % 24;
		interval /= 24;
		
		long day = interval % 30;
		long month = interval / 30;
		
		if (month > 0) {
			return mContext.getString(R.string.long_time_ago);
		} 
		
		if (day > 0){
			return "" + day + mContext.getString(R.string.day_ago);
		}
		
		if (hour > 0) {
			return "" + hour + mContext.getString(R.string.hour_ago);
		}
		
		if (min > 0) {
			return "" + min + mContext.getString(R.string.minute_ago);
		}
		
		if (s > 20) {
			return "" + s + mContext.getString(R.string.second_ago);
		}
		
		return mContext.getString(R.string.just_now);
	}
}
