package org.izju.activity;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.db.WifiAccount;
import org.izju.db.WifiAccountDao;

import com.baidu.mobstat.StatActivity;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class WifiLoginActivity extends StatActivity {

	private static final String TAG = "WifiLoginActivity";
	
	private static long LOGIN_TIMEOUT = 4000;
	private static long LOGOUT_TIMEOUT = 4000;
	private static long FIRST_TEST_NETWORK_TIMEOUT = 3000;
	private static long SECOND_TEST_NETWORK_TIMEOUT = 3000;
	
	private TextView textViewErrorMsg;
	private TextView textViewWifiState;
	private Button btnWifiLogin;
	private Button btnSwitchWifi;
	private Button btnAccountManage;
	private Button btnBack;
	private CheckBox cbLoginOnConnect;
	
	private WifiManager wifiManager;
	private ConnectivityManager connectivityManager;
	private String ssid;
	
	private String defaultUsername = null;
	private String defaultPassword = null;
	
	// 0 for unavailable, 1 for available
	private int wifiState;
	
	private WifiAccountDao wifiAccountDao;
	
	private final int MSG_TO_LOGIN = 0;
	private final int MSG_LOGOUT_RESULT = 1;
	
	private final String[] WIFI_LOGIN_ERRORS = new String[] {
	        "user_tab_error",
	        "Token error",
	        "username_error",
	        "non_auth_error",
	        "password_error",
	        "status_error",
	        "available_error",
	        "ip_exist_error",
	        "usernum_error",
	        "online_num_error",
	        "mode_error",
	        "time_policy_error",
	        "flux_error",
	        "minutes_error",
	        "ip_error",
	        "mac_error",
	        "sync_error",
	};
	
	/**
	 * Used for IPC: Shared memory
	 */
	private static String HttpResponse;
	
	private Handler handler = new Handler() {
		 public void handleMessage(Message msg) {
			 	switch (msg.what) {
			 	case MSG_TO_LOGIN:
			 		Log.d(TAG, "username: " + defaultUsername);
			 		Log.d(TAG, "password: " + defaultPassword);
			 		login(ssid, defaultUsername, defaultPassword);
			 		break;
			 	case MSG_LOGOUT_RESULT:
			 		String res = (String) msg.obj;
			 		Log.d(TAG, "logout result: " + res);
			 		Context context = WifiLoginActivity.this;
			 		if (null != res) {
			 			if (res.equals("logout_ok")) {
			 				res = context.getString(R.string.logout_ok);
			 			}
			 		} else {
			 			res = context.getString(R.string.logout_fail);
			 		}
			 		Toast.makeText(context, res, Toast.LENGTH_SHORT).show();
			 		onLogout();
			 		break;
			 	}
		}
	};
	
//	private BroadcastReceiver mReceiver = new BroadcastReceiver() {
//
//		@Override
//		public void onReceive(Context context, Intent intent) {
//			String action = intent.getAction();
//			Log.d(TAG, "action: " + action);
////			Toast.makeText(context, action, Toast.LENGTH_LONG).show();
//			reinit();
//		}
//		
//	};
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.wifi_manager);
		
		loadResources();
		registerListeners();
		
		init();
		
//        IntentFilter intentFilter = new IntentFilter(
//        		Constants.NETWORK_INACCESSIBLE);
//        intentFilter.addAction(Constants.NETWORK_ACCESSIBLE);
//        registerReceiver(mReceiver, intentFilter);
	}
	
	@Override
	public void onPause() {
		this.finish();
		super.onPause();
	}

	private void loadResources() {
		((TextView)findViewById(R.id.top_title_txt)).setText(
				R.string.wifi_authorization);
		textViewErrorMsg = (TextView) findViewById(R.id.textview_error_msg);
		textViewWifiState = (TextView) findViewById(R.id.textview_wifi_state);
		btnWifiLogin = (Button) findViewById(R.id.btn_wifi_login);
		btnSwitchWifi = (Button) findViewById(R.id.btn_switch_wifi);
		btnBack = (Button) findViewById(R.id.top_bak_btn);
		btnAccountManage = (Button) findViewById(R.id.top_btn_2);
		btnAccountManage.setText(R.string.account_manage);
		cbLoginOnConnect = (CheckBox) findViewById(R.id.cb_login_on_connect);
	}
	
	private void registerListeners() {
		OnClickListener l = new ClickListener();
		btnWifiLogin.setOnClickListener(l);
		btnSwitchWifi.setOnClickListener(l);
		btnAccountManage.setOnClickListener(l);
		btnBack.setOnClickListener(l);
	}
	
