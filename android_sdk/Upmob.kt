package com.psssum.upmob

import android.app.Activity
import android.app.ActivityOptions
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

class Upmob(activty: Activity, token : String, apiKey : String, userId : String = "",onFailListener: OnFailListener) {
    init {
        Constants.onFailListener = onFailListener
        val intent = Intent(activty, UpmobWebviewActivity::class.java)
        val android_id = Settings.Secure.getString(activty.getContentResolver(),
            Settings.Secure.ANDROID_ID);
        intent.putExtra(Constants.TOKEN, token)
        intent.putExtra(Constants.DEVICE_ID, android_id)
        intent.putExtra(Constants.API_KEY, apiKey)
        intent.putExtra(Constants.USER_ID, userId)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
        if (Build.VERSION.SDK_INT > 20) {
            val options =
                ActivityOptions.makeSceneTransitionAnimation(activty)
            activty.startActivity(intent, options.toBundle())
        } else {
            activty.startActivity(intent)
        }

    }

}