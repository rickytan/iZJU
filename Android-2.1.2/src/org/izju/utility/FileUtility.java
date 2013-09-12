package org.izju.utility;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.izju.R;

//import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Environment;
import android.util.Log;

class FileUtility {
	private static final String TAG = "org.izju.utility.FileUtility";
	private static final String DATA_DIR = Environment.getExternalStorageDirectory()
			.getAbsolutePath() + "/iZJU";
	private static final String MAIN_DATA = "data.db";
	
	public static boolean copyDataFile(Context context){
		Log.d(TAG, DATA_DIR);
		InputStream is = null;
		FileOutputStream fos = null;
		try {
			is = context.getResources().openRawResource(R.raw.data);
			fos = context.openFileOutput(MAIN_DATA, Context.MODE_PRIVATE);
			byte[] buffer = new byte[4096];
			int count = 0;
			while((count = is.read(buffer)) > 0){
				fos.write(buffer, 0, count);
			}
			return true;
		} catch (IOException e){
			Log.d(TAG, "Copy file error!");
			Log.e(TAG, e.getMessage());
			return false;
		} finally {
			try {
				fos.close();
				is.close();
			} catch (IOException e) {
				Log.e(TAG, e.getMessage());
			}
		}
	}
	
	public static String readData(Context context){
		StringBuilder sb = new StringBuilder();
		InputStream is = null;
		InputStreamReader isr = null;
		BufferedReader  br = null;
		try {
			is = context.openFileInput(MAIN_DATA);
		} catch (FileNotFoundException e) {
			Log.d(TAG, "data file not found in context");
			is = context.getResources().openRawResource(R.raw.data);
		}
		
		try {
			isr = new InputStreamReader(is, "UTF-8");
			br = new BufferedReader(isr);
			String line = null;
			while((line = br.readLine()) != null){
				sb.append(line);
				sb.append('\n');
			}
		} catch (IOException e) {
				Log.d(TAG, "read data error!");
				Log.e(TAG, e.getMessage());
		} finally {
			try {
				br.close();
				isr.close();
				is.close();
			} catch (IOException e) {
				Log.e(TAG, e.getMessage());
			}
		}
		return sb.toString();
	}
	
	private static boolean sdCardExists(){
    	String sdState = Environment.getExternalStorageState();
    	if(sdState.equals(Environment.MEDIA_MOUNTED)){
    		return true;
    	}
    	else{
    		return false;
    	}
    }
}
