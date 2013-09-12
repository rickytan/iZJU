package org.izju.db;

import org.izju.common.Constants;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

public class DataBaseOpenHelper extends SQLiteOpenHelper {
	private static String dbname = Constants.DB_NAME;
	private static int version = 2;
	
	public final static int TABLE_NAME_UP_POST_ID = 0;
	public final static int TABLE_NAME_WIFI_ACCOUNT = 1;
	
	public DataBaseOpenHelper(Context context) {
		super(context, dbname, null, version);
	}

	public DataBaseOpenHelper(Context context, String name,
			CursorFactory factory, int version) {
		super(context, name, factory, version);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL("CREATE TABLE IF NOT EXISTS " + 
				Constants.TABLE_NAME_UP_POST_ID + " (" +
				Constants.TABLE_KEY_UP_POST_ID +
					" integer primary key autoincrement, " +
				Constants.TABLE_COLUMN_POST_ID + " varchar(40))"
				);
		db.execSQL("CREATE TABLE IF NOT EXISTS " + 
				Constants.TABLE_NAME_WIFI_ACCOUNT + " (" +
				Constants.TABLE_KEY_WIFI_ACCOUNT_ID +
					" integer primary key autoincrement, " +
				Constants.TABLE_COLUMN_USERNAME + " varchar(20)," +
				Constants.TABLE_COLUMN_PASSWORD + " varchar(20))"
				);

	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int arg1, int arg2) {
		db.execSQL("DROP TABLE IF EXISTS " + Constants.TABLE_NAME_UP_POST_ID);
		db.execSQL("DROP TABLE IF EXISTS " + Constants.TABLE_NAME_WIFI_ACCOUNT);
		onCreate(db);
	}
}
