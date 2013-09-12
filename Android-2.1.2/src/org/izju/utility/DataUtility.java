package org.izju.utility;

import java.io.IOException;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.simple.JSONValue;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class DataUtility {
    private static final String TAG = "org.izju.utility.DataUtility";
	
    public static boolean copyDataFile(Context context){
		return FileUtility.copyDataFile(context);
	}
	
	public static JSONObject getObjData(Context context, String path){
		return (JSONObject)getData(context, path, false);
	}
	
	public static JSONArray getArrData(Context context, String path){
		return (JSONArray)getData(context, path, true);
	}
	
	public static String getNetData(Context context, String url){
	    if(!isNetworkAvailable(context)){
			return null;
		}
		
	    BasicHttpParams httpParams = new BasicHttpParams();
	    HttpConnectionParams.setConnectionTimeout(httpParams, 3000);
	    HttpConnectionParams.setSoTimeout(httpParams, 4000);
		HttpClient client = new DefaultHttpClient(httpParams);
		
		try {
			HttpResponse response = client.execute(new HttpGet(url));
			if(response.getStatusLine().getStatusCode() == HttpStatus.SC_OK){
				String result = EntityUtils.toString(response.getEntity());
				if (result != null)
				    return JSONValue.parse(result).toString();
			}
			else {
			    Log.w("TAG", "Service is unavailable.");
			}
		} catch (IOException e) {
		    Log.w("TAG", "network error.");
		}
		return null;
	}
	
	public static String sendNetData(Context context, String url, List<BasicNameValuePair> params) {
	    if(!isNetworkAvailable(context)){
            return null;
        }
	    
	    BasicHttpParams httpParams = new BasicHttpParams();
        HttpConnectionParams.setConnectionTimeout(httpParams, 3000);
        HttpConnectionParams.setSoTimeout(httpParams, 4000);
        HttpClient client = new DefaultHttpClient(httpParams);
        
        try {
            HttpPost httpPost = new HttpPost(url);
            httpPost.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
            HttpResponse response = client.execute(httpPost);
            if(response.getStatusLine().getStatusCode() == HttpStatus.SC_OK){
                
                String result = EntityUtils.toString(response.getEntity());
                if (result != null)
                    return JSONValue.parse(result).toString();
            }
            else {
                Log.w("TAG", "Service is unavailable.");
            }
        } catch (IOException e) {
            Log.w("TAG", "network error.");
        }
	    return null;
	}
	
	public static boolean isNetworkAvailable(Context context){
		NetworkInfo info = ((ConnectivityManager)(context.getSystemService(Context.CONNECTIVITY_SERVICE)))
		.getActiveNetworkInfo();
		if(info == null || !info.isConnected()){
			return false;
		}
		return true;
	}
	
	private static Object getData(Context context, String path, boolean isArray){
		Object res = null;
		JSONObject jsonData = getStringData(context);
		try {
			String[] paths = path.split("/");
			for(int i=0; i<paths.length-1; i++){
				jsonData = jsonData.getJSONObject(paths[i]);
			}
			if(isArray){
				res = jsonData.getJSONArray(paths[paths.length-1]);
			}
			else {
				res = jsonData.getJSONObject(paths[paths.length-1]);
			}
		} catch (JSONException e){
		    Log.w(TAG, "parse json error.");
		}
		return res;
	}
	
	private static JSONObject getStringData(Context context){
		String strData = FileUtility.readData(context);
		JSONObject json = null;
		try {
			json = new JSONObject(strData);
		} catch (JSONException e) {
		    Log.e(TAG, e.getMessage());
		}
		return json;
	}
}
