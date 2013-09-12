package org.izju.parse;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.izju.common.Constants;
import org.izju.post.Post;
import org.izju.user.User;

import android.content.Context;
import android.util.Log;

import com.parse.FindCallback;
import com.parse.Parse;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

public class ParseUtil {
	
	private static final String TAG = "ParseUtil";

	public static void init(Context context) {
		
	    Parse.initialize(context, Constants.PARSE_APPLICATION_ID, 
	    		         Constants.PARSE_CLIENT_KEY);

		ParseUser.enableAutomaticUser();
		
		ParseACL defaultACL = new ParseACL();
		defaultACL.setPublicReadAccess(true);
		defaultACL.setPublicWriteAccess(true);
		ParseACL.setDefaultACL(defaultACL, true);
	}
	
	public int getPostNum(String id) {
		return 0;
	}
	
	public List<Post> getPost(String id) {
		return null;
	}
	
	public boolean sendPost(Post post) {
		return true;
	}

	public static Post parsePost(ParseObject po) {
		String postId = po.getObjectId();
		String articleId = po.getString(Constants.PARSE_KEY_ARTICLE_ID);
		String postContent = po.getString(Constants.PARSE_KEY_CONTENT);
		Date postTime = po.getUpdatedAt();
		String userName = po.getString(Constants.PARSE_KEY_USER_NAME);
		int upCount = po.getInt(Constants.PARSE_KEY_UP_COUNT);
		
		Post post = new Post();
		post.setId(postId);
		post.setArticleId(articleId);
		post.setPostContent(postContent);
		post.setPoster(new User(userName));
		post.setPostTime(postTime);
		post.setUpCount(upCount);
		
		String refPostData = po.getString(Constants.PARSE_KEY_REF_POST);
		Log.d(TAG, "reference post data: " + refPostData);
		if (null != refPostData) {
			// get the reference poster and reference post content
			Pattern p = Pattern.compile("\\[(.+?)\\]([\\s\\S]+)");
			Matcher m = p.matcher(refPostData);
			if (m.find()) {
				Post refPost = new Post(new User(m.group(1)), m.group(2));
				post.setReference(refPost);
			}
		}
		
		Log.d(TAG, post.dump());
		return post;
	}
	
	public static ParseObject obtainParseObject(Post post, String refDescription) {
		ParseObject parseObject = new ParseObject(Constants.PARSE_NAME_COMMENT);
		parseObject.put(Constants.PARSE_KEY_ARTICLE_ID, post.getArticleId());
		parseObject.put(Constants.PARSE_KEY_CONTENT, post.getPostContent());
		parseObject.put(Constants.PARSE_KEY_USER_NAME, post.getPoster().getName());
		
		Post referencePost = post.getReference();
		if (null != referencePost) {
			String refPostData = "[" + referencePost.getPoster().getName() + " " 
							     + refDescription + "]" + referencePost.getPostContent();
			parseObject.put(Constants.PARSE_KEY_REF_POST, refPostData);
		}
		return parseObject;
	}
	
	/**
	 * the 'upCount' member of post is counter-type data. 
	 * User ParseObject.increment() to update the value.
	 * @param post
	 */
	public static void updateUpCount(Post post) {
		ParseQuery query = new ParseQuery(Constants.PARSE_NAME_COMMENT);
		query.whereEqualTo(Constants.PARSE_KEY_OBJECT_ID, post.getId());
		query.findInBackground(new FindCallback() {
		    public void done(List<ParseObject> postList, ParseException e) {
		        if (e == null) {
		            if (1 == postList.size()) {
		            	postList.get(0).increment(Constants.PARSE_KEY_UP_COUNT);
		            	postList.get(0).saveEventually();
		            }
		        } else {
		            Log.d(TAG, "Error: " + e.getMessage());
		        }
		    }
		});
	}

	public static void updatePost(final Post post, final String key) {
		ParseQuery query = new ParseQuery(Constants.PARSE_NAME_COMMENT);
		query.whereEqualTo(Constants.PARSE_KEY_OBJECT_ID, post.getId());
		query.findInBackground(new FindCallback() {
		    public void done(List<ParseObject> postList, ParseException e) {
		        if (e == null) {
		            if (1 == postList.size()) {
		            	postList.get(0).put(key, post.get(key));
		            	postList.get(0).saveEventually();
		            }
		        } else {
		            Log.d(TAG, "Error: " + e.getMessage());
		        }
		    }
		});
	}
	
	public static List<Post> requestHotPosts(String id) {
		Log.d(TAG, "request hot posts");
        ParseQuery query1 = new ParseQuery(Constants.PARSE_NAME_COMMENT);
        query1.whereEqualTo(Constants.PARSE_KEY_ARTICLE_ID, id);
        query1.whereGreaterThan(Constants.PARSE_KEY_UP_COUNT, 0);
        query1.orderByDescending(Constants.PARSE_KEY_UP_COUNT);
        query1.addDescendingOrder(Constants.PARSE_KEY_UPDATED_AT);
        query1.setLimit(Constants.REQUEST_NUM_HOT_POST);
        
		try {
			List<ParseObject> parseObjectList = query1.find();
	        if (null != parseObjectList) {
	        	List<Post> hotPosts = new ArrayList<Post>();
	        	for (ParseObject po : parseObjectList) {
	        		hotPosts.add(ParseUtil.parsePost(po));
	        	}
	        	return hotPosts;
	        }
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public static List<Post> requestLatestPosts(String id) {
		Log.d(TAG, "request latest posts");
        ParseQuery query2 = new ParseQuery(Constants.PARSE_NAME_COMMENT);
        query2.whereEqualTo(Constants.PARSE_KEY_ARTICLE_ID, id);
        query2.orderByDescending(Constants.PARSE_KEY_UPDATED_AT);
        query2.setLimit(Constants.REQUEST_NUM_LATEST_POST);
        
		try {
			List<ParseObject> parseObjectList = query2.find();
	        if (null != parseObjectList) {
	        	List<Post> latestPosts = new ArrayList<Post>();
	        	for (ParseObject po : parseObjectList) {
	        		latestPosts.add(ParseUtil.parsePost(po));
	        	}
	        	return latestPosts;
	        }
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public static int queryPostCount(String id) {
        ParseQuery query = new ParseQuery(Constants.PARSE_NAME_COMMENT);
        query.whereEqualTo(Constants.PARSE_KEY_ARTICLE_ID, id);
        try {
			return query.count();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return -1;
	}
}
