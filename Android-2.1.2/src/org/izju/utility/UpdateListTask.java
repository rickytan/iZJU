package org.izju.utility;

import org.izju.R;
import org.izju.activity.PostActivity;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.SimpleAdapter;
import android.widget.Toast;

public class UpdateListTask extends AsyncTask<String, Integer, String> {
	private Context context;
	private SimpleAdapter adapter;
	private DataChangeHandler dataChangeHandle;
	
	private ProgressDialog dialog;
	
	public UpdateListTask(Context context, SimpleAdapter adapter, DataChangeHandler dataChangeHandle){
		super();
		this.context = context;
		this.adapter = adapter;
		this.dataChangeHandle = dataChangeHandle;
	}
	
	@Override
	protected void onPreExecute(){
		String msg = context.getString(R.string.loading);
		dialog = ProgressDialog.show(context, null, msg, true, true);
		dialog.setCanceledOnTouchOutside(false);
		dialog.setOnCancelListener(new OnCancelListener() {

			@Override
			public void onCancel(DialogInterface dialog) {
				Toast.makeText(context, R.string.operation_canceled, 
							   Toast.LENGTH_LONG).show();
			}
		});
	}

	@Override
	protected String doInBackground(String... arg0) {
		String url = arg0[0];
		if (url != null)
		    return DataUtility.getNetData(context, url);
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
