package com.noaisu.classiclauncher

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.MotionEvent
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.graphics.createBitmap
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.io.OutputStream


class MainActivity : FlutterActivity() {
    private val appMethodChannel = "com.noaisu.classicLauncher/app"
    private val inputEventChannel = "com.noaisu.classicLauncher/input"
    private val appChangeEventChannel = "com.noaisu.classicLauncher/appChange"

    private var eventSink: EventChannel.EventSink? = null

    private var appEventSink: EventChannel.EventSink? = null




    private var methodResult: MethodChannel.Result? = null
    private var SAFUri: String? = ""


    private val packageReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: android.content.Context?, intent: Intent?) {
            Log.d("PackageReceiver", "onReceive fired: ${intent?.action} ${intent?.data}")
            val action = intent?.action ?: return
            val packageName = intent.data?.schemeSpecificPart ?: return
            val status = when (action) {
                Intent.ACTION_PACKAGE_ADDED -> "added"
                Intent.ACTION_PACKAGE_REMOVED -> "removed"
                Intent.ACTION_PACKAGE_REPLACED -> "replaced"
                else -> return
            }

            val appName = try {
                val pm = context?.packageManager ?: return
                val appInfo = pm.getApplicationInfo(packageName, 0)
                pm.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                packageName
            }



            CoroutineScope(Dispatchers.Main).launch {
                appEventSink?.success(mapOf(
                    "packageName" to packageName,
                    "title" to appName,
                    "status" to status
                ))
            }
        }
    }

    override fun getRenderMode() = RenderMode.surface
    override fun getTransparencyMode() = TransparencyMode.transparent
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addDataScheme("package")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(packageReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(packageReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try { unregisterReceiver(packageReceiver) } catch (_: Exception) {}
    }


  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appMethodChannel).setMethodCallHandler {
      call, result ->
      when(call.method){
        "getApps" -> {
          CoroutineScope(Dispatchers.Main).launch {
            val apps = getAppList(applicationContext)
            result.success(apps)
          }}

          "getAppInfo" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  val packageName: String? = call.argument("packageName") as String?
                  if(packageName == null){
                      result.success(null)
                      return@launch
                  }
                  val apps = getAppList(applicationContext)
                  result.success(apps)
              }}

          "getAppIcon" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  val packageName: String? = call.argument("packageName") as String?
                  if(packageName == null){
                      result.success(null)
                      return@launch
                  }
                  result.success(getAppIcon(applicationContext, packageName))
              }}

          "launchApp" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  val packageName: String? = call.argument("packageName") as String?
                  if(packageName == null){
                      result.success(false)
                      return@launch
                  }


                 val success: Boolean = launchApp(packageName, applicationContext)
                  result.success(success)
              }}

          "launchMail" -> {
              CoroutineScope(Dispatchers.Main).launch {



                  val success: Boolean = launchMail(applicationContext)
                  result.success(success)
              }}

          "launchCamera" -> {
              CoroutineScope(Dispatchers.Main).launch {



                  val success: Boolean = launchCamera(applicationContext)
                  result.success(success)
              }}

          "getTempDirAccess" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  methodResult = result
              requestTemporaryDirectoryAccess()
              }
          }
          "getFileUri" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  methodResult = result
                  getFileUri()
              }
          }
          "uninstallApp" -> {
              val packageName: String? = call.argument("packageName") as String?
              if(packageName == null){
                  result.success(false)
                  return@setMethodCallHandler
              }

              uninstallApp(packageName)
              result.success(true)
          }

          "writeFile" -> {
              val fileBytes = call.argument<ByteArray>("fileData")
              val fileName = call.argument<String>("fileName")
              val mediaType = call.argument<String>("mediaType")
              val fileExt = call.argument<String>("fileExt")
              val extPathOverride = call.argument<String?>("extPathOverride")

              CoroutineScope(Dispatchers.Main).launch {
              if (fileBytes != null && mediaType != null && fileExt != null && fileName != null) {
                  writeFile(fileBytes, fileName, mediaType, fileExt, extPathOverride)
                  result.success(fileName)
              } else {
                  result.error("INVALID_ARGUMENT", "One or more arguments are null", null)
              }}

          }

          "getFileBytes" -> {
              val uri = call.argument<String>("uri")
              if (uri != null) {
                  CoroutineScope(Dispatchers.Main).launch {
                  result.success(getFileBytesFromUri(uri))}
              } else {
                  result.error("INVALID_ARGUMENT", "URI is null", null)
              }
          }

              "openWallpaperPicker" -> {

                  CoroutineScope(Dispatchers.Main).launch {
                   openWallpaperPicker()
                        result.success(null)}

          }


         /* "getWallpaper" -> {
              CoroutineScope(Dispatchers.Main).launch {
                  val wallpaper = getWallPaper(applicationContext)
                  result.success(wallpaper)
              }}*/

        else -> {
          result.notImplemented()
        }
      }
    }


      EventChannel(flutterEngine.dartExecutor.binaryMessenger, appChangeEventChannel).setStreamHandler(
          object : EventChannel.StreamHandler {
              override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                  appEventSink = events
              }
              override fun onCancel(arguments: Any?) {
                  appEventSink = null
              }
          }
      )

      EventChannel(flutterEngine.dartExecutor.binaryMessenger, inputEventChannel).setStreamHandler(
          object : EventChannel.StreamHandler {
              override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                  eventSink = events
              }

              override fun onCancel(arguments: Any?) {
                  eventSink = null
              }
          }
      )
  }

    private fun getFileUri() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "*/*"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                "text/plain",
                "application/json"
            ))
            flags = Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        }

        startActivityForResult(intent, 1)
    }

     suspend fun openWallpaperPicker() {
         val intent = Intent(Intent.ACTION_SET_WALLPAPER)
         startActivity(intent)
    }

    fun uninstallApp(packageName: String) {
        val intent = Intent(Intent.ACTION_DELETE).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    suspend fun getFileBytesFromUri(uriString: String): ByteArray? {
        val uri = Uri.parse(uriString)
        if (uri == Uri.EMPTY) {
            return null
        }

        try {
            val stream = contentResolver.openInputStream(uri)
            return stream?.buffered()?.use { it.readBytes() }
        } catch (e: IOException) {
            if (e is FileNotFoundException) {
                Log.e("MainActivity", "File not found for URI: $uriString")
            } else {
                Log.e("MainActivity", "Error reading from URI: $uriString", e)
            }
        }

        return null
    }

    suspend fun writeFile(fileBytes: ByteArray, name: String, mediaType: String, fileExt: String, extPathOverride: String?) {
        var fos: OutputStream? = null
        val resolver = contentResolver
        val contentValues = ContentValues()
        var fileUri: Uri? = null
        var thisMediaType: String = mediaType
        if (thisMediaType == "animation") {
            thisMediaType = "image"
        }

        if (!extPathOverride.isNullOrEmpty()) {
            val doc = DocumentFile.fromTreeUri(applicationContext, Uri.parse(extPathOverride))
            if (doc != null && doc.canWrite()) {
                val file = doc.createFile("$thisMediaType/$fileExt", "$name.$fileExt")
                if (file != null) {
                    fos = contentResolver.openOutputStream(file.uri)
                }
            }
        } else {
            if (thisMediaType == "image") {
                contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, "$name.$fileExt")
                contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "$thisMediaType/$fileExt")
                contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/LoliSnatcher/")
                fileUri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            } else {
                contentValues.put(MediaStore.Video.Media.DISPLAY_NAME, "$name.$fileExt")
                contentValues.put(MediaStore.Video.Media.MIME_TYPE, "$thisMediaType/$fileExt")
                contentValues.put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/LoliSnatcher/")
                fileUri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
            }
            if (fileUri != null) {
                fos = resolver.openOutputStream(fileUri)
            }
        }

        if (fos != null) {
            try {
                fos.write(fileBytes)
            } finally {
                fos.close()
            }
        }
    }


    suspend fun launchApp(packageName: String, context: Context): Boolean {

        try {
        val pm = context.packageManager
        val intent = pm.getLaunchIntentForPackage(packageName)

        if (intent == null) {

            return false
        }

        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        applicationContext.startActivity(intent)
        return true } catch (exc: Exception) {}
        return false
    }

    suspend fun launchMail(context: Context): Boolean{
        try {
            val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:"))
            val resolveInfo = context.packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
         val packageName: String? = resolveInfo?.activityInfo?.packageName
           if(packageName == null){
               return false}

            return launchApp(packageName, context)



        } catch (exc: Exception) {

                // handle exception
            }





        return false
    }

    suspend fun requestDirectoryAccess() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            putExtra("pickerMode", "directory")
            flags = Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        }

        startActivityForResult(intent, 1)
    }

    suspend fun requestTemporaryDirectoryAccess() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            putExtra("pickerMode", "directory")
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        }

        startActivityForResult(intent, 1)
    }

    suspend fun launchCamera(context: Context): Boolean{

        try {
            val imageCaptureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)

            val pm = context.packageManager
            val resolveInfo: ResolveInfo = pm.resolveActivity(imageCaptureIntent, 0) ?: throw Exception("Could not resolve activity!")
            val applicationInfo: ApplicationInfo =
                resolveInfo.activityInfo?.applicationInfo ?:
                resolveInfo.serviceInfo?.applicationInfo ?:
                resolveInfo.providerInfo?.applicationInfo ?: throw Exception("ApplicationInfo not found!")

            return launchApp(applicationInfo.packageName, context)
        }
        catch (exc: Exception) {
            // handle exception
        }
    return false
    }



