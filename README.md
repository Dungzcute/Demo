# Tèo đẳng cấp — demo phỏng vấn Angular + Spring Boot

App mới, tối giản theo đề anh Tú: bấm nút trên Angular → gọi API Java Spring Boot → hiển thị dữ liệu thật từ backend. Không cần database, tài khoản hay token.

## Chạy trên Windows

**Chạy nhanh sau khi setup:** mở **start-app.bat**, chờ vài giây rồi truy cập http://127.0.0.1:4200. Hai server chạy nền; dùng **stop-app.bat** để dừng. Log nằm trong `.logs/`. Backend của chế độ này dùng file JAR đã build; sau khi sửa Java, chạy `check.bat` để build lại, hoặc dùng `run-backend.bat` theo các bước dưới.

1. Cần JDK 21 trở lên (máy hiện tại đã có JDK 23).
2. Chạy **setup.bat** một lần, chờ thông báo `Setup complete`. Cần Internet để tải thư viện. Script tải Node.js 24.13.0 và Maven 3.9.11 từ nguồn chính thức, kiểm tra checksum rồi lưu trong `.tools/` của dự án; không thay đổi bản cài toàn máy.
3. Mở **run-backend.bat**, giữ cửa sổ đó chạy. Backend: http://127.0.0.1:8080.
4. Mở **run-frontend.bat**, giữ cửa sổ đó chạy. Frontend: http://127.0.0.1:4200.
5. Mở frontend và bấm **Hi Tèo**. Backend chọn ngẫu nhiên `Đỏ gay` hoặc `Đỏ ngu` cho mỗi request; Angular chỉ hiển thị kết quả nhận được. Hai lần liên tiếp có thể trả cùng một câu.

Dừng từng server bằng `Ctrl+C` trong cửa sổ tương ứng. Chạy lại hai file `run-*.bat` vào những lần sau. Có thể đặt toàn bộ dự án ở ổ D rồi chạy setup nếu muốn tiết kiệm ổ C. Chỉ các file mã nguồn được đưa vào Git; thư viện và công cụ đã được loại bằng `.gitignore`.

## Cấu trúc để trình bày

```text
backend/
  pom.xml                         Dependencies, phiên bản Java, cấu hình build
  src/main/java/com/atu/demo/
    DemoApplication.java          Điểm khởi động Spring Boot
    controller/HelloController.java  Nhận HTTP GET /api/hello
    service/HelloService.java     Tạo thông điệp
    dto/HelloResponse.java        Dữ liệu trả về { message }
  src/test/java/com/atu/demo/HelloApiTest.java
frontend/
  src/main.ts                     Khởi động Angular, cung cấp HttpClient
  src/app/app.component.ts        Trạng thái và sự kiện bấm nút
  src/app/app.component.html      Giao diện
  src/app/services/hello.service.ts  Gọi API bằng HttpClient
  src/styles.css                  Giao diện responsive
  proxy.conf.json                 Chuyển /api/** đến backend khi chạy local
scripts/                          Cài đặt, chạy và kiểm tra trên Windows
```

## Luồng xử lý

`Button → AppComponent → HelloService (Angular) → HTTP GET /api/hello → HelloController → HelloService (Java) → HelloResponse → JSON → Angular hiển thị`

Ví dụ response, HTTP 200, Content-Type `application/json`:

```json
{"message":"Đỏ gay"}
```

Frontend gọi đường dẫn tương đối `/api/hello`. Dev proxy của Angular chuyển request từ cổng 4200 đến cổng 8080; vì vậy trình duyệt không cần cấu hình CORS. Đây là cấu hình chạy local; bản build frontend khi triển khai cần reverse proxy `/api` đến backend.

Angular dùng standalone component, signals để cập nhật giao diện và HttpClient để gọi HTTP. Spring Boot dùng constructor injection, `@RestController`, `@GetMapping` và Java record làm DTO. Service Java chọn một trong hai câu bằng `ThreadLocalRandom`, được tách riêng để dễ giải thích trách nhiệm từng lớp.

## Kiểm tra

Chạy **check.bat** để chạy integration test backend qua HTTP thật và build production Angular (kèm kiểm tra TypeScript/template).

Kiểm tra trực tiếp:

- Mở trang: chưa có kết quả trước khi bấm nút.
- Bấm nút: có trạng thái đang tải, khóa nút trong lúc gửi request, sau đó hiện lời chào và thời điểm nhận.
- Bấm lại: gửi một request mới.
- Tắt backend rồi bấm: hiện thông báo lỗi và nút thử lại. Request timeout sau 10 giây nếu không có phản hồi.
- Bật lại backend rồi thử lại: kết quả thành công trở lại.
- Trong DevTools → Network, xem request `/api/hello` và JSON response để chứng minh dữ liệu đi từ backend.

Nếu cổng 8080 hoặc 4200 đang bị dùng, dừng app đang chiếm cổng trước khi chạy. Nếu đổi cổng backend trong `application.properties`, cập nhật cả `frontend/proxy.conf.json`. Nếu sửa proxy, khởi động lại frontend.

## Tài liệu chính thức

- [Angular: tương thích Node.js và TypeScript](https://angular.dev/reference/versions)
- [Spring Boot: yêu cầu môi trường](https://docs.spring.io/spring-boot/system-requirements.html)
