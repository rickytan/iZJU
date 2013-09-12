package org.izju.activity;

import java.util.List;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.db.WifiAccount;
import org.izju.db.WifiAccountDao;
import org.izju.post.ArrayListAdapter;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckedTextView;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class WifiAccountManagerActivity extends StatActivity {
	private final String TAG = "WifiAccountManagerActivity";
	
	private ListView listView;
	private List<WifiAccount> wifiAccounts;
	private AccountEntryAdapter adapter;
	private WifiAccountDao wifiAccountsDao;
	
	private Button bakBtn;
	private Button btnAddAccount;
	
	private View preVisibleOperationView;
	
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
        setContentView(R.layout.wifi_accounts_manager);
        
        loadResources();
        registerListeners();
        
        init();
	}
	
	private void loadResources() {
        bakBtn = (Button) findViewById(R.id.top_bak_btn);
        btnAddAccount = (Button) findViewById(R.id.top_btn_2);
        btnAddAccount.setText(R.string.add_account);
        
        TextView titleText = (TextView) findViewById(R.id.top_title_txt);
        titleText.setText(R.string.account_manage);
        
        listView = (ListView) findViewById(R.id.listview_wifi_account);
	}
	
	private void registerListeners() {
		OnClickListener l = new ClickListener();
		bakBtn.setOnClickListener(l);
		btnAddAccount.setOnClickListener(l);
	}
	
	private void init() {
        wifiAccountsDao = new WifiAccountDao(this);
        wifiAccounts = wifiAccountsDao.getScrollData(0, 
        		(int) wifiAccountsDao.getCount());
        
        if (wifiAccounts.size() == 0)
        	Toast.makeText(this, R.string.no_account, Toast.LENGTH_SHORT).show();
        
        adapter = new AccountEntryAdapter(this);
        adapter.setList(wifiAccounts);
        SharedPreferences pref = this.getSharedPreferences(
        		Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
        adapter.setDefault(pref.getInt(Constants.PREF_KEY_DEFAULT_USER_NO, 0));
        
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new ItemClickListener());
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
	
	private void addWifiAccount() {
        LayoutInflater factory = LayoutInflater.from(
        		WifiAccountManagerActivity.this);
        final View textEntryView = factory.inflate(
        		R.layout.alert_dialog_text_entry, null);
        final EditText edtUsername = (EditText) textEntryView.findViewById(
        		R.id.edt_wifi_username);
        final EditText edtPassword = (EditText) textEntryView.findViewById(
        		R.id.edt_wifi_password);
        
        new AlertDialog.Builder(WifiAccountManagerActivity.this)
        .setTitle(R.string.setting_username_password)
        .setView(textEntryView)
        .setPositiveButton(R.string.ok, 
        		new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int whichButton) {
            	String username = edtUsername.getText().toString();
            	String password = edtPassword.getText().toString();
            	if (username.length() == 0 || password.length() ==0) {
            		Toast.makeText(WifiAccountManagerActivity.this, 
            				R.string.illegal_info, Toast.LENGTH_SHORT).show();
            		return;
            	}
            	
            	WifiAccount account = new WifiAccount(username, password);
            	wifiAccounts.add(account);
            	wifiAccountsDao.save(account);
            	
            	adapter.notifyDataSetChanged();
            }
        })
        .setNegativeButton(R.string.cancel, 
        		new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int whichButton) {
            }
        })
        .create().show();
	}
	
	class ClickListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.top_bak_btn:
				back();
				break;
			case R.id.top_btn_2: // add new wifi account
				addWifiAccount();
				break;
			}
		}
	}
	
	class ItemClickListener implements OnItemClickListener, OnClickListener {
		
		private int pos;
		
		@Override
		public void onItemClick(AdapterView<?> parent, final View itemView, 
							    int pos, long id) {
			this.pos = pos;
			if (null != preVisibleOperationView && 
					preVisibleOperationView != itemView) {
				preVisibleOperationView.setVisibility(View.GONE);
				preVisibleOperationView = null;
				return;
			}
			
			preVisibleOperationView = itemView.findViewById(
										R.id.layout_account_operation);
			preVisibleOperationView.setVisibility(View.VISIBLE);
			
			itemView.findViewById(R.id.tv_edit).setOnClickListener(this);
			itemView.findViewById(R.id.tv_delete).setOnClickListener(this);
			itemView.findViewById(R.id.tv_set_default).setOnClickListener(this);
		}

		@Override
		public void onClick(View v) {
			switch(v.getId()) {
			case R.id.tv_edit:
				editAccount(pos);
				break;
			case R.id.tv_delete:
				delAccount(pos);
				break;
			case R.id.tv_set_default:
				setDefaultAccount(pos);
				break;
			}
		}
		
		private void setDefaultAccount(int pos) {
			Editor editor = 
					WifiAccountManagerActivity.this.getSharedPreferences(
							Constants.SHARED_PREFERENCE_NAME, 
							Context.MODE_PRIVATE).edit();
			editor.putInt(Constants.PREF_KEY_DEFAULT_USER_NO, pos);
			editor.commit();
			
			adapter.setDefault(pos);
		}

		private void delAccount(final int pos) {
            new AlertDialog.Builder(WifiAccountManagerActivity.this)
            .setTitle(R.string.confirm_delete_account)
            .setPositiveButton(R.string.ok, 
            		new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {

        			wifiAccountsDao.delete(wifiAccounts.get(pos));
        			wifiAccounts.remove(pos);
        			
        			if (pos == adapter.getDefaultPos()) {
        				setDefaultAccount(0);
        			}
        			
        			adapter.notifyDataSetChanged();
                }
            })
            .setNegativeButton(R.string.cancel, 
            		new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                }
            })
            .create().show();
		}

		private void editAccount(final int pos) {
			
            LayoutInflater factory = LayoutInflater.from(
            		WifiAccountManagerActivity.this);
            final View textEntryView = factory.inflate(
            		R.layout.alert_dialog_text_entry, null);
            final EditText edtUsername = (EditText) textEntryView.findViewById(
            		R.id.edt_wifi_username);
            edtUsername.setText(wifiAccounts.get(pos).getUsername());
            final EditText edtPassword = (EditText) textEntryView.findViewById(
            		R.id.edt_wifi_password);
            
            new AlertDialog.Builder(WifiAccountManagerActivity.this)
            .setTitle(R.string.setting_username_password)
            .setView(textEntryView)
            .setPositiveButton(R.string.ok, 
            		new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                	String username = edtUsername.getText().toString();
                	String password = edtPassword.getText().toString();
                	Log.d(TAG, "username: " + username);
                	if (username.length() == 0 || password.length() ==0) {
                		Toast.makeText(WifiAccountManagerActivity.this, 
                				R.string.illegal_info, Toast.LENGTH_SHORT).show();
                		return;
                	}
                	
                	WifiAccount account = wifiAccounts.get(pos);
                	account.setUsername(username);
                	account.setPassword(password);
                	wifiAccountsDao.update(account);
                	
                	wifiAccounts.remove(pos);
                	wifiAccounts.add(pos, account);
                	adapter.notifyDataSetChanged();
                }
            })
            .setNegativeButton(R.string.cancel, 
            		new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                }
            })
            .create().show();
		}
	}
	
	class AccountEntryAdapter extends ArrayListAdapter<WifiAccount> {

		private static final String TAG = "AccountEntryAdapter";
		private LayoutInflater inflater;
		
		/**
		 * the default account to login
		 */
		private int defaultPos;

		public AccountEntryAdapter(Context context) {
			super();
			defaultPos = 0;
			inflater = (LayoutInflater) context
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		}
		
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder holder;
			if (convertView == null) {
				convertView = inflater.inflate(
						R.layout.wifi_account_list_item, null);

				holder = new ViewHolder();
				holder.username = (CheckedTextView) convertView.findViewById(
						R.id.chk_textview_wifi_account);
				holder.accountOperationLayout 
							= (LinearLayout) convertView.findViewById(
									R.id.layout_account_operation);
				convertView.setTag(holder);
			} else {
				holder = (ViewHolder) convertView.getTag();
			}

			holder.username.setText(mList.get(position).getUsername());
			if (position == defaultPos) {
				holder.username.setChecked(true);
			} else {
				holder.username.setChecked(false);
			}
			
			holder.accountOperationLayout.setVisibility(View.GONE);
			return convertView;
		}
		
		public void setDefault(int pos) {
			if (defaultPos == pos)
				return;
			
			defaultPos = pos;
			notifyDataSetChanged();
		}
		
		public int getDefaultPos() {
			return defaultPos;
		}

		class ViewHolder {
			CheckedTextView username;
			LinearLayout accountOperationLayout;
		}
	}
}
