# Máy Phát Dạng Sóng Đa Năng Trên FPGA 🌊

> **EE3041 Xử lý Tín hiệu Số trên FPGA - Lab 1 (Đại học Bách Khoa TP.HCM)**[cite: 1]
> Một hệ thống xử lý tín hiệu số (DSP) đa năng được triển khai với hai kiến trúc phần cứng khác biệt, được tối ưu hóa cho hai bộ Kit phát triển **Terasic DE10-Standard** và **DE2**.[cite: 1]

---

## 1. Kiến trúc Dự án & Các Phiên bản 🚀
Hệ thống tạo dạng sóng được phát triển thành **hai phiên bản phần cứng** nhằm thể hiện tư duy đánh đổi (trade-off) giữa việc sử dụng bộ nhớ và logic thiết kế:

### 🔹 Phiên bản 1: Kiến trúc dựa trên Bảng tra cứu LUT (Phần cứng: Kit DE10-Standard)[cite: 1]
* **Phương pháp:** Tổng hợp Tín hiệu số Trực tiếp (DDS) sử dụng **Bảng tra cứu (Look-Up Table - LUT)**.[cite: 1]
* **Triển khai:** Toàn bộ 5 dạng sóng (Sin, Vuông, Tam giác, Răng cưa và tín hiệu điện tâm đồ sinh học ECG) được tính toán trước và lưu trữ trong **Block RAM** của FPGA.[cite: 1]
* **Ưu điểm:** Tạo ra các dạng sóng mượt mà, độ phân giải cao với khả năng chia tỷ lệ pha và tần số cực kỳ chính xác, tận dụng tối đa dung lượng bộ nhớ lớn của chip Cyclone V SoC.[cite: 1]

### 🔹 Phiên bản 2: Kiến trúc dựa trên FSM (Phần cứng: Kit DE2)
* **Phương pháp:** Tạo tín hiệu bằng logic phần cứng thông qua **Máy trạng thái hữu hạn (FSM)** và các bộ đếm kỹ thuật số (Counters).
* **Triển khai:** Các dạng sóng toán học (Vuông, Tam giác, Răng cưa) được tính toán động theo thời gian thực bằng các bộ đếm liên tục và máy trạng thái thay vì dùng mảng bộ nhớ.
* **Ưu điểm:** **Tiết kiệm triệt để tài nguyên Block RAM**, tối ưu hóa cực tốt cho các dòng chip cũ hoặc hạn chế về tài nguyên như Cyclone IV/II trên board DE2.

---

## 2. Từ khóa Kỹ thuật & Năng lực 🎯
* **Ngôn ngữ Mô tả Phần cứng:** Verilog / SystemVerilog.[cite: 1]
* **Kiến trúc DSP:** Direct Digital Synthesis (DDS), Nén dữ liệu LUT, Bộ tạo tín hiệu điều khiển bằng FSM.[cite: 1]
* **Tối ưu hóa Tài nguyên:** Bài toán đánh đổi Memory vs. Logic, Điều chỉnh biên độ bằng phép dịch bit (Bit-Shift Gain Control - thay thế các bộ nhân cồng kềnh bằng phép dịch logic).[cite: 1]
* **Giao thức & Chuẩn giao tiếp:** I2C Master Interface (Cấu hình FSM), Giao thức âm thanh I2S (Truyền dữ liệu nối tiếp).[cite: 1]
* **Kiểm thử & Xác minh:** Mô phỏng RTL bằng ModelSim / QuestaSim, Kiểm thử phần cứng (Hardware-in-the-Loop) qua Dao động ký kỹ thuật số (Oscilloscope).[cite: 1]

---

## 3. Thông số Phần cứng Hệ thống 📊
* **Xung nhịp Hệ thống (System Clock) / MCLK:** 3.072 MHz / 12.288 MHz ($256 \times F_s$).[cite: 1]
* **Cấu hình Audio DAC:** Sử dụng chip Wolfson WM8731 CODEC tích hợp trên board.[cite: 1]
* **Tần số lấy mẫu & Độ phân giải:** Hoạt động ở $F_s = 48\text{ kHz}$ với độ phân giải 24-bit.[cite: 1]
* **Module Tiêm Nhiễu:** Bộ thanh ghi dịch phản hồi tuyến tính (LFSR) 24-bit kết hợp bộ dồn kênh (multiplexer) để giảm chấn ($/1$ giảm dần đến $/128$).[cite: 1]

---

## 4. Quá trình Gỡ lỗi Kỹ thuật Chuyên sâu 🛠️
*Một thành tựu kỹ thuật quan trọng của dự án này là quá trình điều tra và giải quyết triệt để sự sai lệch giữa kết quả mô phỏng RTL lý tưởng và tín hiệu thực tế đo được trên Oscilloscope:*[cite: 1]

1. **Lỗi Định dạng Dữ liệu (Signed vs. Unsigned):** Chip DAC WM8731 yêu cầu các mẫu âm thanh có dấu (signed - bù 2), nhưng ban đầu các mảng LUT/FSM lại xuất ra giá trị độ lớn không dấu (unsigned).[cite: 1] Điều này dẫn đến hiện tượng xén ngọn tín hiệu (clipping) nghiêm trọng.[cite: 1]
   * **Khắc phục:** Tổng hợp lại dữ liệu tra cứu và giới hạn logic để hệ thống hỗ trợ nguyên bản các phép toán có dấu.[cite: 1]
2. **Lệch Đồng bộ Giao thức I2S (Timing Skew):** Đường truyền dữ liệu đã bỏ qua độ trễ chuẩn `1-BCLK` chu kỳ sau khi tín hiệu `DACLRC` chuyển trạng thái, làm hỏng khung dữ liệu của kênh âm thanh Stereo bên phải.[cite: 1]
   * **Khắc phục:** Căn chỉnh lại logic điều khiển tuần tự để tuân thủ nghiêm ngặt các ràng buộc chuẩn của giao thức I2S.[cite: 1]

---

## 5. Tóm tắt Tổng hợp Tài nguyên (Cấu hình DE10-Standard) 📉
* **Sử dụng Logic (ALMs):** 184 / 41,910 (< 1%)[cite: 1]
* **Tổng số Thanh ghi (Registers):** 174[cite: 1]
* **Bộ nhớ Block RAM:** 491,520 / 5,662,720 (9%) (Phần lớn được cấp phát cho mảng ROM tín hiệu ECG có mật độ cao trong Phiên bản 1).[cite: 1]
* **Khối DSP (DSP Blocks):** 0% (Được tối ưu hóa hoàn toàn bằng logic dịch bit).[cite: 1]
