# Infrared Plugin

<div align="center">
<a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"/>
</a>
<img src="https://img.shields.io/badge/Flutter-%E2%9D%A4-blue" alt="Flutter"/>
<img src="https://img.shields.io/badge/Platform-Android-green" alt="Platform: Android"/>
<img src="https://img.shields.io/badge/Native%20Bridge-JNIgen-blueviolet" alt="Native Bridge: JNIgen"/>
<a href="#examples">
  <img src="https://img.shields.io/badge/Example-Included-009688" alt="Example Included"/>
</a>
</div>

**Infrared Plugin** is a Flutter plugin designed to provide seamless interaction with a device's infrared (IR) emitter. It allows your Flutter applications to check for IR hardware, query supported frequencies, and transmit custom IR patterns, enabling control of IR-controlled devices directly from your app.

Built using `jnigen` for robust JNI bindings, this plugin ensures reliable communication with the native Android ConsumerIrManager API.

---

## Key Features 🚀

- **IR Emitter Detection**: Easily check if the Android device has an infrared emitter capable of transmitting IR signals via `hasIrEmitter()`.
- **Carrier Frequency Discovery**: Retrieve a list of supported carrier frequency ranges (`min` and `max` Hz) for the IR emitter using `getCarrierFrequencies()`, ensuring compatibility with various devices.
- **Flexible IR Pattern Transmission**:
  - **Hexadecimal String Transmission**: Send IR patterns defined as space-separated hexadecimal pulse durations using `transmitHex()`. Ideal for predefined or custom raw IR codes.
  - **Integer List Transmission**: Transmit IR patterns using a direct list of integer pulse durations (microseconds) with `transmitInts()`, offering programmatic control.
- **Seamless JNI Integration**: Leverages `jnigen` to generate efficient and type-safe Dart bindings for the native Kotlin/Java Android implementation, simplifying native interop.
- **Android-Specific**: Fully integrated with Android's `ConsumerIrManager` for reliable IR functionality.

---

## Supported Platforms 💻

This plugin currently supports:

- **Android**: Fully supported for devices equipped with an IR emitter.

---

## Installation 💻

Add `infrared_plugin` to your `pubspec.yaml`:

```yaml
dependencies:
  infrared_plugin: ^0.0.1
```

Then, fetch packages:

```bash
flutter pub get
```

---

## Android Setup

No special AndroidManifest permissions are typically required for basic IR transmission, as the `ConsumerIrManager` methods handle the necessary permissions internally. However, ensure your `minSdkVersion` in `android/app/build.gradle` is at least **API Level 19** (Android 4.4 KitKat), as `ConsumerIrManager` was introduced in this version.

```gradle
android {
    defaultConfig {
        minSdkVersion 19 // or higher
        // ...
    }
    // ...
}
```

---

## Getting Started

1.  **Import the library:**

    ```dart
    import 'package:infrared_plugin/infrared_plugin.dart';
    ```

2.  **Access the plugin instance:**
    The `InfraredPlugin` is implemented as a singleton, so you can access its instance directly:

    ```dart
    final irPlugin = InfraredPlugin();
    ```

3.  **Check for IR Emitter and Get Frequencies (Recommended):**
    Before transmitting, it's good practice to verify the device's capabilities.

    ```dart
    Future<void> initIr() async {
      final hasEmitter = await irPlugin.hasIrEmitter();
      if (hasEmitter) {
        print('Device has an IR emitter!');
        final frequencies = await irPlugin.getCarrierFrequencies();
        print('Supported frequencies: $frequencies');
      } else {
        print('Device does NOT have an IR emitter.');
      }
    }
    ```

4.  **Transmit an IR Pattern:**

    - **Using Hexadecimal String:**

      ```dart
      // Example: A simple ON/OFF pattern (replace with your actual IR code)
      final int frequency = 38000; // Common IR frequency (Hz)
      final String hexPattern = "00C8 00C8 00C8 00C8 00C8 00C8"; // Example pulse durations in hex (microseconds)

      try {
        await irPlugin.transmitHex(
          frequency: frequency,
          hexPattern: hexPattern,
        );
        print('Hex pattern transmitted successfully!');
      } catch (e) {
        print('Error transmitting hex pattern: $e');
      }
      ```

    - **Using Integer List:**

      ```dart
      // Example: Same pattern as above, but as a list of integers
      final int frequency = 38000;
      final List<int> intPattern = [200, 200, 200, 200, 200, 200]; // Pulse durations in microseconds

      try {
        await irPlugin.transmitInts(
          frequency: frequency,
          pattern: intPattern,
        );
        print('Integer pattern transmitted successfully!');
      } catch (e) {
        print('Error transmitting integer pattern: $e');
      }
      ```

---

## Core Concepts

### InfraredPlugin Singleton

The `InfraredPlugin` class follows the singleton pattern, ensuring that only one instance of the plugin exists throughout your application. This centralizes control and management of the device's IR emitter.

- Access the instance via `InfraredPlugin()`.
- The native `IrController` is initialized upon the first access of the singleton, binding it to the current Android `Context`.

### IR Emitter Capabilities

- `hasIrEmitter()`: A quick check for hardware capability. Always check this before attempting to transmit.
- `getCarrierFrequencies()`: Essential for understanding what frequencies your device can actually emit. Transmitting outside these ranges might fail or result in unreliable signals.

### Pattern Formats

The plugin supports two common ways to define IR patterns:

- **Hexadecimal String**: A convenient format often found in IR databases. Each hexadecimal value represents a duration.
- **Integer List**: A direct array of pulse durations, useful when patterns are generated programmatically or extracted from other sources as raw numbers.

Both `transmitHex` and `transmitInts` expect the `frequency` parameter in Hertz (Hz) and the pattern durations in microseconds (µs).

---

## JNI Binding (Under the Hood)

This plugin leverages `jnigen`, a Dart tool for generating C and Dart bindings for Java/Kotlin code. This means:

- Your Dart code calls the Dart-side `IrController` bindings.
- These Dart bindings then communicate with the native Kotlin `IrController` class via JNI.
- The Kotlin `IrController` interacts with the Android `ConsumerIrManager` to control the IR hardware.

This architecture ensures high performance and type safety between your Flutter app and the native Android IR APIs.

---

## Examples 🎯

Check the [example](example/) folder for a full, runnable Flutter application demonstrating how to use the `infrared_plugin` to check capabilities and transmit IR patterns.

---

## Contributing 🤝

We welcome contributions\! Feel free to open issues, suggest enhancements, or submit pull requests. Please follow our coding style and ensure all tests pass.

---

## License 📄

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---
