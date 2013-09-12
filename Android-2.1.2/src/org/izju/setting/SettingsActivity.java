package org.izju.setting;

import org.izju.R;
import org.izju.common.Constants;
import org.izju.push.PushTimeDlgPreference;
import org.izju.push.PushUtil;

import cn.jpush.android.api.JPushInterface;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.DialogPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.util.Log;

public class SettingsActivity extends PreferenceActivity {

	private static final String TAG = "SettingsActivity";
	private String notifyPrefKey;
	private String pushTimePrefKey;
	private DialogPreference pushTimePref;
	private CheckBoxPreference notifyPref;

	public SettingsActivity() {
		
	}
	
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
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.xml.preference);
		
		PreferenceManager pm = getPreferenceManager();
		pm.setSharedPreferencesName(Constants.SHARED_PREFERENCE_NAME);
		pm.setSharedPreferencesMode(Context.MODE_PRIVATE);
		
		notifyPrefKey = this.getString(R.string.key_push);
		notifyPref = (CheckBoxPreference) pm.findPreference(notifyPrefKey);
		notifyPref
			.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {
			@Override
			public boolean onPreferenceChange(Preference arg0, Object allow) {
				if (allow.equals(Boolean.valueOf(false))) {
					Log.d(TAG, "disable push");
					PushUtil.disablePush(getApplicationContext());
				} else {
					Log.d(TAG, "enable push");
					PushUtil.enablePush(getApplicationContext());
				}
				return true;
			}
		});

		pushTimePrefKey = this.getString(R.string.key_push_time);
		pushTimePref = (PushTimeDlgPreference)pm.findPreference(pushTimePrefKey);
		pushTimePref.setDependency(notifyPrefKey);
		
		init();
	}
	
	private void init() {
		SharedPreferences settings = getSharedPreferences(
				Constants.SHARED_PREFERENCE_NAME, Context.MODE_PRIVATE);
		
		boolean notify = settings.getBoolean(notifyPrefKey, true);
		notifyPref.setChecked(notify);
		int pushTime = settings.getInt(pushTimePrefKey, 0x0816);
		pushTimePref.setSummary(pushTime);
	}
}