suspend fun getAppList(context: Context): List<Map<String, Any?>> =
    withContext(Dispatchers.IO) {

        val pm: PackageManager = context.packageManager

        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val launchableApps = pm.queryIntentActivities(intent, 0)
            .mapNotNull { resolveInfo ->
                val appInfo = resolveInfo.activityInfo.applicationInfo
                val packageName = appInfo.packageName

                try {
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    mapOf(
                        "packageName" to packageName,
                        "title" to appName,
                    )
                } catch (e: Exception) {
                    null
                }
            }

        launchableApps.sortedBy { it["title"] as String } // optional alphabetical
    }

    suspend fun getAppIcon(context: Context, packageName: String):  ByteArray? =
        withContext(Dispatchers.IO) {

            val pm: PackageManager = context.packageManager


            try {

                return@withContext pm.getApplicationIcon(packageName).toByteArray()

            } catch (e: Exception) {
                return@withContext null
            }

        }


 //   @RequiresPermission(anyOf = ["android.permission.READ_WALLPAPER_INTERNAL", Manifest.permission.MANAGE_EXTERNAL_STORAGE])
 //   suspend fun getWallPaper(context: Context): ByteArray? {
//return null;
     //   return WallpaperManager.getInstance(context).drawable?.toByteArray();

 //   }


  private fun Drawable.toByteArray(): ByteArray {
    val bitmap = if (this is BitmapDrawable) {
      this.bitmap
    } else {
      val bmp = createBitmap(intrinsicWidth.coerceAtLeast(1), intrinsicHeight.coerceAtLeast(1))
      val canvas = Canvas(bmp)
      setBounds(0, 0, canvas.width, canvas.height)
      draw(canvas)
      bmp
    }

    val outputStream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
    return outputStream.toByteArray()
  }


