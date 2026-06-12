# Máy Phát Sóng Trên FPGA 🌊

> **EE3041 Xử lý Tín hiệu Số trên FPGA - Lab 1 **
> Triển khai phần cứng máy Phát Sóng trên **Terasic DE10-Standard** và **DE2**.

---

## 1. Kiến trúc & Phiên bản 🚀
Hệ thống được tạo trên **hai phiên bản phần cứng** đánh đổi giữa việc sử dụng tài nguyên và logic thiết kế:
 
### 🔹 Phiên bản 1: Kiến trúc Bảng LUT (Kit DE10-Standard)
* **Phương pháp:** Sử dụng giải thuật DDS và sử dụng **Look-Up Table - LUT**.
* **Triển khai:** Sin, Vuông, Tam giác, Răng cưa và ECG được lưu trữ trong **Block RAM** của FPGA.
* **Ưu điểm:** Tạo dạng sóng mượt, độ phân giải cao và khả năng chia tỷ lệ pha và tần số chính xác, tận dụng dung lượng bộ nhớ lớn của chip Cyclone V SoC.

### 🔹 Phiên bản 2: Kiến trúc dựa trên FSM (Kit DE2)
* **Phương pháp:** Tạo tín hiệu thông qua **Máy trạng thái hữu hạn** và các bộ đếm .
* **Triển khai:** Các dạng sóng Vuông, Tam giác, Răng cưa được tính toán động theo thời gian thực bằng các bộ đếm liên tục và máy trạng thái.
* **Ưu điểm:** **Tiết kiệm triệt để tài nguyên Block RAM**, tối ưu hóa cho các dòng chip cũ hoặc hạn chế về tài Cyclone II trên board DE2.

---

## 2. Từ khóa Kỹ thuật & Năng lực 🎯
* **Ngôn ngữ Mô tả Phần cứng:** Verilog / SystemVerilog.
* **Kiến trúc DSP:** Direct Digital Synthesis, Bẳng tra LUT, Bộ tạo sóng FSM, I2S Controller, I2C Controller.
* **Giao thức & Chuẩn giao tiếp:** I2C Controller WM8731, Giao thức âm thanh I2S truyền dữ liệu nối tiếp.
* **Kiểm thử & Xác minh:** Mô phỏng RTL bằng ModelSim / QuestaSim, Kiểm thử phần cứng qua Oscilloscope.

---

## 3. Thông số Phần cứng Hệ thống 📊
* **Xung nhịp Hệ thống/MCLK:** 3.072 MHz / 12.288 MHz ($256 \times F_s$).
* **Cấu hình Audio DAC:** Sử dụng chip Wolfson WM8731 CODEC.
* **Tần số lấy mẫu & Độ phân giải:** ở $F_s = 48\text{ kHz}$ với độ phân giải 24-bit.
* **Module Tiêm Nhiễu:** Bộ thanh ghi dịch phản hồi tuyến tính (LFSR) 24-bit kết hợp bộ dồn kênh (multiplexer) để giảm chấn ($/1$ giảm dần đến $/128$).

---

## 4. Quá trình Gỡ lỗi 🛠️

1. **Lỗi Định dạng Dữ liệu:** Chip DAC WM8731 yêu cầu các mẫu âm thanh có dấu, cho nên các giá trị bộ đếm không dấu và LUT/FSM sử dụng định dạng số không dấu là không thể.
  **Giải pháp:** Sử dụng LUT theo giá trị bù 2 và bộ tạo sóng FSM theo tín hiệu bù 2 trước khi dữ liệu đi vào I2S Controller.
2. **Clock Domain Crossing:** Hệ thống sử dụng tần số 3.072Mhz nhưng LUT/I2S Controller có thể sử dụng tần số độc lập.
   **Giải pháp:** Sử dụng chung tần số 3.072Mhz tránh hiện tượng meta-stability, glitch và bộ bắt cạnh lên 48khz tránh hiện tượng over-sampling.

--- 

## 5. Demo trên FPGA KIT DE-10.

