package org.izju.activity;

import java.lang.reflect.Field;
import java.util.ArrayList;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.setting.SettingsActivity;

import com.baidu.mobstat.StatActivity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends StatActivity {
	
	private static final String TAG = "MainActivity";
	
	private ViewPager mViewPager;
	private ArrayList<View> mPageViews;
	private ImageView mImageView;
	private ImageView[] mImageViews;
	
	private LinearLayout indicatorViewGroup;
	
	private GridView firstPage;
	private GridView secondPage;
	
	private ViewGroup contentView;
	
//    @Override
//    public void onStart() {
//        super.onStart();
//        JPushInterface.activityStarted(this);
//    }
//     
//    @Override
//    public void onStop() {
//        super.onStop();
//        JPushInterface.activityStopped(this);
//    }
	
	
	@Override
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		
		contentView = (ViewGroup) getLayoutInflater().inflate(R.layout.main, null);
//		contentView.setBackgroundDrawable(createMainBackground());
		this.setContentView(contentView);
        
        if(getIntent().getBooleanExtra("doUpdate", false)){
            Toast.makeText(this, "iZJU已经在更新中...", Toast.LENGTH_SHORT).show();
        }
        
        loadResources();
        registerListeners();
        
        if (CheckFirstUse()) {
        	startActivity(new Intent(MainActivity.this, NewerGuideActivity.class));
        }
	}
	
	private boolean CheckFirstUse() {
		SharedPreferences pref = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		int installedVersion = pref.getInt(Constants.PREF_KEY_VERSION_CODE, 0);
		try {
			PackageManager pm = getPackageManager();
			PackageInfo pi = pm.getPackageInfo(getPackageName(), 0);
			if (pi.versionCode > installedVersion) {
				Editor editor = pref.edit();
				editor.putBoolean(Constants.PREF_KEY_FIRST_USE, false);
				editor.putInt(Constants.PREF_KEY_VERSION_CODE, pi.versionCode);
				editor.commit();
				return true;
			}
		} catch (NameNotFoundException e) {
			Log.e(TAG, "getPackageInfo exception");
		}
		
		return pref.getBoolean(Constants.PREF_KEY_FIRST_USE, true);
	}
	
	private void registerListeners() {		
		OnItemClickListener l1 = new ItemClickListener();
        firstPage.setOnItemClickListener(l1);
        secondPage.setOnItemClickListener(l1);
		
        OnPageChangeListener l2 = new PageChangeListener();
        mViewPager.setOnPageChangeListener(l2);
        
        OnClickListener l3 = new ClickListener();
        contentView.findViewById(R.id.btn_copyright).setOnClickListener(l3);
	}

	private void loadResources() {		
		setupViewPager();
		setupIndicatorView();
	}
	
	private void setupViewPager() {
        MainPageItem[] items1 = new MainPageItem[] {
        	new MainPageItem(R.drawable.icon_huodong, 
        					 R.string.huodong, HuodongActivity.class),
        	new MainPageItem(R.drawable.icon_jiaoliu,
        					 R.string.jiaoliu, JiaoliuActivity.class),
        	new MainPageItem(R.drawable.icon_jiuye,
        					 R.string.jiuye, JiuyeActivity.class),
        	new MainPageItem(R.drawable.icon_baike,
        			 		 R.string.baike, BaikeActivity.class),
        	new MainPageItem(R.drawable.icon_meishi,
        					 R.string.meishi, MeishiActivity.class),
        	new MainPageItem(R.drawable.icon_zhusu,
        					 R.string.zhusu, ZhusuActivity.class),
        	new MainPageItem(R.drawable.icon_xiaoche,
        					 R.string.xiaoche, XiaocheActivity.class),
        	new MainPageItem(R.drawable.icon_mobile_lib,
        					 R.string.mobile_lib, ZjuMobileLibActivity.class),
        	new MainPageItem(R.drawable.icon_yijian,
        					 R.string.yijian, YijianActivity.class),
        };
        firstPage = createPage(items1);

        MainPageItem[] items2 = new MainPageItem[] {
            	new MainPageItem(R.drawable.icon_dianhua, 
   					 R.string.dianhua, DianhuaActivity.class),
   				new MainPageItem(R.drawable.icon_wifi,
   					 R.string.wifi_authorization, WifiLoginActivity.class),
        };
        secondPage = createPage(items2);
        
        mPageViews = new ArrayList<View>();
        mPageViews.add(firstPage);
        mPageViews.add(secondPage);
        
        mViewPager = (ViewPager) contentView.findViewById(R.id.myviewpager);
        mViewPager.setAdapter(new MyPagerAdapter());
	}
	
	private GridView createPage(MainPageItem[] items) {
        GridView page = (GridView) getLayoutInflater().inflate(
        		R.layout.main_page, null);
        GridViewAdapter adapter = new GridViewAdapter(this);
        adapter.setItems(items);
        page.setAdapter(adapter);
        return page;
	}
	
	private void setupIndicatorView() {
		/*
		 * calculate the top margin of indicator view
		 */
        int screenHeight = getWindowManager().getDefaultDisplay().getHeight();
        screenHeight -= getStatusBarHeight();
        TextView textView = (TextView) firstPage.getAdapter().getView(0, null,
        		firstPage);
        textView.measure(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        int gridViewHeight = (textView.getMeasuredHeight() 
        		+ textView.getPaddingTop() + textView.getPaddingBottom()) * 3;
        int marginTop = (int) ((gridViewHeight + screenHeight * 0.675) / 2) - 10;
        if (marginTop - gridViewHeight > 30)
        	marginTop = gridViewHeight + 30;
        
        indicatorViewGroup 
    		= (LinearLayout) contentView.findViewById(R.id.mybottomviewgroup);
        LinearLayout.LayoutParams params 
    		= (LinearLayout.LayoutParams) indicatorViewGroup.getLayoutParams();
        params.setMargins(0, marginTop, 0, 0);
        indicatorViewGroup.setLayoutParams(params);
        
        mImageViews = new ImageView[mPageViews.size()];
        for (int i = 0; i < mImageViews.length; i++) {
        	mImageView = new ImageView(MainActivity.this);  
        	mImageView.setLayoutParams(new LayoutParams(20,20));  
        	mImageView.setPadding(20, 0, 20, 0);  
        	
        	if (i == 0) {
        		mImageView.setBackgroundResource(R.drawable.page_indicator_focused);				
			} else {
				mImageView.setBackgroundResource(R.drawable.page_indicator);
			}
			
        	mImageViews[i] = mImageView;
        	
        	indicatorViewGroup.addView(mImageViews[i]);
		}
	}
	
	// ensure the status bar is showing
	private int getStatusBarHeight() {
        int statusBarHeight = 0;
        
        // get the height of status bar using reflecting
        try {
        	Class<?> c = Class.forName("com.android.internal.R$dimen");
        	Object obj = c.newInstance();
        	Field field = c.getField("status_bar_height");
        	int x = Integer.parseInt(field.get(obj).toString());
			statusBarHeight = this.getResources().getDimensionPixelSize(x);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			statusBarHeight = 38;
		}
        
        return statusBarHeight;
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.setting, menu);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		int itemId = item.getItemId();
		switch (itemId) {
		case R.id.setting:
			Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
			startActivity(intent);
			break;
		}
		return super.onMenuItemSelected(featureId, item);
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
	
    class MyPagerAdapter extends PagerAdapter {

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
    
    private class ClickListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			Intent intent = null;
			switch(v.getId()){
			case R.id.btn_copyright:
				Log.d(TAG, "copyright click");
				intent = new Intent(MainActivity.this, CopyrightActivity.class);
				break;
			default:
			    intent = new Intent(MainActivity.this, YijianActivity.class);
			}
			startActivity(intent);
		}
    	
    }
    
    private class PageChangeListener implements OnPageChangeListener {
		@Override
		public void onPageSelected(int arg0) {
			for (int i = 0; i < mImageViews.length; i++) {
				if(i == arg0) {
					mImageViews[i].setBackgroundResource(
							R.drawable.page_indicator_focused);
				} else {
					mImageViews[i].setBackgroundResource(
							R.drawable.page_indicator);
				}
			}
		}
		
		@Override
		public void onPageScrolled(int arg0, float arg1, int arg2) {
			
		}
		
		@Override
		public void onPageScrollStateChanged(int arg0) {
			
		}
    }
    
    private class ItemClickListener implements OnItemClickListener {

		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			MainPageItem item = (MainPageItem) parent.getAdapter().getItem(position);
			Intent intent = new Intent(MainActivity.this, item.activityClass);
			MainActivity.this.startActivity(intent);
		}
    }
    
    private class GridViewAdapter extends BaseAdapter {
        private Context mContext;
        private MainPageItem[] items;

        public GridViewAdapter(Context c) {
            mContext = c;
        }
        
        public void setItems(MainPageItem[] items) {
        	this.items = items;
        }

        public int getCount() {
            return items.length;
        }

        public Object getItem(int position) {
            return items[position];
        }

        public long getItemId(int position) {
            return 0;
        }

        public View getView(int position, View convertView, ViewGroup parent) {
            TextView textView;
            
            // if it's not recycled, initialize some attributes
            if (null == convertView) {  
                textView = new TextView(mContext);
                textView.setLayoutParams(new GridView.LayoutParams(
                		LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
                textView.setCompoundDrawablePadding(5);
                textView.setGravity(Gravity.CENTER);
                textView.setPadding(8, 8, 8, 8);
            } else {
                textView = (TextView) convertView;
            }
            
            Drawable top = mContext.getResources()
            		.getDrawable(items[position].imageId);
            
            // the following method must be called, or, the Drawable will
            // not show
            top.setBounds(0, 0, top.getMinimumWidth(), top.getMinimumHeight());
            
            textView.setCompoundDrawables(null, top, null, null);
            textView.setText(items[position].descriptionId);
            
            return textView;
        }
    }
    
    private class MainPageItem {
    	int imageId;
    	int descriptionId;
    	Class<?> activityClass;
    	
    	public MainPageItem(int imageId, int descriptionId, 
    					    Class<?> activityClass) {
    		this.imageId = imageId;
    		this.descriptionId = descriptionId;
    		this.activityClass = activityClass;
    	}
    }
}
