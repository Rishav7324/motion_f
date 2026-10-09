package com.motionf.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var plugin: MotionFPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        plugin = MotionFPlugin(this, flutterEngine)
        plugin?.setupChannels()
    }

    override fun onDestroy() {
        plugin?.cleanup()
        plugin = null
        super.onDestroy()
    }
}
