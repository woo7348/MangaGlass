# MangaGlass
MacOS 용 실시간 번역앱.
### 기본 개요
-	macOS 전용 실시간 만화 번역 앱
-	스크린 캡처 기반의 OCR + 번역 + 오버레이 UI 제공
-	주 대상: 일본 만화 팬, 영상 번역 크리에이터 등

🧠 핵심 기능

### 🖼 OCR & 번역
-	Google Vision OCR 사용
-	말풍선 단위 또는 문장 단위 병합 모드 제공
-	세로쓰기/가로쓰기 모드 지원
-	병합 기준 수동 조정 가능 (X/Y 간격, 병합 방식 등)
-	Google Translate API 사용

### 🪟 오버레이 UI
-	Overlay 1: 번역 대상 영역 선택
- Overlay 2: 번역 결과 표시
-	Overlay 위치/크기 동기화 또는 독립 설정 가능
- 상태 표시 레이어 분리
- 현재는 Overlay 1 통합 구조 + 팝오버 대신 독립 창 구조로 리팩토링됨

### 🧩 번역 설정 UI
-	번역 실행 버튼 제공
-	언어 선택 가능 (원문/대상 언어)
-	말풍선 병합 vs 문장 병합 모드 선택 가능

### 🔒 무료 사용 제한 + 유료화 준비
-	UUID 기반 중복 사용 방지
-	무료 사용 횟수 제한
-	구독형 모델을 기반으로 한 유료화 계획

 # MangaGlass

**MangaGlass** is a macOS application that provides real-time manga translation using OCR and overlay UI. Designed for manga readers and content creators, it offers seamless capture, recognition, and translation of Japanese text directly on your screen.

---

## 🧩 Features

### 🖼 Real-time OCR & Translation
- Capture screen regions with precise bounding boxes
- Google Cloud Vision OCR support
- Sentence-based or speech bubble-based text merging
- Vertical and horizontal writing modes supported
- Manual merge thresholds for X/Y distance
- Google Translate API for fast, multilingual translation

### 🪟 Overlay Interface
- **Overlay 1**: Selection area for translation
- **Overlay 2**: Translation result display (optionally hidden or detached)
- Auto-sync position/size between overlays
- State label window separated to avoid OCR interference

### ⚙️ Translation Settings UI
- Independent window for translation settings
- Select source/target language
- Choose between merge modes (speech bubble vs sentence)
- Real-time adjustment of merge thresholds and reading direction

### 🔐 Usage Limits & Monetization
- Free usage limit per device (UUID-based)
- Prevention of repeated free trials
- Planned subscription model for global users

---

## 📦 Installation

Coming soon via `.dmg` package for macOS.

---

## 🛠 Development

Built with Swift (SwiftUI) using MVVM architecture.  
Currently in MVP phase. Subscription integration and UI polish in progress.

---


## 🙌 Contributing

PRs welcome! Please submit issues for bugs or feature requests.
