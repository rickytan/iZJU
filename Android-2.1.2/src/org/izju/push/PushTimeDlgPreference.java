package org.izju.push;

import java.util.ArrayList;
import java.util.List;
import org.izju.R;

import android.content.Context;
import android.preference.DialogPreference;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.Toast;

public class PushTimeDlgPreference extends DialogPreference {
	
	private static final String TAG = "PushTimeDlgPreference";
	private Spinner startHourSpinner;
	private Spinner endHourSpinner;
	private SpinnerAdapter adapter;
	private Context context;

	public PushTimeDlgPreference(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.context = context;
		
		List<String> hours = new ArrayList<String>();
		for (int i = 0; i < 24; i++) 
			hours.add(String.format("%02d:00", i));
		adapter = new ArrayAdapter<String>(context, 
				android.R.layout.simple_spinner_dropdown_item, hours);
	}
	
	@Override
	protected void onBindDialogView(View view) {
		startHourSpinner = (Spinner)view.findViewById(R.id.spinner1);
		endHourSpinner = (Spinner)view.findViewById(R.id.spinner2);
		startHourSpinner.setAdapter(adapter);
		endHourSpinner.setAdapter(adapter);
		
		int pushTime = getSharedPreferences().getInt(getKey(), 0x0816);
		int startHour = ((pushTime & 0x00ff00) >> 8);
		int endHour = (pushTime & 0x00ff);
		startHourSpinner.setSelection(startHour);
		endHourSpinner.setSelection(endHour);
		
		super.onBindDialogView(view);
	}

	@Override
	protected void onDialogClosed(boolean positiveResult) {
		if (positiveResult) {
			int startHour = startHourSpinner.getSelectedItemPosition();
			int endHour = endHourSpinner.getSelectedItemPosition();
			if (endHour < startHour) {
				Toast.makeText(context, R.string.push_time_error, Toast.LENGTH_SHORT).show();
				return;
			}
			PushUtil.setPushTime(context, startHour, endHour);
			
			int pushTime = (startHour << 8) + endHour;
			this.setSummary(pushTime);
			persistInt(pushTime);
		}
		super.onDialogClosed(positiveResult);
	}

	public void setSummary(int pushTime) {
		Log.d(TAG, "push time: " + pushTime);
		int startHour = ((pushTime & 0x00ff00) >> 8);
		int endHour = (pushTime & 0x00ff);
		String summaryFormat = context.getString(R.string.push_time_summary_format);
		setSummary(String.format(summaryFormat, startHour, endHour));
	}
}
