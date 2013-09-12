package org.izju.activity;

import org.izju.common.Constants;

import cn.jpush.android.api.JPushInterface;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class ZjuMobileLibActivity extends Activity {

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
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		WebView webview = new WebView(this);
		setContentView(webview);

		webview.loadUrl(Constants.ZJU_MOBILE_LIB_URL);
		
		webview.setWebViewClient(new WebViewClient() {
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				  view.loadUrl(url);
			      return true;
			}
		});
	}
}
