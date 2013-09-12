package org.izju.activity;

import java.util.ArrayList;

import org.izju.R;
import org.izju.activity.MainActivity.MyPagerAdapter;
import org.izju.common.Constants;

import cn.jpush.android.api.JPushInterface;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

public class NewerGuideActivity extends Activity {
	
	private ViewPager mViewPager;
	private ArrayList<View> mPageViews;
	
	private ViewGroup firstPage;
	private ViewGroup secondPage;
	
	private ImageView mImageView;
	private ImageView[] mImageViews;
	
	private LinearLayout indicatorViewGroup;
	
	private LayoutInflater mInflater;
	
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
		setContentView(R.layout.newer_guide);
		
        loadResources();
        registerListeners();
	}
	
	private void registerListeners() {		
        OnPageChangeListener l = new PageChangeListener();
        mViewPager.setOnPageChangeListener(l);
	}

	private void loadResources() {
        mInflater = getLayoutInflater();
        
        firstPage = (ViewGroup) mInflater.inflate(
        		R.layout.newer_guide_first_page, null);
        secondPage = (ViewGroup) mInflater.inflate(
        		R.layout.newer_guide_second_page, null);
        
        mPageViews = new ArrayList<View>();
        mPageViews.add(firstPage);
        mPageViews.add(secondPage);
        
        mViewPager = (ViewPager) findViewById(R.id.viewPager_newer_guide);
        mViewPager.setAdapter(new NewerGuidePagerAdapter());     
        
        indicatorViewGroup = (LinearLayout) findViewById(R.id.mybottomviewgroup);
        mImageViews = new ImageView[mPageViews.size()];
        for (int i = 0; i < mImageViews.length; i++) {
        	mImageView = new ImageView(NewerGuideActivity.this);  
        	mImageView.setLayoutParams(new LayoutParams(20,20));  
        	mImageView.setPadding(20, 0, 20, 0);  
        	
        	if (i == 0) {
        		mImageView.setBackgroundResource(R.drawable.newer_guide_indicator_focused);				
			} else {
				mImageView.setBackgroundResource(R.drawable.newer_guide_indicator);
			}
			
        	mImageViews[i] = mImageView;
        	
        	indicatorViewGroup.addView(mImageViews[i]);
		}
	}
	
    class NewerGuidePagerAdapter extends PagerAdapter {

    	@Override  
        public int getCount() {  
            return mPageViews.size();  
        }  
  
        @Override  
        public boolean isViewFromObject(View arg0, Object arg1) {  
            return arg0 == arg1;  
        }  
  
        @Override  
        public int getItemPosition(Object object) {  
            return super.getItemPosition(object);  
        }  
  
        @Override  
        public void destroyItem(View arg0, int arg1, Object arg2) {  
            ((ViewPager) arg0).removeView(mPageViews.get(arg1));  
        }  
  
        @Override  
        public Object instantiateItem(View arg0, int arg1) {
            ((ViewPager) arg0).addView(mPageViews.get(arg1));  
            return mPageViews.get(arg1);  
        }  
  
        @Override  
        public void restoreState(Parcelable arg0, ClassLoader arg1) { 

        }  
  
        @Override  
        public Parcelable saveState() {  
            return null;  
        }  
  
        @Override  
        public void startUpdate(View arg0) {  

        }  
  
        @Override  
        public void finishUpdate(View arg0) {
        	
        } 
    	
    }
    
    private class PageChangeListener implements OnPageChangeListener {
		@Override
		public void onPageSelected(int arg0) {
			for (int i = 0; i < mImageViews.length; i++) {
				if(i == arg0) {
					mImageViews[i].setBackgroundResource(
							R.drawable.newer_guide_indicator_focused);
				} else {
					mImageViews[i].setBackgroundResource(
							R.drawable.newer_guide_indicator);
				}
			}
			
			if (1 == arg0) {
				Toast.makeText(NewerGuideActivity.this, R.string.guide, Toast.LENGTH_LONG).show();
			}
		}
		
		@Override
		public void onPageScrolled(int arg0, float arg1, int arg2) {
			
		}
		
		@Override
		public void onPageScrollStateChanged(int arg0) {
			
		}
    }

	@Override
	public void onBackPressed() {
		Editor editor = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE).edit();
		editor.putBoolean(Constants.PREF_KEY_FIRST_USE, false);
		editor.commit();
		super.onBackPressed();
	}
    
    
}
