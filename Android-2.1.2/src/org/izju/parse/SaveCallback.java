package org.izju.parse;

import org.izju.post.Post;

public interface SaveCallback {
	/**
	 * 
	 * @param e
	 * @param post the post that was sent successfully just
	 */
	public void done(Exception e, Post post);
}
