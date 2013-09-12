package org.izju.user;

import org.izju.R;

import android.content.Context;

public class User {
	private String id;
	private String name;
	
	public User(String name) {
		this.name = name;
	}

	public User(String id, String name) {
		this.id = id;
		this.name = name;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public static User getCurrentUser(Context context) {
		return new User(context.getString(R.string.user_name));
	}
}
