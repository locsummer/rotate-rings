# Rotate Rings (Untangle Spatial Logic Puzzle)

Game giải đố không gian và logic 2D mang tính chất thư giãn, rèn luyện trí não, lấy cảm hứng và xây dựng theo chuẩn chất lượng của **Rotate Rings (Nebula Studio)**.

---

## 1. Cấu Trúc Dự Án (Architecture Overview)

Dự án được kiến trúc theo chuẩn Clean Architecture, tách biệt rõ ràng các tầng Physics, Solver, Level Data, UI, Audio và Save System:

```
rotate-rings/
├── android/                         # NATIVE ANDROID (KOTLIN)
│   └── app/src/main/kotlin/com/nebulagame/rotaterings/rotate_rings/
│       ├── model/                  # Ring, Joint, LevelData, LockType
│       ├── physics/                # UntangleEngine, GeometryMath
│       ├── solver/                 # PuzzleSolver (BFS State Search)
│       ├── levels/                 # LevelCatalog (200 màn chơi)
│       ├── storage/                # SaveManager (SharedPreferences)
│       ├── audio/                  # SoundManager (Haptics & SoundPool)
│       └── MainActivity.kt
│   └── app/src/test/kotlin/        # Kotlin Unit Tests
│
├── ios/                             # NATIVE IOS (SWIFT)
│   └── Runner/
│       ├── Models/                 # Ring.swift, Joint.swift, LevelData.swift
│       ├── Physics/                # UntangleEngine.swift, GeometryMath.swift
│       ├── Solver/                 # PuzzleSolver.swift (BFS Solver)
│       ├── Levels/                 # LevelCatalog.swift (200 màn chơi)
│       ├── Storage/                # SaveManager.swift (UserDefaults)
│       ├── Audio/                  # SoundManager.swift (AudioToolbox & Feedback)
│       └── AppDelegate.swift
│   └── RunnerTests/                # Swift XCTest Unit Tests
│
├── lib/                             # CROSS-PLATFORM ENGINE (FLUTTER / DART)
│   ├── models/                     # RingModel, JointModel, LevelData, GameSessionState
│   ├── physics/                    # UntangleEngine, GeometryMath
│   ├── solver/                     # PuzzleSolver (BFS State Search Engine)
│   ├── levels/                     # LevelCatalog (200 Levels chia 9 bậc độ khó)
│   ├── audio/                      # SoundService (ASMR Audio & Haptics)
│   ├── storage/                    # SaveService (Tự động lưu, bảo vệ dữ liệu)
│   ├── ui/
│   │   ├── theme/                  # GameColors (Candy pastel), GameTheme
│   │   ├── components/
│   │   │   ├── ring_canvas.dart    # CustomPainter 120fps + Touch & Drag Physics
│   │   │   ├── squirrel_mascot.dart# Animated Artist Squirrel mascot + Speech bubble
│   │   │   ├── acorn_widget.dart   # Vector Golden Acorn collectible
│   │   │   ├── particle_system.dart# Particle & Confetti celebration engine
│   │   │   ├── victory_dialog.dart # 3-Star Victory Celebration dialog
│   │   │   ├── settings_dialog.dart# Sound/Music/Haptic toggles
│   │   │   └── stats_dialog.dart   # Bảng thành tích người chơi
│   │   └── screens/
│   │       ├── home_screen.dart    # Màn hình chính
│   │       ├── game_screen.dart    # Màn hình chơi game trung tâm
│   │       └── level_select_screen.dart # Chọn 200 màn chơi
│   └── main.dart                   # Entry point
└── test/
    ├── widget_test.dart            # Unit tests toán học, solver, catalog
    └── gameplay_flow_test.dart     # Integration test toàn diện 15 hạng mục
```

---

## 2. Gameplay & Cơ Chế Hoạt Động (Gameplay & Mechanics)

1. **Cơ chế xoay vòng (Rotate Rings)**:
   - Nhận diện chạm chính xác từng vòng qua `GeometryMath.hitTestRing` với thứ tự lớp (Z-index layering).
   - Kéo vuốt ngón tay liên tục theo chiều kim đồng hồ hoặc ngược chiều kim đồng hồ.
   - Tính toán góc tiếp tuyến chính xác: `atan2(touchY - centerY, touchX - centerX)` và góc quay `currentAngle` chuẩn hóa trong `[0, 2π)`.
   - Phản hồi rung haptic và tiếng tick gỗ ASMR nhẹ nhàng mỗi 10 độ quay.

2. **Căn chỉnh khe hở (Hidden Gaps)**:
   - Mỗi vòng có góc bắt đầu (`gapStartAngle`) và độ mở (`gapSweep`, ví dụ ~72°).
   - Khi góc của chốt khóa/khớp nối rơi vào khoảng khe hở (với dung sai mượt mà ±15°), liên kết được giải tỏa.

