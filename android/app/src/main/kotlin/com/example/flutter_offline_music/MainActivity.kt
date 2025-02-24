package com.giatk.flutter_offline_music

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity

class MainActivity : AudioServiceActivity () {
    private val CHANNEL = "com.giatk.flutter_offline_music/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "moveToBackground") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
