# 다른 PC에서 4wire-simple.py 실행 준비 가이드

> ⚠️ **대상 PC는 인터넷 미연결 환경** → 인터넷 되는 PC에서 파일을 미리 받아 USB로 이동

---

## 전체 흐름

```
[인터넷 되는 PC]                         [측정용 PC (인터넷 없음)]
  ① Python 설치 파일 다운로드  ──USB──▶  ① Python 설치
  ② NI-VISA 설치 파일 다운로드 ──USB──▶  ② NI-VISA 설치 + PC 재시작
  ③ pyvisa 패키지 파일 다운로드──USB──▶  ③ pyvisa 오프라인 설치
  ④ 4wire-simple 폴더 복사    ──USB──▶  ④ 파일 복사
                                         ⑤ 실행
```

---

## [인터넷 PC에서] 사전 준비: USB에 받아야 할 파일들

USB 드라이브에 아래 폴더 구조로 저장하세요:

```
USB드라이브/
├── 01_python/
│   └── python-3.x.x-amd64.exe          ← Python 설치 파일
├── 02_nivisa/
│   └── NI-VISA-xx.x.x-Online.exe       ← NI-VISA 설치 파일
├── 03_pyvisa_packages/
│   ├── pyvisa-x.x.x-py3-none-any.whl   ← pip download로 받은 파일들
│   └── pyvisa_py-x.x.x-py3-none-any.whl
└── 04_4wire-simple/
    └── (4wire-simple 폴더 전체)
```

---

### 파일 1: Python 설치 파일 다운로드

- **다운로드 사이트:** https://www.python.org/downloads/
- 최신 버전 페이지 → `Windows installer (64-bit)` 클릭
- 파일명 예시: `python-3.12.2-amd64.exe`
- USB의 `01_python/` 폴더에 저장

---

### 파일 2: NI-VISA 설치 파일 다운로드

- **다운로드 사이트:** https://www.ni.com/ko-kr/support/downloads/drivers/download.ni-visa.html
- 최신 버전 선택 → `다운로드` 클릭
- NI 계정 없으면 무료 회원가입 후 다운로드
- 파일 크기: 약 600MB~1GB
- USB의 `02_nivisa/` 폴더에 저장

---

### 파일 3: pyvisa 패키지 오프라인용 다운로드

인터넷 PC의 **명령 프롬프트(cmd)** 에서 실행:

```
pip download pyvisa pyvisa-py -d C:\USB경로\03_pyvisa_packages\
```

예시 (USB가 D드라이브인 경우):
```
pip download pyvisa pyvisa-py -d D:\03_pyvisa_packages\
```

→ `.whl` 파일 2~3개가 해당 폴더에 저장됨

---

### 파일 4: 측정 폴더 복사

`4wire-simple/` 폴더 전체를 USB의 `04_4wire-simple/`에 복사

```
4wire-simple/
├── src/
│   └── 4wire-simple.py
└── results/
```

---

## [측정용 PC에서] 설치 및 실행

### 1단계: Python 설치

1. USB의 `01_python/python-3.x.x-amd64.exe` 실행
2. ⚠️ **중요:** 설치 첫 화면에서 **"Add python.exe to PATH"** 반드시 체크
3. `Install Now` 클릭 → 완료 후 `Close`

**설치 확인:**
```
python --version
```
→ `Python 3.12.2` 출력되면 정상

---

### 2단계: NI-VISA 드라이버 설치

1. USB의 `02_nivisa/` 폴더에서 설치 파일 실행
2. 설치 마법사 → `다음` 계속 클릭
3. 라이선스 동의 후 설치
4. ⚠️ **설치 완료 후 PC 재시작 필수**

**설치 확인:**
- 시작 메뉴에서 `NI MAX` 검색하여 실행되면 정상

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
3. 약 10~30초 대기 (드라이버 자동 인식)

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
[10] ...
측정 완료. 총 10개 파일이 results/ 에 저장되었습니다.
```
→ 완료 후 `results/` 폴더 자동으로 열림

---

## 문제 해결

### 장비가 인식되지 않을 때
- NI-VISA 설치 후 재시작했는지 확인
- 다른 USB 포트에 연결해 보기
- 장비관리자(Device Manager) → 노란 느낌표 여부 확인
- NI MAX 프로그램에서 장비 목록 확인

### `ModuleNotFoundError: No module named 'pyvisa'`
- pyvisa 오프라인 설치 명령어 다시 실행
- USB 드라이브 경로가 정확한지 확인

### `No resources found` (장비 목록 비어있음)
- Keithley 2460 전원이 켜져 있는지 확인
- USB 케이블 재연결 후 재시도

---

## 최종 요약표

| 순서 | 장소 | 작업 | 다운로드 사이트 |
|------|------|------|----------------|
| 사전 ① | 인터넷 PC | Python 설치 파일 다운로드 | https://www.python.org/downloads/ |
| 사전 ② | 인터넷 PC | NI-VISA 설치 파일 다운로드 | https://www.ni.com/ko-kr/support/downloads/drivers/download.ni-visa.html |
| 사전 ③ | 인터넷 PC | `pip download pyvisa pyvisa-py -d USB경로` | (pip 명령어로 자동 다운로드) |
| 사전 ④ | 인터넷 PC | 4wire-simple 폴더 USB 복사 | - |
| 1 | 측정용 PC | Python 설치 (PATH 체크 필수) | USB에서 실행 |
| 2 | 측정용 PC | NI-VISA 설치 + **재시작** | USB에서 실행 |
| 3 | 측정용 PC | `pip install --no-index --find-links=USB경로 pyvisa pyvisa-py` | USB에서 오프라인 설치 |
| 4 | 측정용 PC | 4wire-simple 폴더 복사 | USB에서 복사 |
| 5 | 측정용 PC | `python src/4wire-simple.py` 실행 | - |
