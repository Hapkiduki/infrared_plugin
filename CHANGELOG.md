## [0.0.1] - 2025-06-29

### Added

- **Initial Release of `infrared_plugin`**:
  - Core functionality to **check for IR emitter presence** (`hasIrEmitter`).
  - Ability to **retrieve supported carrier frequencies** (`getCarrierFrequencies`).
  - Methods for **transmitting IR patterns** using:
    - Hexadecimal strings (`transmitHex`).
    - Integer pulse duration lists (`transmitInts`).
- **JNI Bindings**: Automatically generated bindings via `jnigen` for seamless communication with native Android (Kotlin) code.
- **Android Implementation**: Native Kotlin implementation leveraging `ConsumerIrManager` for IR control.
- **Documentation**: Comprehensive DartDoc comments for all public APIs, explaining usage, parameters, and return values.
