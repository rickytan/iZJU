package org.izju.utility;

import org.izju.R;
import org.izju.activity.PostActivity;
import org.izju.common.Constants;
import org.izju.parse.ParseUtil;
import org.json.JSONException;
import org.json.JSONObject;

import com.parse.CountCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.SimpleAdapter;
import android.widget.Toast;

public class UpdateActivityDetailTask extends AsyncTask<String, Integer, String> {
	private static final String TAG = "UpdateActivityDetailTask";
	private Context context;
	private SimpleAdapter adapter;
	private DataChangeHandler dataChangeHandle;
	
	private ProgressDialog dialog;
	
	private String data;
	private int count;
	
	public UpdateActivityDetailTask(Context context, SimpleAdapter adapter, DataChangeHandler dataChangeHandle){
		super();
		this.context = context;
		this.adapter = adapter;
		this.dataChangeHandle = dataChangeHandle;
	}
	
	@Override
	protected void onPreExecute(){
		String msg = context.getString(R.string.loading);
		dialog = ProgressDialog.show(context, null, msg, true, false);
		
	}

	@Override
	protected String doInBackground(String... arg0) {
		final String url = arg0[0];
		final String id = arg0[1];
		if (url != null) {
			try {
				Thread t1 = new Thread(new Runnable() {

					@Override
					public void run() {
						data = DataUtility.getNetData(context, url);
						Log.d(TAG, "net data: " + data);
					}
					
				});
				t1.start();
				Thread t2 = new Thread(new Runnable() {

					@Override
					public void run() {
						count = ParseUtil.queryPostCount(id);
					}
				});
				t2.start();
				
				try {
					t1.join();
					t2.join();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				if (null == data || count < 0)
					return null;
				
				
				JSONObject jsonData = new JSONObject(data);
		        jsonData.put(Constants.PARSE_KEY_UP_COUNT, count);
		        return jsonData.toString();
			} catch (JSONException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
		return null;
	}
	
	@SuppressLint("ShowToast")
    @Override
	protected void onPostExecute(String result){
		if(dialog.isShowing()){
			dialog.dismiss();
		}
		if(result == null){
		    Toast.makeText(context, "亲，网络故障，暂时无法显示", Toast.LENGTH_LONG).show();
		}
		dataChangeHandle.changeData(result);
		if(adapter != null)
			adapter.notifyDataSetChanged();
	}
}
