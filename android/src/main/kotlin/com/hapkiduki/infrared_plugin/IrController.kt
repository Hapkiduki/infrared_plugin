package com.hapkiduki.infrared_plugin

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Build
import android.util.Log
import androidx.annotation.Keep

/**
 * IrController is a singleton object that handles all interactions with Android's ConsumerIrManager.
 *
 * JNIgen will generate bindings for the static methods of this object.
 * The @Keep annotation ensures that Proguard/R8 doesn't remove this class during release builds.
 */
@Keep
object IrController {

    private var consumerIrManager: ConsumerIrManager? = null
    private var isInitialized = false
    private const val TAG = "IrController"

    /**
     * Initializes the controller by getting the ConsumerIrManager system service.
     * This must be called once from the main plugin class.
     * @param context The application context.
     */
    fun initialize(context: Context) {
        if (isInitialized) return
        try {
            // ConsumerIrManager is available on API level 19 (KitKat) and higher.
            consumerIrManager = context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize ConsumerIrManager", e)
        }
        isInitialized = true
    }

    /**
     * Checks if the device has an infrared emitter.
     * @return True if an IR emitter is available, false otherwise.
     */
    @JvmStatic
    fun hasIrEmitter(): Boolean {
        if (consumerIrManager == null) {
            Log.w(TAG, "ConsumerIrManager not initialized or not available.")
            return false
        }
        return consumerIrManager?.hasIrEmitter() ?: false
    }

    /**
     * Retrieves the carrier frequency ranges supported by the hardware.
     * @return An integer array of [min, max, min, max, ...] frequency pairs, or null if not available.
     */
    @JvmStatic
    fun getCarrierFrequencies(): IntArray? {
        if (!hasIrEmitter()) return null
        return try {
            val ranges = consumerIrManager?.carrierFrequencies
            // Flatten the list of ranges into a single integer array for easier JNI transport.
            ranges?.flatMap { listOf(it.minFrequency, it.maxFrequency) }?.toIntArray()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting carrier frequencies", e)
            null
        }
    }

    /**
     * Transmits an IR pattern from a space-separated string of hex values.
     * This is common for Pronto HEX formats.
     *
     * @param frequency The carrier frequency in Hz (e.g., 38000).
     * @param hexPattern A string containing hex values separated by spaces.
     */
    @JvmStatic
    fun transmitHex(frequency: Int, hexPattern: String) {
        if (!hasIrEmitter()) return
        try {
            // Convert the hex string into an integer array of pulse durations (in microseconds).
            val parts = hexPattern.trim().split(Regex("\\s+")).toMutableList()
            if (parts.isNotEmpty()) {
                parts.removeAt(0)
            } else {
                throw IllegalArgumentException("Hex pattern is too short to extract frequency and pattern.")
            }
            val rawFrequencyHex = if (parts.isNotEmpty()) parts.removeAt(0) else {
                throw IllegalArgumentException("Hex pattern is too short to extract frequency.")
            }
            var frequency = rawFrequencyHex.toInt(16)
            if (parts.size >= 2) {
                parts.removeAt(0)
                parts.removeAt(0)
            } else {
                throw IllegalArgumentException("Hex pattern is too short to remove padding elements.")
            }


            frequency = (1000000 / (frequency * 0.241246)).toInt()
            val pulses = 1000000 / frequency
            val pattern = IntArray(parts.size)
            for (i in parts.indices) {
                val count = parts[i].toInt(16)
                pattern[i] = count * pulses
            }
            consumerIrManager?.transmit(frequency, pattern)
        } catch (e: NumberFormatException) {
            Log.e(TAG, "Error parsing hex pattern: $hexPattern", e)
        } catch (e: Exception) {
            Log.e(TAG, "Error transmitting hex pattern", e)
        }
    }

    /**
     * Transmits an IR pattern from an array of integers.
     * Each integer represents a pulse duration in microseconds.
     *
     * @param frequency The carrier frequency in Hz (e.g., 38000).
     * @param pattern An integer array of pulse durations.
     */
    @JvmStatic
    fun transmitInts(frequency: Int, pattern: IntArray) {
        if (!hasIrEmitter()) return
        try {
            consumerIrManager?.transmit(frequency, pattern)
        } catch (e: Exception) {
            Log.e(TAG, "Error transmitting integer pattern", e)
        }
    }
}