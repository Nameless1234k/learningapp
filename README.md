# Learning App

Dự án ứng dụng học tập gồm Backend (Spring Boot / Kotlin) và Frontend (Flutter).

## Cấu trúc dự án
- `backend/`: REST API service xây dựng bằng Spring Boot 3.3.5, Kotlin, Spring Data JPA, JWT & PostgreSQL.
- `frontend/`: Ứng dụng di động và web đa nền tảng xây dựng bằng Flutter.

## Hướng dẫn cài đặt & khởi chạy

### 1. Backend (Spring Boot)
Yêu cầu: JDK 21, PostgreSQL.
```bash
cd backend
./gradlew bootRun
```

### 2. Frontend (Flutter)
Yêu cầu: Flutter SDK (Dart 3.x).
```bash
cd frontend
flutter pub get
flutter run
```