private fun PackageManager.getInstalledPackagesCompat(flags: Long = 0L): List<PackageInfo> {
  return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    getInstalledPackages(PackageManager.PackageInfoFlags.of(flags))
  } else {
    @Suppress("DEPRECATION")
    getInstalledPackages(flags.toInt())
  }
}


    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        val keyInfo = mapOf(
            "keyCode" to keyCode,
            "char" to if (event.unicodeChar != 0) String(Character.toChars(event.unicodeChar)) else null,
            "state" to "keyup"
        )
        eventSink?.success(keyInfo)
        return true
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        val keyInfo = mapOf(
            "keyCode" to keyCode,
            "char" to if (event.unicodeChar != 0) String(Character.toChars(event.unicodeChar)) else null,
            "state" to "keydown"
        )
        eventSink?.success(keyInfo)
        return true
    }

    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        if(event == null) return super.onGenericMotionEvent(event)

        val actionStr = when(event.actionMasked) {
            MotionEvent.ACTION_HOVER_MOVE -> "HOVER_MOVE"
            MotionEvent.ACTION_SCROLL -> "SCROLL"
            MotionEvent.ACTION_MOVE -> "MOVE"
            MotionEvent.ACTION_DOWN -> "DOWN"
            MotionEvent.ACTION_UP -> "UP"
            MotionEvent.ACTION_BUTTON_PRESS -> "BUTTON_PRESS"
            MotionEvent.ACTION_BUTTON_RELEASE -> "BUTTON_RELEASE"
            else -> event.actionMasked.toString()
        }

        val info = """
        ===== MotionEvent =====
        action: $actionStr
        deviceId: ${event.deviceId}
        source: ${event.source}
        pointerCount: ${event.pointerCount}
        x/y: ${event.getX(0)}, ${event.getY(0)}
        pressure: ${event.getPressure(0)}
        axis values: 
            HORIZONTAL_SCROLL: ${event.getAxisValue(MotionEvent.AXIS_HSCROLL)}
            VERTICAL_SCROLL: ${event.getAxisValue(MotionEvent.AXIS_VSCROLL)}
            X: ${event.getAxisValue(MotionEvent.AXIS_X)}
            Y: ${event.getAxisValue(MotionEvent.AXIS_Y)}
            Z: ${event.getAxisValue(MotionEvent.AXIS_Z)}
    """.trimIndent()

        Log.d("USB_KEY_DEBUG", info)

        return super.onGenericMotionEvent(event)
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onActivityResult(requestCode: Int, resultCode: Int, resultData: Intent?) {
        super.onActivityResult(requestCode, resultCode, resultData)

        if (resultCode == Activity.RESULT_OK && resultData?.data != null) {
            val uri = resultData.data
            val mode = resultData.getStringExtra("pickerMode")

            if (uri != null) {
                SAFUri = uri.toString()
                try {
                    contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    methodResult?.success(uri.toString())
                } catch (e: SecurityException) {
                    Log.e("MainActivity", "Failed to take persistable URI permission", e)
                    methodResult?.error("PERMISSION_ERROR", "Failed to take persistable URI permission", null)
                }
            } else {
                methodResult?.error("INVALID_URI", "URI is null", null)
            }
        } else {
            methodResult?.error("RESULT_ERROR", "Invalid result or data", null)
        }
    }


}


