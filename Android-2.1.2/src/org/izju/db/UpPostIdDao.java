package org.izju.db;

import java.util.ArrayList;
import java.util.List;

import org.izju.common.Constants;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class UpPostIdDao {

	private DataBaseOpenHelper dbOpenHelper;

	public UpPostIdDao(Context context) {
		dbOpenHelper = new DataBaseOpenHelper(context);
	}

	public void save(String postId) {
		SQLiteDatabase database = dbOpenHelper.getWritableDatabase();
		ContentValues contentValues = new ContentValues();
		contentValues.put(Constants.TABLE_COLUMN_POST_ID, postId);
		database.insert(Constants.TABLE_NAME_UP_POST_ID, null, contentValues);
		database.close();
	}

	public void update(String postId) {
	}

	public boolean find(String postId) {
		SQLiteDatabase database = dbOpenHelper.getReadableDatabase();
		Cursor cursor = database.query(
				Constants.TABLE_NAME_UP_POST_ID, 
				new String[] { Constants.TABLE_KEY_UP_POST_ID, Constants.TABLE_COLUMN_POST_ID}, 
				Constants.TABLE_COLUMN_POST_ID + "=?",
				new String[] {postId}, 
				null, 
				null, 
				null);
		if (cursor.moveToNext()) {
			database.close();
			return true;
		}
		database.close();
		return false;
	}

	public List<String> getScrollData(int startResult, int maxResult) {
		List<String> postIdList = new ArrayList<String>();
		SQLiteDatabase database = dbOpenHelper.getReadableDatabase();
		
		Cursor cursor = database.query(
				Constants.TABLE_NAME_UP_POST_ID, 
				new String[] { Constants.TABLE_KEY_UP_POST_ID, Constants.TABLE_COLUMN_POST_ID}, 
				null, null, null, null, null,
				startResult + "," + maxResult);

		while (cursor.moveToNext()) {
			postIdList.add(cursor.getString(1));
		}
		
		database.close();
		return postIdList;
	}

	public long getCount() {
		SQLiteDatabase database = dbOpenHelper.getReadableDatabase();
		Cursor cursor = database.query(Constants.TABLE_NAME_UP_POST_ID, new String[] { "count(*)" },
				null, null, null, null, null);
		
		if (cursor.moveToNext()) {
			long res = cursor.getLong(0);
			database.close();
			return res;
		}
		return 0;
	}

}
