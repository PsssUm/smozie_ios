package com.psssum.upmob

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.animation.DecelerateInterpolator
import android.webkit.*
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
//import br.com.onimur.handlepathoz.HandlePathOz
//import br.com.onimur.handlepathoz.HandlePathOzListener
//import br.com.onimur.handlepathoz.model.PathOz
import com.google.android.play.core.review.ReviewManagerFactory
import java.io.File
import java.io.FileNotFoundException


class UpmobWebviewActivity : AppCompatActivity() {
    private lateinit var webInterFace : WebAppInterface
    private val SELECT_PHOTO = 1
//    private lateinit var handlePathOz: HandlePathOz
    private lateinit var webview : WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        setAnimation()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_webview_layout)
        val token = intent.getStringExtra(Constants.TOKEN)
        val device_id = intent.getStringExtra(Constants.DEVICE_ID)
        val api_key = intent.getStringExtra(Constants.API_KEY)
        val uniq_user_id = intent.getStringExtra(Constants.USER_ID)
        webview = findViewById<WebView>(R.id.webview)
        //webview.loadUrl("https://app-coins.ru/tasks?device_id=gsagasdag23g2gewag&token_google=eyJhbGciOiJSUzI1NiIsImtpZCI6ImNiNDA0MzgzODQ0YjQ2MzEyNzY5YmI5MjllY2VjNTdkMGFkOGUzYmIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI3OTIzNjc1MDQyMjctOTY1YWU0b2VlMXBmOWxqNWhnMmxmb2RqdTZlZGpnZzUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI3OTIzNjc1MDQyMjctMjYzNWhtaDZxZjQ0NmZpNGJrcGxscDQ0YjNmMm9waTAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDAwOTkxOTk4Mzg0NTczMTk2OTUiLCJlbWFpbCI6ImJ1bXMzMjMwQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoi0JLQsNGB0LjQu9C40Lkg0J_QtdGC0YDQvtCyIiwicGljdHVyZSI6Imh0dHBzOi8vbGg1Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tbmJYeHI2THJhNk0vQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQUtGMDVuQjlod2k4NHRNbWgzXzNTM1FPMk1TazNVODJIUS9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoi0JLQsNGB0LjQu9C40LkiLCJmYW1pbHlfbmFtZSI6ItCf0LXRgtGA0L7QsiIsImxvY2FsZSI6InJ1IiwiaWF0IjoxNTg0MDIxNjEwLCJleHAiOjE1ODQwMjUyMTB9.TRaTRz6NUKyfkNhTs6kWoeGSw3-5uh1Lke6WYT4JNDZnrXN4ylsyV8IOh6zSZQrqTtejdUOImITS19qV3IZ4clmttcb8pV90GSOiOGl86ohvtC3zKDdU_4wJo5xwnv2gywCIEi-SCKyHMzSrP9NMnUIHWVLyWqJKvaUFi5BQWoCAd5BiUc4pGlOfbIaN7vxpZsB4gS6BQj_u0XgDL8bsdvLLVL1fCOaQ-Qky_fxn6q-XiEQoYQEHrATW1WsrblJkQJsjmhzv4mYjv-UB19rdenijPKcK_sGgUxbPIe7RK7T5OwXm1e7VZamBYUuh4YiPdfanel_z8LOgvgrjUUCTxw")
        webview.loadUrl("https://app-coins.ru/tasks?device_id=$device_id&token_google=$token&api_key=$api_key&uniq_user_id=$uniq_user_id&testReactJS=1&bundle=${applicationContext.packageName}&webview_fits=true")
        val webSettings: WebSettings = webview.getSettings()
        webSettings.javaScriptEnabled = true
        webSettings.domStorageEnabled = true

        webview.webViewClient = MyWebViewClient()
        webInterFace = WebAppInterface(this)
        webview.addJavascriptInterface(webInterFace, "Android")
        webSettings.javaScriptCanOpenWindowsAutomatically = false
