package org.izju.post;

import java.util.Date;

import org.izju.common.Constants;
import org.izju.user.User;

public class Post {
	
	private String id;
	private String articleId;
	private User poster;
	private String postContent;
	private Date postTime;
	private int upCount;
	private Post reference;
	
	public Post(User poster, String postContent) {
		this.poster = poster;
		this.postContent = postContent;
	}
	
	public Post() {
		
	}

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getArticleId() {
		return articleId;
	}

	public void setArticleId(String articleId) {
		this.articleId = articleId;
	}

	public User getPoster() {
		return poster;
	}
	public void setPoster(User poster) {
		this.poster = poster;
	}
	public String getPostContent() {
		return postContent;
	}
	public void setPostContent(String postContent) {
		this.postContent = postContent;
	}
	public Date getPostTime() {
		return postTime;
	}
	public void setPostTime(Date postTime) {
		this.postTime = postTime;
	}
	public int getUpCount() {
		return upCount;
	}
	public void setUpCount(int upNum) {
		this.upCount = upNum;
	}
	public Post getReference() {
		return reference;
	}
	public void setReference(Post reference) {
		this.reference = reference;
	}
	
	public Object get(String key) {
		if (key.equals(Constants.PARSE_KEY_UP_COUNT)) {
			return getUpCount();
		}
		if (key.equals(Constants.PARSE_KEY_CONTENT)) {
			return getPostContent();
		}
		return null;
	}

	public String dump() {
		return "Post [id=" + id + ", articleId=" + articleId + ", poster="
				+ poster + ", postContent=" + postContent + ", postTime="
				+ postTime + ", upCount=" + upCount + ", reference="
				+ reference + "]";
	}
	
}
