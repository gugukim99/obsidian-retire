# 다른 PC에서 4wire-simple.py 실행 준비 가이드

> ⚠️ **대상 PC 환경: Windows 7, 인터넷 미연결**
> ⚠️ Keithley 전용 드라이버 사용 (NI-VISA 불필요)

---

## 전체 흐름

```
[인터넷 되는 PC]                              [측정용 PC (Windows 7, 인터넷 없음)]
  ① Python 3.8 설치 파일 다운로드  ──USB──▶  ① Python 3.8 설치
  ② Keithley I/O Layer 다운로드   ──USB──▶  ② Keithley I/O Layer 설치 + 재시작
  ③ pyvisa 패키지 파일 다운로드   ──USB──▶  ③ pyvisa 오프라인 설치
  ④ 4wire-simple 폴더 복사        ──USB──▶  ④ 파일 복사
                                             ⑤ 실행
```

---

## NI-VISA 대신 Keithley I/O Layer를 쓰는 이유

| 항목 | NI-VISA | Keithley I/O Layer |
|------|---------|-------------------|
| 제조사 | National Instruments | Keithley (Tektronix) |
| 용량 | 600MB~1GB | 약 50~100MB |
| Keithley 호환성 | 호환됨 | 전용 드라이버, 더 안정적 |
| Windows 7 지원 | 버전에 따라 다름 | 지원 |
| 권장 여부 | Keithley 장비에 불필요 | ✅ Keithley 장비 전용 권장 |

---

## [인터넷 PC에서] 사전 준비: USB에 받아야 할 파일들

USB 드라이브에 아래 폴더 구조로 저장:

```
USB드라이브/
├── 01_python/
│   └── python-3.8.x-amd64.exe           ← Python 3.8 설치 파일
├── 02_keithley_io/
│   └── KI-IO-Layer_x.x.x.exe            ← Keithley I/O Layer 설치 파일
├── 03_pyvisa_packages/
│   ├── pyvisa-x.x.x-py3-none-any.whl
│   └── pyvisa_py-x.x.x-py3-none-any.whl
└── 04_4wire-simple/
    └── (4wire-simple 폴더 전체)
```

---

### 파일 1: Python 3.8 설치 파일 다운로드

> ⚠️ Windows 7은 Python **3.8만** 지원 (3.9 이상은 Windows 7 미지원)

- **다운로드 사이트:** https://www.python.org/downloads/release/python-3819/
- 페이지 하단 `Files` 섹션에서 **`Windows x86-64 executable installer`** 클릭
- 파일명: `python-3.8.x-amd64.exe`
- USB의 `01_python/` 폴더에 저장

---

### 파일 2: Keithley I/O Layer 다운로드

- **다운로드 사이트:** https://www.tek.com/en/support/software/application/850c10
  - Windows 7 호환 버전: **KIOL-850C10** (Windows 11/10/8/7 모두 지원)
- 페이지에서 `Download` 클릭
- Tektronix 계정 없으면 무료 회원가입 후 다운로드
- USB의 `02_keithley_io/` 폴더에 저장

---

### 파일 3: pyvisa 패키지 오프라인용 다운로드

인터넷 PC의 **명령 프롬프트(cmd)** 에서 실행:

```
pip download pyvisa pyvisa-py -d D:\03_pyvisa_packages\
```
(USB가 D드라이브인 경우)

→ `.whl` 파일 2~3개가 해당 폴더에 저장됨

---

### 파일 4: 측정 폴더 복사

`4wire-simple/` 폴더 전체를 USB의 `04_4wire-simple/`에 복사

---

## [측정용 PC에서] 설치 및 실행

### 1단계: Python 3.8 설치

1. USB의 `01_python/python-3.8.x-amd64.exe` 실행
2. ⚠️ **중요:** 설치 첫 화면에서 **"Add Python 3.8 to PATH"** 반드시 체크
3. `Install Now` 클릭 → 완료 후 `Close`

**설치 확인** (시작 → cmd):
```
python --version
```
→ `Python 3.8.x` 출력되면 정상

---

### 2단계: Keithley I/O Layer 설치

1. USB의 `02_keithley_io/` 폴더에서 설치 파일 실행
2. 설치 마법사 → `다음` 계속 클릭 → 라이선스 동의 → 설치
3. ⚠️ **설치 완료 후 PC 재시작 필수**