//	private void reinit() {
//		// initialize all components
//		btnWifiLogin.setVisibility(View.VISIBLE);
//		btnWifiLogin.setEnabled(true);
//		btnWifiLogin.setText(R.string.wifi_login);
//		
//		btnSwitchWifi.setVisibility(View.VISIBLE);
//		btnSwitchWifi.setEnabled(true);
//		
//		cbLoginOnConnect.setVisibility(View.VISIBLE);
//		cbLoginOnConnect.setEnabled(true);
//		
//		update();
//	}
	
	private void init() {
		wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
		connectivityManager = (ConnectivityManager) 
				getSystemService(Context.CONNECTIVITY_SERVICE);
		wifiAccountDao = new WifiAccountDao(this);
		
		update();
	}

	private void update() {
		NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
		if (null == networkInfo || 
				networkInfo.getType() != ConnectivityManager.TYPE_WIFI) {
			textViewWifiState.setText(R.string.no_wifi_connect);
			disableLogin();
			return;
		}
		
		WifiInfo wifiInfo = wifiManager.getConnectionInfo();
		ssid = wifiInfo.getSSID();
		if (null == ssid || ssid.length() < 1)
			return;
		
		// if SSID is surrounded by double quotation marks, remote them to
		// simplify the processing logic
		if (ssid.charAt(0) == '\"' && ssid.charAt(ssid.length() - 1) == '\"') {
			ssid = ssid.substring(1, ssid.length() - 1);
			if (ssid.length() < 1)
				return;
		}
		Log.v(TAG, "connect to: " + ssid);
		
		SharedPreferences pref = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		cbLoginOnConnect.setChecked(
				pref.getBoolean(
						Constants.PREF_KEY_LOGIN_ON_CONNECT + ssid, true));
		
		textViewWifiState.setText(this.getString(R.string.connect_to) + ssid);
		if (!needAuthorization(ssid)) {
			disableLogin();
			return;
		}
		
		// test whether the device has connected to the Internet
		TestNetwork(ssid);
	}
	
	private void TestNetwork(final String ssid) {
		new TestWifiAsyncTask().execute(ssid);
	}
	
	private void connect(String ssid) {
		SharedPreferences pref = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		boolean loginOnConnect = pref.getBoolean(
				Constants.PREF_KEY_LOGIN_ON_CONNECT + ssid, true);
		if (!loginOnConnect) {
			return;
		}
		
		requestAuthorization(ssid);
	}

	private void requestAuthorization(String ssid) {
		defaultUsername = null;
		defaultPassword = null;
		getDefaultLoginInfo();
		if (null == defaultUsername) {
            LayoutInflater factory = LayoutInflater.from(this);
            final View textEntryView = factory.inflate(
            		R.layout.alert_dialog_text_entry, null);
            final EditText edtUsername = (EditText) textEntryView.findViewById(
            		R.id.edt_wifi_username);
    
            final EditText edtPassword = (EditText) textEntryView.findViewById(
            		R.id.edt_wifi_password);
            
            new AlertDialog.Builder(WifiLoginActivity.this)
                .setTitle(R.string.setting_username_password)
                .setView(textEntryView)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	defaultUsername = edtUsername.getText().toString();
                    	defaultPassword = edtPassword.getText().toString();
                    	if (defaultUsername.length() == 0 ||
                    			defaultPassword.length() ==0) {
                    		Toast.makeText(WifiLoginActivity.this, 
                    				R.string.illegal_info, Toast.LENGTH_SHORT).show();
                    		return;
                    	}
                    	handler.sendEmptyMessage(MSG_TO_LOGIN);
                    	
        				// hide soft keyboard
        				InputMethodManager imm = 
        						(InputMethodManager) WifiLoginActivity.this
        						.getSystemService(Context.INPUT_METHOD_SERVICE);
        				imm.hideSoftInputFromWindow(
        						edtPassword.getWindowToken(), 0);
                    }
                })
                .setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	Toast.makeText(WifiLoginActivity.this, 
                    			R.string.no_username_password, 
                    			Toast.LENGTH_SHORT).show();
                    }
                })
                .create().show();
            return;
		}
		
		login(ssid, defaultUsername, defaultPassword);
	}
	
	private void getDefaultLoginInfo() {
		List<WifiAccount> wifiAccounts = wifiAccountDao.getScrollData(0, 
				(int) wifiAccountDao.getCount());
		if (wifiAccounts.size() == 0)
			return;
		
		SharedPreferences pref = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		int defaultUserNo = pref.getInt(Constants.PREF_KEY_DEFAULT_USER_NO, 0);
		defaultUsername = wifiAccounts.get(defaultUserNo).getUsername();
		defaultPassword = wifiAccounts.get(defaultUserNo).getPassword();
	}

	private boolean needAuthorization(String ssid) {
		String[] authorizationWifis = this.getResources().getStringArray(
				R.array.authorization_wifis);
		for (String wifi : authorizationWifis) {
			if (wifi.equalsIgnoreCase(ssid)) {
				return true;
			}
		}
		return false;
	}

	private void disableLogin() {
		btnWifiLogin.setEnabled(false);
		cbLoginOnConnect.setEnabled(false);
	}
	
	private static String getHttpResponse(String urlStr, String method, String content,
			int connectTimeout, int readTimeout) {
        HttpURLConnection conn = null;
        InputStream in = null;
        String res = "";
		try {
			URL url = new URL(urlStr);
			conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod(method);
            conn.setConnectTimeout(connectTimeout);
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setRequestProperty("Content-Type", 
            		"application/x-www-form-urlencoded");
            conn.setReadTimeout(readTimeout);
            conn.connect();
            if ("POST".equals(method)) {
                DataOutputStream dos = new DataOutputStream(conn.getOutputStream());
                dos.writeBytes(content);
                dos.flush();
                dos.close();
            }
            
            in = conn.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String line = "";
            while (null != (line = br.readLine())) {
            	res += line;
            }
            
            Log.v(TAG, "res: " + res);
		} catch (MalformedURLException e) {
			e.printStackTrace();
			res = null;
		} catch (IOException e) {
			e.printStackTrace();
			res = null;
		} finally {
			if (null != conn)
				conn.disconnect();
			if (null != in)
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
		
		return res;
	}
	
	private void showErrorMessage(String result) {
		String[] errorDescriptions = this.getResources().getStringArray(
				R.array.error_descriptions);
		String message = this.getString(R.string.unknown_error);
		
		int flag = 0;
		if (null != result) {
			for (int i = 0; i < WIFI_LOGIN_ERRORS.length; i++) {
				if (WIFI_LOGIN_ERRORS[i].equals(result)) {
					message = errorDescriptions[i];
					flag = 1;
					break;
				}
			}
		}
		
		textViewErrorMsg.setVisibility(View.VISIBLE);
		textViewErrorMsg.setText(message);
		
		// unknown error
		if (0 == flag) {
			Toast.makeText(WifiLoginActivity.this, 
					R.string.restart_wifi, Toast.LENGTH_SHORT).show();
		}
	}
	
	private void login(String ssid, String username, String password) {
		new LoginAsyncTask().execute(ssid, username, password);
	}
	
	private void onLogin(String ssid, String result) {
		Toast.makeText(this, R.string.login_success, Toast.LENGTH_SHORT).show();
		textViewErrorMsg.setVisibility(View.INVISIBLE);
		btnWifiLogin.setText(R.string.logout);
		btnSwitchWifi.setVisibility(View.GONE);
		cbLoginOnConnect.setVisibility(View.GONE);
		wifiState = 1;
		
		/**
		 * Only when there is no account locally do save the information of
		 * current account, because that we always get the local account firstly
		 * to login.
		 */
		if (wifiAccountDao.getCount() == 0) {
			if (null != defaultUsername)
				wifiAccountDao.save(
						new WifiAccount(defaultUsername, defaultPassword));
		}
		
		SharedPreferences pref = this.getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		Editor editor = pref.edit();
		
		editor.putBoolean(Constants.PREF_KEY_LOGIN_ON_CONNECT + ssid, 
				cbLoginOnConnect.isChecked());
		editor.commit();
	}
	
	private void logout() {
        new Thread(new Runnable() {
        	@Override
        	public void run() {
                String urlStr = 
                		"http://10.50.200.245/cgi-bin/srun_portal";
                String content = "action=logout&type=2";
        		String response 
        				= getHttpResponse(urlStr, "POST", content, 2000, 2000);
        		Message msg = new Message();
        		msg.what = MSG_LOGOUT_RESULT;
        		msg.obj = response;
        		handler.sendMessage(msg);
        	}
        }).start();
	}
	
	private void onLogout() {
		wifiState = 0;
		btnWifiLogin.setText(R.string.wifi_login);
		btnSwitchWifi.setVisibility(View.VISIBLE);
		cbLoginOnConnect.setVisibility(View.VISIBLE);
	}

	private void back() {
		super.onBackPressed();
//		this.unregisterReceiver(mReceiver);
	}
	
	class ClickListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.btn_wifi_login:
				if (1 == wifiState) {
					logout();
				} else {
					textViewErrorMsg.setVisibility(View.INVISIBLE);
					requestAuthorization(ssid);
				}
				break;
			case R.id.btn_switch_wifi:
				WifiLoginActivity.this.startActivity(
						new Intent(
								android.provider.Settings.
								ACTION_WIFI_SETTINGS));
				break;
			case R.id.top_bak_btn:
				back();
				break;
			case R.id.top_btn_2:
				Intent intent = new Intent(WifiLoginActivity.this, 
						WifiAccountManagerActivity.class);
				WifiLoginActivity.this.startActivity(intent);
				break;
			}
		}
		
	}
	
	class LoginAsyncTask extends AsyncTask<String, Integer, String> {
		private ProgressDialog dialog;
		private String ssid; 
		
		@Override
		protected void onPreExecute() {
			dialog = new ProgressDialog(WifiLoginActivity.this, 0);
			dialog.setMessage(WifiLoginActivity.this.getString(
					R.string.logining));
			dialog.setIndeterminate(true);
			if (null != WifiLoginActivity.this 
					&& !WifiLoginActivity.this.isFinishing()) {
				dialog.show();				
			}
		}

		@Override
		protected String doInBackground(String... params) {
			ssid = params[0];
			String username = params[1];
			String password = params[2];
			
            String urlStr = "http://10.50.200.245/cgi-bin/srun_portal";
            String content = "action=login&username=" + username + 
            				 "&password="  + password + 
            				 "&ac_id=3&is_ldap=1&type=2&local_auth=1";
            
            Log.d(TAG, "login url: " + urlStr);
            String loginResult = login(urlStr, content);
			
			if ("online_num_error".equals(loginResult)) {
				if (forceLogout(username, password)) {
					// try again
					loginResult = login(urlStr, content);
					Log.d(TAG, "try again result: " + loginResult);
				}
			}
			
            return loginResult;
		}
		
		private String login(String urlStr, String content) {
            String loginResult = getHttpResponse(
            		urlStr, "POST", content, 3000, 3000, LOGIN_TIMEOUT);
            if (null == loginResult)
            	return null;
            
            if (loginResult.contains("login_ok")) {
            	loginResult = "login_ok";
            }
            
            if (!loginResult.equals("login_ok")) {
            	// Maybe there are bugs in the system of  wireless network 
            	// authorization, that is, we can connect to Internet when login
            	// result is not OK.
                if (connectedToInternet(SECOND_TEST_NETWORK_TIMEOUT)) {
                	loginResult = "login_ok";
                }
            }
            return loginResult;
		}
		
		private boolean forceLogout(String username, String password) {
            String urlStr = 
            		"http://10.50.200.245/cgi-bin/srun_portal";
            String content = "action=logout&uid=-1&username=" + username + 
            		"&password=" + password + "&force=1&type=2";
            String result = getHttpResponse(urlStr, "POST", content, 5000, 3000,
            		LOGOUT_TIMEOUT);
            Log.d(TAG, "force logout res: " + result);
            return "logout_ok".equals(result);
		}
		
		@Override
		protected void onProgressUpdate(Integer... progress) {
            dialog.setMessage(
            		WifiLoginActivity.this.getString(R.string.testing_wifi));
	    }
		
		@Override
		protected void onPostExecute(String result) {
			if (null != result && result.equals("login_ok")) {
				onLogin(ssid, result); 
			} else {
				showErrorMessage(result);
			}
			if (null != WifiLoginActivity.this 
					&& !WifiLoginActivity.this.isFinishing()) {
				dialog.dismiss();
			}
		}
	}
	
	private class TestWifiAsyncTask extends AsyncTask<String, Void, Boolean> {
		private ProgressDialog dialog;
		private String ssid;
		
		@Override
		protected void onPreExecute() {
			dialog = new ProgressDialog(WifiLoginActivity.this, 0);
			dialog.setMessage(WifiLoginActivity.this.getString(
					R.string.testing_wifi));
			dialog.setIndeterminate(true);
			if (null != WifiLoginActivity.this 
					&& !WifiLoginActivity.this.isFinishing()) {
				dialog.show();			
			}
		}
		
		@Override
		protected Boolean doInBackground(String... params) {
			ssid = params[0];
			return connectedToInternet(FIRST_TEST_NETWORK_TIMEOUT);
		}
		
		@Override
		protected void onPostExecute(Boolean result) {			
			if (result) {
		 		onLogin(ssid, null);
			} else {
		 		connect(ssid);
			}
			
			if (null != WifiLoginActivity.this 
					&& !WifiLoginActivity.this.isFinishing()) {
				dialog.dismiss();		
			}
		}
	}
	
