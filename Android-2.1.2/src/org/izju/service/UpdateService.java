package org.izju.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.izju.activity.MainActivity;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;

public class UpdateService extends Service {
	private final String TAG = "org.izju.service.UpdateService";
	private NotificationManager updateNotificationManager = null;
	private Notification updateNotification = null;
	private PendingIntent updatePendingIntent = null;
	private Intent updateIntent = null;
	private File updateFile = null;
	private String updateurl = null;
	
	private final int DOWNLOAD_COMPLETE = 0;
	private final int DOWNLOAD_FAIL = -1;

	@Override
	public IBinder onBind(Intent arg0) {
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public int onStartCommand (Intent intent, int flags, int startId){
		Log.d(TAG, "update service");
		
		updateurl = intent.getStringExtra("url");
		updateFile = new File(Environment.getExternalStorageDirectory(), intent.getStringExtra("file"));
		
		updateNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
		updateNotification = new Notification();
		
		updateIntent = new Intent(this, MainActivity.class);
		updatePendingIntent = PendingIntent.getActivity(this, 0, updateIntent, 0);
		
		updateNotification.icon = android.R.drawable.arrow_down_float;
		updateNotification.tickerText = "开始下载";
		updateNotification.setLatestEventInfo(this, "iZJU校园资讯", "%0", updatePendingIntent);
		
		updateNotificationManager.notify(0, updateNotification);
		
		new Thread(new updateRunnable()).start();
		
		return super.onStartCommand(intent, flags, startId);
	}
	
	private Handler updateHandler = new Handler(){
		@Override
		public void handleMessage(Message msg){
			switch(msg.what){
			case DOWNLOAD_COMPLETE:
				Uri uri = Uri.fromFile(updateFile);
				Intent installIntent = new Intent(Intent.ACTION_VIEW);
				installIntent.setDataAndType(uri, "application/vnd.android.package-archive");
				updatePendingIntent = PendingIntent.getActivity(UpdateService.this, 0, installIntent, 0);
				
				updateNotification.defaults = Notification.DEFAULT_SOUND;
				updateNotification.setLatestEventInfo(UpdateService.this, "iZJU校园资讯", "下载完成，点击安装...", updatePendingIntent);
				updateNotificationManager.notify(0, updateNotification);
				
				stopService(updateIntent);
				break;
			case DOWNLOAD_FAIL:
				updateNotification.setLatestEventInfo(UpdateService.this, "iZJU校园资讯", "下载失败", updatePendingIntent);
				updateNotificationManager.notify(0, updateNotification);
				stopService(updateIntent);
				break;
			default:
				stopService(updateIntent);
			}
		}
	};
	
	private class updateRunnable implements Runnable {
		Message message = updateHandler.obtainMessage();
		@Override
		public void run() {
			message.what = DOWNLOAD_COMPLETE;
			
			long downloadSize;
			try {
				downloadSize = downloadUpdateFile(updateurl, updateFile);
				if(downloadSize > 0){
					message.what = DOWNLOAD_COMPLETE;
				} else {
					message.what = DOWNLOAD_FAIL;
				}
			} catch (Exception e) {
				message.what = DOWNLOAD_FAIL;
			} finally {
				updateHandler.sendMessage(message);
			}
		}
		
	}
	
	private long downloadUpdateFile(String apnurl, File saveFile) throws Exception {
		int downloadCount = 0;
		long totalSize = 0;
		int updateTotalsize = 0;
		
		HttpURLConnection httpConnection = null;
		InputStream is = null;
		FileOutputStream fos = null;
		
		try {
			URL url = new URL(apnurl);
			httpConnection = (HttpURLConnection) url.openConnection();
			if(httpConnection.getResponseCode() == 404){
				return 0L;
			}
			updateTotalsize = httpConnection.getContentLength();
			
			is = httpConnection.getInputStream();
			fos = new FileOutputStream(saveFile, false);
			byte buffer[] = new byte[8192];
			int readsize = 0;
			while((readsize = is.read(buffer)) > 0){
				fos.write(buffer, 0, readsize);
				totalSize += readsize;
				
				if((int)(totalSize*100/updateTotalsize)-10>downloadCount){
					downloadCount += 10;
					updateNotification.setLatestEventInfo(UpdateService.this, "正在下载", 
							(int)totalSize*100/updateTotalsize+"%", updatePendingIntent);
					updateNotificationManager.notify(0, updateNotification);
				}
			}
			
		} finally {
			if(httpConnection != null){
				httpConnection.disconnect();
			}
			if(is != null){
				is.close();
			}
			if(fos != null){
				fos.close();
			}
		}
		return totalSize;
	}

}
