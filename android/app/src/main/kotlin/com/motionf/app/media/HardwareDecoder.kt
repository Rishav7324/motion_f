package com.motionf.app.media

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.util.Log
import android.view.Surface
import java.io.IOException

class HardwareDecoder(private val filePath: String, private val outputSurface: Surface) {
    companion object {
        private const val TAG = "MotionF_Decoder"
        private const val TIMEOUT_US = 10000L
    }

    private var extractor: MediaExtractor? = null
    private var decoder: MediaCodec? = null
    var durationUs: Long = 0L
    var videoWidth: Int = 0
    var videoHeight: Int = 0

    fun prepare(): Boolean {
        try {
            extractor = MediaExtractor().apply {
                setDataSource(filePath)
            }

            val numTracks = extractor!!.trackCount
            var videoTrackIndex = -1
            var videoFormat: MediaFormat? = null

            for (i in 0 until numTracks) {
                val format = extractor!!.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
                if (mime.startsWith("video/")) {
                    videoTrackIndex = i
                    videoFormat = format
                    break
                }
            }

            if (videoTrackIndex < 0 || videoFormat == null) {
                Log.e(TAG, "No video track found in: $filePath")
                return false
            }

            extractor!!.selectTrack(videoTrackIndex)
            val mime = videoFormat.getString(MediaFormat.KEY_MIME)!!
            videoWidth = videoFormat.getInteger(MediaFormat.KEY_WIDTH)
            videoHeight = videoFormat.getInteger(MediaFormat.KEY_HEIGHT)
            durationUs = videoFormat.getLong(MediaFormat.KEY_DURATION)

            decoder = MediaCodec.createDecoderByType(mime).apply {
                configure(videoFormat, outputSurface, null, 0)
                start()
            }
            Log.i(TAG, "HardwareDecoder ready: ${videoWidth}x${videoHeight}, duration: ${durationUs / 1000}ms")
            return true
        } catch (e: IOException) {
            Log.e(TAG, "Failed to prepare hardware decoder", e)
            return false
        }
    }

    fun seekTo(timeUs: Long) {
        extractor?.seekTo(timeUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
        decoder?.flush()
    }

    fun decodeNextFrame(): Boolean {
        val dec = decoder ?: return false
        val ext = extractor ?: return false

        // Feed input buffer
        val inIndex = dec.dequeueInputBuffer(TIMEOUT_US)
        if (inIndex >= 0) {
            val inputBuffer = dec.getInputBuffer(inIndex)
            if (inputBuffer != null) {
                val sampleSize = ext.readSampleData(inputBuffer, 0)
                if (sampleSize < 0) {
                    dec.queueInputBuffer(inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                } else {
                    dec.queueInputBuffer(inIndex, 0, sampleSize, ext.sampleTime, 0)
                    ext.advance()
                }
            }
        }

        // Drain output buffer to output Surface
        val bufferInfo = MediaCodec.BufferInfo()
        val outIndex = dec.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)
        if (outIndex >= 0) {
            // Render directly to surface texture
            dec.releaseOutputBuffer(outIndex, true)
            return true
        }
        return false
    }

    fun release() {
        try {
            decoder?.stop()
            decoder?.release()
            extractor?.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing decoder", e)
        }
        decoder = null
        extractor = null
    }
}