3. **Hệ thống tháo gỡ đa tầng (Untangle Cascade System)**:
   - Khi một chốt mở ra, hàm `UntangleEngine.checkAndReleaseCascade` tự động kiểm tra dây chuyền.
   - Vòng nào hết chốt khóa sẽ chuyển trạng thái `unlocked` -> `released`, kích hoạt animation trượt bay ra ngoài theo hướng khe hở kèm hiệu ứng ánh sáng lấp lánh (particle burst) và âm thanh pop thỏa mãn.
   - Thu thập hạt dẻ vàng (Golden Acorns) bay về thanh điểm số.
   - Khi toàn bộ cấu trúc được giải phóng -> Kích hoạt màn hình Victory 3 sao và pháo hoa giấy (confetti).

4. **10 Dạng cấu trúc khóa phong phú**:
   - `C-Lock`: Vòng cung hở hình chữ C.
   - `D-Ring`: Vòng chữ D (một bên thẳng, một bên cong có khe hở).
   - `S-Flex`: Mắt xích uốn lượn chữ S.
   - `Triangle Lock`: Khung tam giác liên kết 3 góc.
   - `Double Ring`: Hai vòng lồng nhau / giao nhau.
   - `Triple Ring`: Ba vòng đồng tâm hoặc chuỗi Borromean.
   - `Spiral Lock`: Vòng dạng rãnh xoắn.
   - `Multi-Layer Lock`: Cấu trúc đa tầng (ngoài giữ trong).
   - `Interlocked Chains`: Chuỗi mắt xích liên hoàn (như Level 65 trong game mẫu).
   - `Complex Geometry`: Mạng lưới đa giác hoa thị 6-9 vòng.

5. **Trợ thủ thông minh (Smart BFS Hint Solver)**:
   - Thuật toán tìm kiếm không gian trạng thái (State Search BFS):
     - Duyệt các góc giải phóng của các chốt còn lại trên từng vòng.
     - Tìm nước đi ngắn nhất để tháo gỡ ít nhất 1 chốt hoặc giải phóng 1 vòng ngay lập tức.
     - Làm nổi bật vòng cần xoay bằng quầng sáng nhấp nháy (pulsating glow), mũi tên cong chỉ hướng xoay, và thông điệp hướng dẫn tiếng Việt rõ ràng.

---

## 3. Hệ Thống 200 Màn Chơi (Level Catalog)

Phân chia độ khó chuẩn xác theo 9 bậc:
- **Level 1–20**: Làm quen thao tác 1-2 vòng đơn giản.
- **Level 21–40**: Hai vòng và khe hở kép.
- **Level 41–60**: Cấu trúc C-Lock và D-Ring.
- **Level 61–80**: Nhiều mắt xích đan xen (Đặc biệt **Level 65** tái hiện 1:1 màn chơi trong ảnh tham khảo).
- **Level 81–100**: Cấu trúc ba vòng & ba tầng đồng tâm.
- **Level 101–130**: Khóa hình học (Tam giác, Kim cương, Đa giác).
- **Level 131–160**: Cấu trúc nhiều tầng (Multi-layer hierarchy).
- **Level 161–180**: Khóa lai tạo (Hybrid combinations).
- **Level 181–200**: Bậc thầy tháo gỡ (Master puzzles, 6-9 vòng, tư duy nhiều bước).

---

## 4. Hướng Dẫn Chạy & Build (Build & Run Guide)

### 4.1. Chạy Thử Nghiệm & Test
- Chạy toàn bộ Unit & Integration Tests:
  ```powershell
  flutter test
  ```
- Kiểm tra mã nguồn (lint & typecheck):
  ```powershell
  flutter analyze
  ```

### 4.2. Build Ứng Dụng Android (APK)
```powershell
flutter build apk --debug
# hoặc bản release:
flutter build apk --release
```
File APK xuất xưởng tại:
- **Release APK (Tối ưu hóa, R8 minified, 18.8 MB)**: `build\app\outputs\flutter-apk\app-release.apk`
- **Debug APK (Chứa symbol debug, 94.9 MB)**: `build\app\outputs\flutter-apk\app-debug.apk`

### 4.3. Build Ứng Dụng iOS (IPA)
Trên môi trường macOS có Xcode:
```bash
flutter build ios --no-codesign
# hoặc mở workspace trong Xcode:
open ios/Runner.xcworkspace
```
Chọn scheme **Runner** và nhấn **Product > Archive** để xuất file IPA phát hành App Store.

### 4.4. Chạy Trên Trình Duyệt Web / Desktop
```powershell
flutter run -d chrome
# hoặc build web static:
flutter build web --release
```
Output nằm tại thư mục `build/web/`.
