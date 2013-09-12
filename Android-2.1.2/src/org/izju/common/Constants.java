package org.izju.common;

public class Constants {

	public static final String SHARED_PREFERENCE_NAME = "IZJU_PREFERENCE";
	public static final String PREF_KEY_FIRST_USE = "first_use";
	public static final String PREF_KEY_VERSION_CODE = "version_code";
	public static final String PREF_KEY_DEFAULT_USER_NO = "default_user_no";
	public static final String PREF_KEY_USERNAME = "wifi_username";
	public static final String PREF_KEY_PASSWORD = "wifi_password";
	public static final String PREF_KEY_LOGIN_ON_CONNECT = "login_on_connect_";
	public static final String PREF_KEY_LOGIN_ON_OFFLINE = "login_on_offline_";
	
	// from 8:00 AM to 10:00 PM
	public static final int DEFAULT_PUSH_TIME = 0x0816;
	
	// Extra names
	public static final String EXTRA_NAME_ARTICLE_ID = "ARTICLE_ID";
	public static final String EXTRA_NAME_POST_NUM = "TOTAL_POST_NUM";
	public static final String EXTRA_NAME_NOTIFCATION_TITLE = "ntf_title";
	public static final String EXTRA_NAME_NOTIFCATION_CONTENT = "ntf_content";
	
	// Parse Application ID and Client Key
	public static final String PARSE_APPLICATION_ID 
								= "";
	public static final String PARSE_CLIENT_KEY
								= "";
	
	// ParseObject Names
	public static final String PARSE_NAME_COMMENT = "CommentsOfInfo";
	
	// ParseObject Keys
	public static final String PARSE_KEY_OBJECT_ID = "objectId";
	public static final String PARSE_KEY_ARTICLE_ID = "articleId";
	public static final String PARSE_KEY_CONTENT = "content";
	public static final String PARSE_KEY_REF_POST = "referencePost";
	public static final String PARSE_KEY_UP_COUNT = "upCount";
	public static final String PARSE_KEY_USER_NAME = "userName";
	public static final String PARSE_KEY_UPDATED_AT = "updatedAt";
	

	// the text size of post operation view
	public static final float OPERATION_VIEW_TEXT_SIZE = 50;

	// zju mobile library url
	public static final String ZJU_MOBILE_LIB_URL = "http://zju.ddlib.com/ddlib/";
	
	public static final long REFRESH_INTERVAL = 5000;

	public static final long POPUP_TIME = 1000;
	
	
	public static final int REQUEST_NUM_HOT_POST = 3;
	public static final int REQUEST_NUM_LATEST_POST = 25;

	public static final long HIGH_LIGHT_TIME = 2000;
	
	// persistence constants
	public static final String DB_NAME = "iZJU-persistence";
	
	// up post table
	public static final String TABLE_NAME_UP_POST_ID = "up_post";
	public static final String TABLE_KEY_UP_POST_ID = "up_post_id";
	public static final String TABLE_COLUMN_POST_ID = "post_id";
	
	// wifi account table
	public static final String TABLE_NAME_WIFI_ACCOUNT = "wifi_account";
	public static final String TABLE_KEY_WIFI_ACCOUNT_ID = "account_id";
	public static final String TABLE_COLUMN_USERNAME = "username";
	public static final String TABLE_COLUMN_PASSWORD = "password";

	public static final String PUSH_KEY_CHANNEL = "channel";
	public static final String PUSH_KEY_ARITICLE_ID = "ArticleID";
	
	public static final String CHANNEL_NAME_ACTIVITY = "ActivityCampus";
	public static final String CHANNEL_NAME_EXCHANGE = "Exchange";

	public static final String MAIL_TO_EMAIL = "mailto:contact@izju.org";
	public static final String OFFICIAL_NET = "http://www.izju.org";
	public static final String NETWORK_INACCESSIBLE = "network_inaccessible";
	public static final String NETWORK_ACCESSIBLE = "network_accessible";
	
	// the number of supported wifi account
	public static final int SUPPORTED_WIFI_ACCOUNT_NUM = 3;
}
