package org.izju.common;

import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

/**
 * Request focus when the current view is touched.
 * @author LvtonSmith
 *
 */
public class RequestFocusListener implements OnTouchListener {

	@Override
	public boolean onTouch(View v, MotionEvent arg1) {
		v.requestFocus();
		return false;
	}

}
