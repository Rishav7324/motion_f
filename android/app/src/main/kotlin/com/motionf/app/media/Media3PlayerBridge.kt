package com.motionf.app.media

import android.content.Context
import android.net.Uri
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer

class Media3PlayerBridge(private val context: Context) {
    companion object {
        private const val TAG = "MotionF_Media3"
    }

    private var exoPlayer: ExoPlayer? = null
    var isPlaying: Boolean = false
        private set

    fun initPlayer(onPositionUpdate: (Long) -> Unit) {
        exoPlayer = ExoPlayer.Builder(context).build().apply {
            repeatMode = Player.REPEAT_MODE_OFF
            addListener(object : Player.Listener {
                override fun onIsPlayingChanged(playing: Boolean) {
                    isPlaying = playing
                }
            })
        }
    }

    fun loadMedia(uriString: String) {
        val mediaItem = MediaItem.fromUri(Uri.parse(uriString))
        exoPlayer?.apply {
            setMediaItem(mediaItem)
            prepare()
        }
    }

    fun play() {
        exoPlayer?.play()
    }

    fun pause() {
        exoPlayer?.pause()
    }

    fun seekTo(positionMs: Long) {
        exoPlayer?.seekTo(positionMs)
    }

    val currentPosition: Long
        get() = exoPlayer?.currentPosition ?: 0L

    val duration: Long
        get() = exoPlayer?.duration ?: 0L

    fun release() {
        exoPlayer?.release()
        exoPlayer = null
    }
}
