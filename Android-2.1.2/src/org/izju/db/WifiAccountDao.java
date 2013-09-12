package org.izju.db;

import java.util.ArrayList;
import java.util.List;

import org.izju.common.Constants;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class WifiAccountDao {

	private DataBaseOpenHelper dbOpenHelper;

	public WifiAccountDao(Context context) {
		dbOpenHelper = new DataBaseOpenHelper(context);
	}

	public void save(WifiAccount account) {
		SQLiteDatabase database = dbOpenHelper.getWritableDatabase();
		ContentValues contentValues = new ContentValues();
		contentValues.put(Constants.TABLE_COLUMN_USERNAME, 
				account.getUsername());
		contentValues.put(Constants.TABLE_COLUMN_PASSWORD, 
				account.getPassword());
		database.insert(Constants.TABLE_NAME_WIFI_ACCOUNT, null, contentValues);
		database.close();
	}

	public void update(WifiAccount account) {
		SQLiteDatabase database = dbOpenHelper.getWritableDatabase();
		ContentValues contentValues = new ContentValues();
		contentValues.put(Constants.TABLE_COLUMN_USERNAME, 
				account.getUsername());
		contentValues.put(Constants.TABLE_COLUMN_PASSWORD, 
				account.getPassword());
		database.update(Constants.TABLE_NAME_WIFI_ACCOUNT, contentValues, 
				Constants.TABLE_KEY_WIFI_ACCOUNT_ID + "=" + account.getId(), 
				null);
	}
	
	public void delete(WifiAccount account) {
		SQLiteDatabase database = dbOpenHelper.getWritableDatabase();
		database.delete(Constants.TABLE_NAME_WIFI_ACCOUNT, 
				Constants.TABLE_KEY_WIFI_ACCOUNT_ID + "=" + account.getId(), 
				null);
	}

	public List<WifiAccount> getScrollData(int startResult, int maxResult) {
		List<WifiAccount> accountList = new ArrayList<WifiAccount>();
		SQLiteDatabase database = dbOpenHelper.getReadableDatabase();
		
		Cursor cursor = database.query(
				Constants.TABLE_NAME_WIFI_ACCOUNT, 
				new String[] { 
						Constants.TABLE_KEY_WIFI_ACCOUNT_ID, 
						Constants.TABLE_COLUMN_USERNAME,
						Constants.TABLE_COLUMN_PASSWORD
						}, 
				null, null, null, null, null,
				startResult + "," + maxResult);

		while (cursor.moveToNext()) {
			accountList.add(
					new WifiAccount(cursor.getString(0), cursor.getString(1), 
								    cursor.getString(2)));
		}
		
		database.close();
		return accountList;
	}
	
	public long getCount() {
		SQLiteDatabase database = dbOpenHelper.getReadableDatabase();
		Cursor cursor = database.query(Constants.TABLE_NAME_WIFI_ACCOUNT, 
				new String[] { "count(*)" },
				null, null, null, null, null);
		
		if (cursor.moveToNext()) {
			long res = cursor.getLong(0);
			database.close();
			return res;
		}
		return 0;
	}
}