//	public static boolean pingHost(String host) {
//		Process p = null;
//	    boolean res = false;
//        try {
//            p = Runtime.getRuntime().exec("ping -c 1 -w 2 " + host);
//            res = (p.waitFor() == 0);
//        } catch (IOException e) {
//            e.printStackTrace();
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        } finally {
//            if (null != p)
//                p.destroy();
//        }
//        return res;
//	}
	
	private static boolean connectedToInternet(long timeout) {
		boolean networkAvailable = false;
		String url = "http://www.apple.com/library/test/success.html";                  
		String responeText = 
				getHttpResponse(url, "GET", null, 5000, 3000, timeout);
		Log.d(TAG, "test network: " + responeText);
		if (null != responeText && responeText.contains("Success")) {                   
			networkAvailable = true;                                               
		}

		return networkAvailable;
	}
	
	/**
	 * 
	 * @param urlStr
	 * @param method
	 * @param content
	 * @param connectTimeout
	 * @param readTimeout
	 * @param timeout the time for getting HTTP response, in case waiting for
	 * 		  long time
	 * @return
	 */
	private synchronized static String getHttpResponse(final String urlStr, 
			final String method, final String content, 
			final int connectTimeout, final int readTimeout, 
			final long timeout) {
		HttpResponse = null;
		Thread thread = new Thread(new Runnable() {
			public void run() {                 
				HttpResponse = getHttpResponse(
						urlStr, method, content, connectTimeout, readTimeout);			
			}
		});
		thread.start();
		try {
			thread.join(timeout);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		thread.interrupt();
		
		return HttpResponse;
	}
}
