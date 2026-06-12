# Wage_Generator
EE3041 DSP on FPGA Lab 1 at HCMUT: A digital waveform generator (Sine, Square, Triangle, Sawtooth, ECG) implemented on DE10-Standard &amp; DE2- . Features real-time parameter control (frequency, amplitude,) and LFSR-based noise injection.

## 1. Project Overview
A digital signal processing (DSP) system designed and implemented on an FPGA to generate versatile waveforms with real-time parameter tuning and controllable hardware noise injection[cite: 1]. This project serves as the foundational transmitter module for a complete communication/filtering system[cite: 1].

### Key Specifications:
* **Target Hardware:** Terasic DE10-Standard (Intel Cyclone V SX SoC FPGA)[cite: 1].
* **System Clock / MCLK:** 3.072 MHz / 12.288 MHz ($256 \times F_s$).
* **Audio DAC Configuration:** Wolfson WM8731 CODEC operated at $F_s = 48\text{ kHz}$ with 24-bit resolution[cite: 1].

## 2. Technical Keywords & Competencies
* **Hardware Description Language (HDL):** Verilog / SystemVerilog.
* **Digital Signal Processing (DSP):** Direct Digital Synthesis (DDS), Phase Accumulator, Look-Up Table (LUT) compression.
* **Hardware Verification & Simulation:** ModelSim / QuestaSim, RTL Simulation, Testbench development[cite: 1].
* **Digital Interfaces & Protocols:** I2C (Control Path / State Machine), I2S (Data Path / Serial Audio Transmission).
* **Hardware Testing Instruments:** Digital Storage Oscilloscope (MSO/DSO), Hardware-in-the-Loop (HIL) testing[cite: 1].
* **Logic Optimization & Timing:** Finite State Machine (FSM), Clock Domain Synchronization (Mitigating Clock Skew).
* **Design for Testability (DFT) / Verification:** Linear Feedback Shift Register (LFSR) pseudo-random noise generation, Bit-Shift Gain Control[cite: 1].

## 3. RTL Architecture & Implementation
The design is modularly partitioned into four main functional blocks:

1. **Phase Accumulator & LUT (DDS Core):** Generates 5 distinct waveforms (Sine, Square with 50% duty cycle, Triangle, Sawtooth, and a simulated biological complex ECG signal)[cite: 1].
2. **LFSR Noise Generator & Gain Control:** Implements a 24-bit LFSR using a feedback polynomial ($23 \oplus 22 \oplus 21 \oplus 16$) to generate pseudo-random noise. Features bit-shifting arithmetic to achieve resource-efficient amplitude scaling ($/1$ down to $/128$).
3. **I2C Master Controller:** A robust Finite State Machine (FSM) operating at 300 kHz SCL to initialize and load the 10 structural configuration registers of the WM8731 CODEC.
4. **I2S Transmitter Module:** Serializes 24-bit parallel waveform data into Left/Right stereo audio channels synchronized with the DAC sampling rate ($F_s = 48\text{ kHz}$).

## 4. Hardware Verification & Critical Debugging Analysis

### Simulation Results (QuestaSim/ModelSim)
RTL simulation demonstrated perfect theoretical waveforms (Sine, Square, Triangle, Sawtooth, ECG) with precise frequency calculations based on the phase increment formula:
$$f_{out} = \frac{f_{clk} \times \text{phase\_increment}}{2^N}$$

### Hardware Testing Anomalies (Oscilloscope Measurement)
During physical testing using a 3.5mm-to-BNC cable on a Siglent Oscilloscope, the analog output exhibited distortion, incorrect duty cycles, and unprovoked background noise[cite: 1].

### Root Cause Analysis (Engineering Post-Mortem):
Through rigorous testbench debugging and waveform analysis, our team successfully isolated two critical hardware bugs:
1. **Data Format Mismatch (Signed vs. Unsigned):** The WM8731 DAC expects signed data format, whereas our look-up tables (LUTs) were mistakenly synthesized using unsigned data, causing clipping and distortion at the extreme thresholds.
2. **I2S Protocol Timing Skew:** The I2S transmitter initiated data transmission immediately when `DACLRC = 1` without waiting for the standard 1-BCLK cycle delay required by the standard protocol. This misalignment corrupted the right-channel sample framing while leaving the left-channel partially functional.

### Key Learning Outcomes:
* Deepened practical understanding of signed vs. unsigned binary representation in DSP hardware.
* Mastered protocol timing specifications (I2C/I2S) beyond basic RTL simulation boundaries.

## 5. Synthesis Results (Intel Quartus Prime)
The design achieves high resource efficiency, leaving ample logic elements for future complex filtering blocks (Lab 2)[cite: 1]:

* **Logic Utilization:** 184 / 41,910 ALMs (< 1%)
* **Total Registers:** 174
* **Block Memory Bits:** 491,520 / 5,662,720 (9%) (Primarily allocated for complex ECG ROM arrays)
* **DSP Blocks:** 0 / 112 (0%) (Optimized via shift-based arithmetic instead of multipliers)[cite: 1]
* **PLLs:** 1 / 15 (7%)
