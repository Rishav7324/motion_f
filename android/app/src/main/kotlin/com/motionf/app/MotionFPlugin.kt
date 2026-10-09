package com.motionf.app

import android.app.Activity
import android.graphics.SurfaceTexture
import android.util.Log
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import com.motionf.app.media.EglSurfaceManager
import com.motionf.app.media.Media3PlayerBridge
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

class MotionFPlugin(
    private val activity: Activity,
    private val flutterEngine: FlutterEngine
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.motionf.app/engine"
        private const val TAG = "MotionFPlugin"

        init {
            System.loadLibrary("motionf_engine")
        }
    }

    private var methodChannel: MethodChannel? = null
    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var eglManager: EglSurfaceManager? = null
    private var media3Bridge: Media3PlayerBridge? = null

    // Native JNI functions declared in jni_bridge.cpp
    private external fun nativeInitEngine(width: Int, height: Int)
    private external fun nativeDestroyEngine()
    private external fun nativeEvaluateBezier(x1: Float, y1: Float, x2: Float, y2: Float, t: Float): Float
    private external fun nativeSetParent(childId: String, parentId: String)
    private external fun nativeUpdateCamera(
        posX: Float, posY: Float, posZ: Float,
        tgtX: Float, tgtY: Float, tgtZ: Float,
        fovDeg: Float, zoom: Float
    )

    fun setupChannels() {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        media3Bridge = Media3PlayerBridge(activity)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initPreviewTexture" -> {
                val width = call.argument<Int>("width") ?: 1080
                val height = call.argument<Int>("height") ?: 1920

                textureEntry = flutterEngine.renderer.createSurfaceTexture()
                val surfaceTexture = textureEntry!!.surfaceTexture()
                surfaceTexture.setDefaultBufferSize(width, height)

                eglManager = EglSurfaceManager(surfaceTexture).apply {
                    init()
                }

                nativeInitEngine(width, height)
                result.success(textureEntry!!.id())
            }

            "evaluateBezier" -> {
                val x1 = (call.argument<Double>("x1") ?: 0.0).toFloat()
                val y1 = (call.argument<Double>("y1") ?: 0.0).toFloat()
                val x2 = (call.argument<Double>("x2") ?: 1.0).toFloat()
                val y2 = (call.argument<Double>("y2") ?: 1.0).toFloat()
                val t = (call.argument<Double>("t") ?: 0.0).toFloat()

                val res = nativeEvaluateBezier(x1, y1, x2, y2, t)
                result.success(res.toDouble())
            }

            "setParent" -> {
                val childId = call.argument<String>("childId") ?: ""
                val parentId = call.argument<String>("parentId") ?: ""
                nativeSetParent(childId, parentId)
                result.success(true)
            }

            "updateCamera" -> {
                val px = (call.argument<Double>("px") ?: 0.0).toFloat()
                val py = (call.argument<Double>("py") ?: 0.0).toFloat()
                val pz = (call.argument<Double>("pz") ?: 1000.0).toFloat()
                val tx = (call.argument<Double>("tx") ?: 0.0).toFloat()
                val ty = (call.argument<Double>("ty") ?: 0.0).toFloat()
                val tz = (call.argument<Double>("tz") ?: 0.0).toFloat()
                val fov = (call.argument<Double>("fov") ?: 45.0).toFloat()
                val zoom = (call.argument<Double>("zoom") ?: 1.0).toFloat()

                nativeUpdateCamera(px, py, pz, tx, ty, tz, fov, zoom)
                result.success(true)
            }

            "renderFrame" -> {
                eglManager?.makeCurrent()
                eglManager?.swapBuffers()
                result.success(true)
            }

            "exportVideoFFmpeg" -> {
                val command = call.argument<String>("command") ?: ""
                FFmpegKit.executeAsync(command) { session ->
                    val returnCode = session.returnCode
                    if (ReturnCode.isSuccess(returnCode)) {
                        activity.runOnUiThread {
                            methodChannel?.invokeMethod("onExportProgress", mapOf("status" to "success"))
                        }
                    } else {
                        activity.runOnUiThread {
                            methodChannel?.invokeMethod("onExportProgress", mapOf("status" to "failed"))
                        }
                    }
                }
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    fun cleanup() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        nativeDestroyEngine()
        eglManager?.release()
        eglManager = null

        textureEntry?.release()
        textureEntry = null

        media3Bridge?.release()
        media3Bridge = null
    }
}