//        handlePathOz = HandlePathOz(this, object : HandlePathOzListener.SingleUri{
//            override fun onRequestHandlePathOz(pathOz: PathOz, tr: Throwable?) {
//                val file = File(pathOz.path)
//                val value: String = Base64.encodeToString(file.readBytes(), Base64.DEFAULT)
//                runOnUiThread {
//                    webview.loadUrl("javascript:handleImage('data:image/png;base64,${value}')")
//                }
//            }
//        })

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SELECT_PHOTO) {
            try {
                val imageUri: Uri? = data?.data
                imageUri?.let {
                    //webview.loadUrl("javascript:onResume()")
                    //handlePathOz.getRealPath(imageUri)
                }

            } catch (e: FileNotFoundException) {
                e.printStackTrace()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        webInterFace.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
    class WebAppInterface internal constructor(c: Activity) {
        var mContext: Activity
        private val READ_STORAGE_PERMISSION_REQUEST_CODE = 3

        fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<out String>,
            grantResults: IntArray
        ){
            when (requestCode) {
                READ_STORAGE_PERMISSION_REQUEST_CODE -> {
                    // If request is cancelled, the result arrays are empty.
                    if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                        pickPhoto()
                    }
                    return
                } else -> {
                    // Ignore all other requests.
                }
            }
        }
        @JavascriptInterface
        fun checkInstalledNew(packagename: String): Boolean {
            return mContext.packageManager!!.getLaunchIntentForPackage(packagename) != null
        }
        @JavascriptInterface
        fun showToast(toast: String) {
            Toast.makeText(mContext, toast, Toast.LENGTH_SHORT).show()
        }
        @JavascriptInterface
        fun isAppInstalled(packagename: String): Boolean {
            try {
                mContext.packageManager.getPackageInfo(packagename, 0)
                return true
            } catch (e: Exception) {
                return false
            }
        }
        @JavascriptInterface
        fun openUrl(url: String){

            Log.d("mainActivty", "url =" + url)
            val intent = Intent("android.intent.action.VIEW", Uri.parse(url))
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            mContext.startActivity(intent)
        }
        @JavascriptInterface
        fun openApp(packagename: String) {
            try {
                val i = mContext.packageManager!!.getLaunchIntentForPackage(packagename)
                mContext.startActivity(i)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        @JavascriptInterface
        fun openAppWithParams(packagename: String, google_user_id : String, order_id : String) {
            try {
                val i = mContext.packageManager!!.getLaunchIntentForPackage(packagename)
                i!!.putExtra("google_user_id", google_user_id)
                i!!.putExtra("order_id", order_id)
                i.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                mContext.startActivity(i)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        @JavascriptInterface
        fun copyId(id: String, text: String){
            val clipboard = mContext.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("", id)
            clipboard.setPrimaryClip(clip)
            Toast.makeText(mContext, text, Toast.LENGTH_SHORT).show()
        }
        @JavascriptInterface
        fun registrationFailed(desc: String){
            if (Constants.onFailListener != null){
                Constants.onFailListener!!.onError(desc)
                mContext.finish()
            }
        }
        @JavascriptInterface
        fun finish(){
            mContext.finish()
        }
        @JavascriptInterface
        fun showReviewDialog() {
            if (!isRated(mContext)) {
                setRated(mContext)
                val manager = ReviewManagerFactory.create(mContext)
                //val manager = FakeReviewManager(requireContext()) //TEST MODE!!!
                val request = manager.requestReviewFlow()
                request.addOnCompleteListener { r ->
                    if (r.isSuccessful) {
                        val reviewInfo = r.result
                        val flow = manager.launchReviewFlow(mContext, reviewInfo)
                        flow.addOnCompleteListener { _ ->

                        }
                    }
                }
            }
        }
        private val IS_RATE = "IS_RATE"
        fun isRated(ctx: Context?): Boolean {
            val sPref = PreferenceManager
                .getDefaultSharedPreferences(ctx)
            return sPref.getBoolean(IS_RATE, false)
        }

        fun setRated(ctx: Context?) {
            val sPref = PreferenceManager
                .getDefaultSharedPreferences(ctx)
            val ed = sPref.edit()
            ed.putBoolean(IS_RATE, true)
            ed.apply()
        }
        @JavascriptInterface
        fun getStringPref(key : String): String {
            val sPref = PreferenceManager
                .getDefaultSharedPreferences(mContext)
            return sPref.getString(key, "").toString()
        }
        @JavascriptInterface
        fun setStringPref(text: String, key : String) {
            val sPref = PreferenceManager
                .getDefaultSharedPreferences(mContext)
            val ed = sPref.edit()
            ed.putString(key, text)
            ed.apply()
        }
        @JavascriptInterface
        fun checkPickPhoto(){
            if (checkPermissionForReadExtertalStorage()) {
                pickPhoto()
            } else {
                requestPermissionForReadExtertalStorage()
            }
        }
        private fun checkPermissionForReadExtertalStorage(): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val result: Int = mContext.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                val resultWrite: Int = mContext.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                return result == PackageManager.PERMISSION_GRANTED && resultWrite == PackageManager.PERMISSION_GRANTED
            }
            return false
        }
        private fun pickPhoto() {
            val photoPickerIntent = Intent(Intent.ACTION_PICK)
            photoPickerIntent.type = "image/*"
            photoPickerIntent.putExtra(Intent.EXTRA_LOCAL_ONLY, true)
            mContext.startActivityForResult(photoPickerIntent, 1)
        }
        @SuppressLint("NewApi")
        @Throws(Exception::class)
        fun requestPermissionForReadExtertalStorage() {
            try {
                mContext.requestPermissions(
                    arrayOf<String>(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    READ_STORAGE_PERMISSION_REQUEST_CODE
                )
            } catch (e: Exception) {
                e.printStackTrace()
                throw e
            }
        }
        init {
            mContext = c


        }
    }


    override fun onResume() {
        super.onResume()
        webview.loadUrl("javascript:onResume()")
    }
    private class MyWebViewClient : WebViewClient() {
        //HERE IS THE MAIN CHANGE.
        override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
            return false
        }
    }
    private fun setAnimation(){

        if (Build.VERSION.SDK_INT > 20) {
            val fadeAnimaton = android.transition.Fade()
            fadeAnimaton.setDuration(200)
            fadeAnimaton.setInterpolator(DecelerateInterpolator())
            getWindow().setExitTransition(fadeAnimaton)
            getWindow().setEnterTransition(fadeAnimaton)
        }
    }
}