**설치 확인:**
- 시작 메뉴에서 `Keithley Communicator` 또는 `KI-IO` 검색하여 실행되면 정상

---

### 3단계: pyvisa 오프라인 설치

> PC 재시작 후 진행

명령 프롬프트(cmd)에서 실행 (USB가 D드라이브인 경우):

```
pip install --no-index --find-links=D:\03_pyvisa_packages\ pyvisa pyvisa-py
```

**설치 확인:**
```
python -c "import pyvisa; print(pyvisa.__version__)"
```
→ 버전 번호 출력되면 정상 (예: `1.14.1`)

---

### 4단계: 측정 폴더 복사

USB의 `04_4wire-simple/` 폴더를 측정용 PC의 원하는 위치에 복사

예시:
```
C:\Users\사용자이름\Desktop\4wire-simple\
```

---

### 5단계: 연결 확인 및 실행

**USB 연결:**
1. Keithley 2460 전원 ON
2. USB 케이블로 PC와 Keithley 2460 연결
3. 약 10~30초 대기

**장비 인식 확인:**
```
python -c "import pyvisa; rm = pyvisa.ResourceManager(); print(rm.list_resources())"
```
정상 출력 예시:
```
('USB0::0x05E6::0x2460::04479940::INSTR', 'ASRL1::INSTR')
```
→ `USB0::0x05E6::0x2460` 포함되면 인식 성공

**프로그램 실행:**
```
cd C:\Users\사용자이름\Desktop\4wire-simple
python src/4wire-simple.py
```

**정상 실행 화면:**
```
검색된 장비: ('USB0::0x05E6::0x2460::04479940::INSTR', ...)
연결 장비: USB0::0x05E6::0x2460::04479940::INSTR
장비 확인: KEITHLEY INSTRUMENTS,MODEL 2460,...

출력 전류: 50 uA
측정 횟수: 10회 (간격: 1.0초)

[01] 2026-03-04 17:43:49  V=6.48e-01 V  R=12966.58 Ω  Rs=58769.19 Ω/sq
       → 저장: ...\results\측정01_20260304_174349.csv
...
측정 완료. 총 10개 파일이 results/ 에 저장되었습니다.
```

---

## 문제 해결

### 장비가 인식되지 않을 때
- Keithley I/O Layer 설치 후 재시작했는지 확인
- 다른 USB 포트에 연결
- 장비관리자(Device Manager) → 노란 느낌표 여부 확인
- Keithley Communicator 프로그램에서 장비 목록 확인

### `ModuleNotFoundError: No module named 'pyvisa'`
- pyvisa 오프라인 설치 명령어 다시 실행
- USB 드라이브 경로가 정확한지 확인

### `No resources found` (장비 목록 비어있음)
- Keithley 2460 전원이 켜져 있는지 확인
- USB 케이블 재연결 후 재시도

### Python 설치가 안 될 때 (Windows 7)
- 반드시 **Python 3.8** 사용 (3.9 이상은 Windows 7 미지원)
- Windows 7 SP1 + KB2533623 업데이트 필요할 수 있음
  - Microsoft 업데이트 카탈로그에서 `KB2533623` 검색하여 오프라인 설치

---

## 최종 요약표

| 순서 | 장소 | 작업 | 다운로드 사이트 |
|------|------|------|----------------|
| 사전 ① | 인터넷 PC | Python **3.8** 설치 파일 다운로드 | https://www.python.org/downloads/release/python-3819/ |
| 사전 ② | 인터넷 PC | Keithley I/O Layer 다운로드 | https://www.tek.com/en/support/software/application/850c10 |
| 사전 ③ | 인터넷 PC | `pip download pyvisa pyvisa-py -d USB경로` | pip 명령어로 자동 다운로드 |
| 사전 ④ | 인터넷 PC | 4wire-simple 폴더 USB 복사 | - |
| 1 | 측정용 PC | Python 3.8 설치 (PATH 체크 필수) | USB에서 실행 |
| 2 | 측정용 PC | Keithley I/O Layer 설치 + **재시작** | USB에서 실행 |
| 3 | 측정용 PC | `pip install --no-index --find-links=USB경로 pyvisa pyvisa-py` | USB 오프라인 설치 |
| 4 | 측정용 PC | 4wire-simple 폴더 복사 | USB에서 복사 |
| 5 | 측정용 PC | `python src/4wire-simple.py` 실행 | - |
