package org.izju.activity;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.message.BasicNameValuePair;
import org.izju.R;
import org.izju.utility.DataUtility;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;
import android.widget.Toast;

import cn.jpush.android.api.JPushInterface;

import com.baidu.mobstat.StatActivity;

public class YijianActivity extends StatActivity {
    private final String TAG = "org.izju.activity.BaikeActivity";
    private final String URL = "http://www.izju.org/data/suggest.php";
    
    @Override
    public void onStart() {
        super.onStart();
        JPushInterface.activityStarted(this);
    }
     
    @Override
    public void onStop() {
        super.onStop();
        JPushInterface.activityStopped(this);
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.yijian);
        
        //initialize back button
        Button bakBtn = (Button) findViewById(R.id.top_bak_btn);
        bakBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                back();
            }
        });
        
        //initialize the view
        TextView titleText = (TextView) findViewById(R.id.top_title_txt);
        titleText.setText(R.string.yijian);
        
        EditText email = (EditText) findViewById(R.id.yijian_email_txt);
        email.setOnEditorActionListener(new OnEditorActionListener() {
            
            @Override
            public boolean onEditorAction(TextView arg0, int arg1, KeyEvent arg2) {
                if (arg1 == 4) {
                    new Thread(sendder).start();
                }
                return true;
            }
        });
        
        Button sendBtn = (Button) findViewById(R.id.yijian_send_btn);
        sendBtn.setOnClickListener(new OnClickListener() {
            
            @Override
            public void onClick(View arg0) {
                new Thread(sendder).start();
            }
        });
        
        
    }
    
    @SuppressLint("HandlerLeak")
    private Handler handler = new Handler() {
        ProgressDialog dialog;

        @Override
        public void dispatchMessage(Message msg) {
            switch (msg.what) {
            case 0:
                dialog = ProgressDialog.show(YijianActivity.this, "Sending...", "Please wait...", true, true);
                dialog.setOnCancelListener(new OnCancelListener() {
                    
                    @Override
                    public void onCancel(DialogInterface dialog) {
                        dialog.dismiss();
                        YijianActivity.this.finish();
                    }
                });
                break;
                
            case 1:
                dialog.dismiss();
                Toast.makeText(YijianActivity.this, "感谢您的建议！我们会做得更好！", Toast.LENGTH_LONG).show();
                break;
            
            case -1:
                dialog.dismiss();
                Toast.makeText(YijianActivity.this, "亲，网络故障，暂时无法提交", Toast.LENGTH_LONG).show();
                break;
            }
        }
    };
    
    private Runnable sendder = new Runnable() {

        @Override
        public void run() {
            handler.sendEmptyMessage(0);
            EditText suggest = (EditText) findViewById(R.id.yijian_suggest_txt);
            EditText email = (EditText) findViewById(R.id.yijian_email_txt);
            
            List<BasicNameValuePair> params = new ArrayList<BasicNameValuePair>();
            params.add(new BasicNameValuePair("suggest", suggest.getText().toString()));
            params.add(new BasicNameValuePair("email", email.getText().toString()));
            
            String result = DataUtility.sendNetData(YijianActivity.this, URL, params);
            Log.d(TAG, result+"");
            if (result == null) {
                handler.sendEmptyMessage(-1);
            } else {
                handler.sendEmptyMessage(1);
            }
        }
        
    };
    
    private void back(){
        super.onBackPressed();
    }
}
