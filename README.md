# FPGA-Based Multi-Waveform Generator 🌊

> **EE3041 DSP on FPGA - Lab 1 (HCMUT)**  
> A versatile digital signal processing (DSP) system implemented on an FPGA to generate standard waveforms with real-time parameter tuning and controllable hardware noise injection.

## 1. Project Overview 🚀
This project serves as the foundational transmitter module for a complete communication and filtering system. It generates high-precision digital signals and converts them to analog outputs using onboard hardware.

* **Supported Waveforms:** Sine, Square (50% duty cycle), Triangle, Sawtooth, and ECG (Electrocardiogram).
* **Target Hardware:** Terasic DE10-Standard (Intel Cyclone V SX SoC FPGA).
* **Audio DAC Configuration:** Wolfson WM8731 CODEC.
* **Core Specifications:** System Clock: `3.072 MHz` | Audio Sampling Rate ($F_s$): `48 kHz` | Resolution: `24-bit`.

## 2. RTL Architecture 🧩
The design is modularly partitioned into four main functional blocks:

* **DDS Core (Phase Accumulator & LUT):** The central processing unit generating the 5 distinct waveforms based on Direct Digital Synthesis principles.
* **LFSR Noise Generator:** Generates 24-bit pseudo-random noise. It uses bit-shifting arithmetic for amplitude control (gain) to ensure resource efficiency.
* **I2C Master Controller:** A robust Finite State Machine (FSM) operating at 300 kHz SCL to initialize and configure the DAC chip.
* **I2S Transmitter Module:** Serializes, packs, and synchronizes the 24-bit parallel waveform data into Left/Right stereo audio channels.

## 3. Critical Debugging & Problem Solving 🛠️
*A highlight of the engineering process involved resolving the discrepancy between theoretical simulations and physical hardware behavior.*

* **The Issue:** RTL simulation demonstrated perfect waveforms, but physical oscilloscope measurements exhibited distortion, incorrect duty cycles, and unprovoked noise.
* **Root Cause Analysis & Fixes:**
  1. **Data Format Mismatch (Signed vs. Unsigned):** The WM8731 DAC expects *signed* data, but our LUTs were outputting *unsigned* data. This caused severe clipping at extreme amplitudes. **Fix:** Converted LUT data representation.
  2. **I2S Protocol Timing Skew:** The I2S transmitter was sending data immediately instead of waiting for the standard `1-BCLK` cycle delay required by the protocol. This corrupted the right-channel framing. **Fix:** Re-aligned the state machine to respect the 1-clock delay constraint.

## 4. Synthesis Results & Efficiency 📊
The design achieves high resource efficiency on **Intel Quartus Prime**, leaving ample logic elements for future complex DSP filtering blocks:

* **Logic Elements (ALMs):** `< 1%` (Highly optimized control logic).
* **DSP Blocks:** `0%` (Automatically optimized by using shift-based arithmetic instead of resource-heavy multipliers).
* **Block Memory:** `9%` (Memory resources intentionally prioritized for complex waveform ROM arrays, such as the ECG signal).

---
*Designed and debugged with ❤️ for the Digital Signal Processing on FPGA course.*
