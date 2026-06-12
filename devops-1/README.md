# Tài liệu

## Yêu cầu:
- Có server linux

## Hướng dẫn chạy
- thực hiện copy code hoặc clone lên server linux
- thực hiện chạy câu lệnh chmod +x devops-1/deploy.sh
- Chạy câu lệnh sau ./devops-1/deploy.sh

---

# Bài Tập Về Nhà — Thu Thập Thông Tin Dự Án

> **Yêu cầu chung:** Sau khi deploy ứng dụng thành công, sử dụng các lệnh Linux đã học để lấy đầy đủ các thông tin bên dưới. Ghi lại **lệnh đã dùng** và **kết quả output** vào file báo cáo.

---

## 1. Thông tin hệ thống (System Info)

- [ ] Tên hostname của server
- [ ] Địa chỉ IP public và IP private của server
- [ ] Phiên bản hệ điều hành (OS) đang chạy
- [ ] Phiên bản kernel Linux
- [ ] Kiến trúc CPU (x86_64, arm64,...)
- [ ] Số lượng CPU core
- [ ] Tổng dung lượng RAM và RAM đang được sử dụng
- [ ] Tổng dung lượng ổ đĩa và dung lượng còn trống
- [ ] Thời gian server đã chạy liên tục (uptime)
- [ ] Timezone đang cấu hình trên server

---

## 2. Thông tin Python & môi trường Backend

- [ ] Phiên bản Python đang chạy backend (`python3 --version`)
- [ ] Đường dẫn tuyệt đối của Python binary trong virtualenv
- [ ] Danh sách tất cả package đã cài trong virtualenv (`pip list`)
- [ ] Phiên bản FastAPI đang dùng
- [ ] Phiên bản uvicorn đang dùng
- [ ] Phiên bản asyncpg đang dùng
- [ ] Đường dẫn đến file `main.py`
- [ ] Nội dung file `.env` của backend (che password)

---

## 3. Thông tin tiến trình Backend (Process)

- [ ] PID của tiến trình uvicorn đang chạy
- [ ] Command line đầy đủ của tiến trình (bao gồm tham số)
- [ ] User đang chạy tiến trình
- [ ] Thời điểm tiến trình được khởi động (start time)
- [ ] Tiến trình cha (PPID) của uvicorn là gì
- [ ] Số lượng thread của tiến trình
- [ ] Số lượng file descriptor đang mở
- [ ] Dung lượng RAM thực tế tiến trình đang dùng (RSS)
- [ ] Dung lượng virtual memory (VSZ)
- [ ] CPU usage của tiến trình (%)
- [ ] Working directory của tiến trình
- [ ] Các biến môi trường tiến trình đang nhận (từ `/proc/<PID>/environ`)

---

## 4. Thông tin systemd Service

- [ ] Trạng thái hiện tại của service `devops-backend` (active/inactive/failed)
- [ ] PID được systemd quản lý
- [ ] Thời gian service được start lần gần nhất
- [ ] Số lần service đã restart kể từ khi cài
- [ ] Đường dẫn file unit `.service` trên hệ thống
- [ ] Nội dung đầy đủ file unit (`systemctl cat devops-backend`)
- [ ] Service có được enable (tự khởi động khi boot) không
- [ ] Các service mà `devops-backend` phụ thuộc vào (dependencies)
- [ ] Giới hạn `LimitNOFILE` được cấu hình trong service
- [ ] 20 dòng log gần nhất của service từ journald

---

## 5. Thông tin Network & Port

- [ ] Port nào backend đang lắng nghe (và trên interface nào)
- [ ] Port nào nginx đang lắng nghe
- [ ] Port nào PostgreSQL đang lắng nghe
- [ ] Liệt kê tất cả port đang LISTEN trên server
- [ ] Số kết nối TCP đang ESTABLISHED đến port 80
- [ ] Số kết nối TCP đang ESTABLISHED đến port 3000
- [ ] Địa chỉ socket file của PostgreSQL (nếu có)
- [ ] Xác nhận nginx có đang proxy đúng đến `127.0.0.1:3000` không

---

## 6. Thông tin Nginx

- [ ] Phiên bản Nginx đang cài
- [ ] PID của master process Nginx
- [ ] PID của các worker process Nginx
- [ ] Số lượng worker process đang chạy
- [ ] Đường dẫn file config đang dùng (`/etc/nginx/sites-enabled/`)
- [ ] Kết quả kiểm tra cú pháp config (`nginx -t`)
- [ ] Đường dẫn file access log và error log của Nginx
- [ ] 10 request gần nhất trong access log
- [ ] Có bao nhiêu request trả về HTTP 200 trong access log
- [ ] Có bao nhiêu request trả về HTTP 502/504 trong access log (nếu có)

---

## 7. Thông tin Docker & PostgreSQL

- [ ] Phiên bản Docker Engine đang cài
- [ ] Phiên bản Docker Compose đang cài
- [ ] Tên và ID của container PostgreSQL đang chạy
- [ ] Trạng thái container (running/exited/...)
- [ ] Image PostgreSQL đang dùng (tên + tag + image ID)
- [ ] Port mapping của container (host port → container port)
- [ ] Tên volume Docker đang mount cho data PostgreSQL
- [ ] Dung lượng volume PostgreSQL đang chiếm
- [ ] Biến môi trường được truyền vào container (POSTGRES_DB, POSTGRES_USER,...)
- [ ] Thời gian container được khởi động
- [ ] 20 dòng log gần nhất của container PostgreSQL

---

## 8. Thông tin Database PostgreSQL

- [ ] Phiên bản PostgreSQL đang chạy
- [ ] Tên database đã tạo
- [ ] Tên user/role đã tạo
- [ ] Danh sách tất cả bảng trong database `devops_training`
- [ ] Cấu trúc (schema) của bảng `messages`
- [ ] Số lượng bản ghi trong bảng `messages`
- [ ] Nội dung toàn bộ bảng `messages`
- [ ] Dung lượng database `devops_training` đang chiếm
- [ ] Các kết nối hiện tại đến PostgreSQL (`pg_stat_activity`)

---

## 9. Kiểm tra API hoạt động (End-to-end)

- [ ] Gọi `GET /api/health` — output JSON và HTTP status code
- [ ] Gọi `GET /api/message` — output JSON và HTTP status code
- [ ] Gọi `GET /api/info` — output JSON và HTTP status code
- [ ] Thời gian phản hồi (response time) của từng endpoint
- [ ] Header response trả về từ Nginx (kiểm tra `X-Frame-Options`, `Server`,...)
- [ ] Gọi 1 endpoint không tồn tại (VD: `/api/abc`) — HTTP status code trả về là bao nhiêu

---

## 10. Thông tin bảo mật cơ bản

- [ ] User `devops` có trong `/etc/passwd` không, home directory là gì
- [ ] User `devops` thuộc những group nào
- [ ] Phân quyền (permission) của thư mục `/opt/devops-training-app`
- [ ] Phân quyền của file `/opt/devops-training-app/backend/.env`
- [ ] UFW firewall có đang bật không, các rule đang áp dụng là gì
- [ ] Các port nào đang được mở ra internet (dựa trên firewall rules)

---

## Nộp bài

Tổng hợp toàn bộ lệnh + output vào 1 file `report_<tên_bạn>.md` theo cấu trúc và gửi link vào nhóm để đánh giá và kiểm tra:

```
## <Tên mục>
**Lệnh:** `<lệnh đã dùng>`
**Output:**
<kết quả>
```

> **Lưu ý:** Không được copy kết quả giả. Mỗi output phải khớp với thực tế server của bạn (có hostname, IP, PID, timestamp thực).
