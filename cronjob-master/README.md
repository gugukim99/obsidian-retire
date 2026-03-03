# AI 자동화 시스템

Claude Code CLI를 활용한 자동화 스크립트 모음입니다. 정해진 주기로 웹 뉴스를 수집하고, 새로 생성된 문서를 자동으로 요약합니다.

---

## 전체 구조

```
메추라기\
├── input\          작업 파일 입력 (watch.ps1 전용)
├── output\         분석 결과 저장
├── archive\        처리 완료 파일 보관
├── news\           수집된 뉴스 마크다운 파일
├── summaries\      뉴스 자동 요약본
├── logs\           각 스크립트 실행 로그
└── scripts\
    ├── fetch_news.ps1         10분마다 웹 뉴스 수집
    ├── watch_summarize.ps1    새 .md 파일 감지 시 자동 요약
    ├── watch.ps1              input\ 폴더 감시 (기본 실습)
    └── run_all.ps1            전체 스크립트 동시 실행 런처
```

---

## 핵심 기능

### 1. 뉴스 수집기 (`fetch_news.ps1`)

10분 간격으로 Claude에게 웹 검색을 요청하여 최신 뉴스 5건을 마크다운 문서로 저장합니다.

| 항목 | 값 |
|------|-----|
| 실행 주기 | 600초 (10분) |
| 저장 위치 | `news\news_YYYYMMDD_HHmmss.md` |
| 로그 파일 | `logs\fetch_news.log` |

**동작 흐름:**

```
루프 시작
  → Claude에게 "최신 뉴스 5건을 검색해서 .md로 저장해줘" 요청
  → 파일 생성 확인
  → 실패 시 stdout 리다이렉트 방식으로 재시도 (폴백)
  → 10분 대기
```

**생성되는 파일 예시:**

```markdown
# 오늘의 주요 뉴스 (2026년 03월 02일 19:55 수집)

## 1. 뉴스 제목
- **요약**: 핵심 내용 2~3줄
- **출처**: 언론사명 / URL

## 2. ...
```

### 2. 문서 요약기 (`watch_summarize.ps1`)

`news\` 폴더를 30초마다 확인하여, 아직 요약되지 않은 `.md` 파일을 발견하면 Claude가 자동으로 요약합니다.

| 항목 | 값 |
|------|-----|
| 확인 주기 | 30초 |
| 감시 대상 | `news\*.md` |
| 저장 위치 | `summaries\summary_원본파일명.md` |
| 로그 파일 | `logs\watch_summarize.log` |

**중복 처리 방지:**

`summaries\summary_{원본파일명}` 이 이미 존재하면 건너뜁니다. 즉 같은 뉴스 파일을 두 번 요약하지 않습니다.

**동작 흐름:**

```
루프 시작
  → news\ 폴더의 모든 .md 파일 목록 가져오기
  → 각 파일에 대해:
      summaries\summary_파일명 이 있으면 건너뛰기 (이미 요약됨)
      없으면 → Claude에게 "파일을 읽고 요약해서 저장해줘" 요청
      실패 시 → 원본 내용을 프롬프트에 직접 포함하여 재시도 (폴백)
  → 30초 대기
```

**생성되는 요약 예시:**

```markdown
# 요약: news_20260302_195500.md
> 원본: C:\...\news\news_20260302_195500.md
> 요약 시각: 2026-03-02 20:00:15

## 핵심 요약 (3~5줄)
- 포인트 1
- 포인트 2

## 키워드
- 키워드1, 키워드2
```

### 3. 두 기능의 연결

```
fetch_news.ps1                    watch_summarize.ps1
──────────────                    ───────────────────
10분마다 실행                      30초마다 확인
      │                                 │
      ▼                                 ▼
news\news_20260302_195500.md  ──→  감지! 요약 시작
                                         │
                                         ▼
                              summaries\summary_news_20260302_195500.md
```

뉴스가 수집되면 최대 30초 이내에 자동 요약이 시작됩니다.

---

## 실행 방법

### 전체 실행 (권장)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_all.ps1
```

3개 스크립트(`watch.ps1`, `fetch_news.ps1`, `watch_summarize.ps1`)가 각각 **별도 PowerShell 창**으로 실행됩니다. 각 창의 제목표시줄에 `[AI] 뉴스 수집기` 등으로 표시되어 구분이 쉽습니다.

**종료**: 런처 창에서 `Ctrl+C`를 누르면 3개 프로세스가 모두 자동 종료됩니다.

### 개별 실행

```powershell
# 뉴스 수집만
powershell -ExecutionPolicy Bypass -File scripts\fetch_news.ps1

# 문서 요약만
powershell -ExecutionPolicy Bypass -File scripts\watch_summarize.ps1

# 폴더 감시만 (기본 실습)
powershell -ExecutionPolicy Bypass -File scripts\watch.ps1
```

---

## 사전 요구사항

| 항목 | 확인 방법 |
|------|-----------|
| Claude Code CLI | `claude --version` 실행 시 버전이 출력되어야 함 |
| PowerShell 5.1+ | Windows 10/11에 기본 포함 |

Claude Code CLI 설치:
```powershell
npm install -g @anthropic-ai/claude-code
```

---

## 로그 확인

모든 스크립트는 `logs\` 폴더에 개별 로그 파일을 생성합니다.

```powershell
# 실시간 로그 확인
Get-Content logs\fetch_news.log -Wait
Get-Content logs\watch_summarize.log -Wait

# 전체 로그 확인
Get-Content logs\run_all.log
```

로그 형식:
```
[2026-03-02 19:55:00] [fetch_news] 뉴스 수집을 시작합니다...
[2026-03-02 19:55:30] [fetch_news] 뉴스 저장 완료: news_20260302_195500.md (2048 bytes)
[2026-03-02 19:55:35] [summarize] 새 문서 발견: news_20260302_195500.md - 요약을 시작합니다...
```

---

## 주기 변경

각 스크립트 상단의 변수를 수정하면 됩니다.

| 스크립트 | 변수 | 기본값 | 설명 |
|---------|------|--------|------|
| `fetch_news.ps1` | `$Interval` | `600` | 뉴스 수집 간격 (초) |
| `watch_summarize.ps1` | `$CheckInterval` | `30` | 폴더 확인 간격 (초) |
| `watch.ps1` | (하단 `Start-Sleep`) | `300` | 폴더 감시 간격 (초) |

---

## 폴백 메커니즘

두 핵심 스크립트 모두 2단계 실행 방식을 갖추고 있습니다.

**1단계** — Claude에게 파일 경로를 지정하여 직접 저장을 요청합니다.

```
claude -p "... 결과를 C:\...\news\news_20260302.md 파일에 저장해줘"
```

**2단계 (폴백)** — 1단계에서 파일이 생성되지 않으면, Claude의 stdout 출력을 파일로 리다이렉트합니다.

```powershell
$result = claude -p "... 마크다운으로 출력해줘"
$result | Out-File -FilePath $OutputPath -Encoding UTF8
```

이를 통해 Claude의 도구 사용 가능 여부와 관계없이 파일이 안정적으로 생성됩니다.

---

## 참고: 기본 폴더 감시 (`watch.ps1`)

`input\` 폴더에 `new_task.txt` 파일을 넣으면 Claude가 자동으로 분석하여 `output\`에 결과를 저장하고, 원본은 `archive\`로 이동합니다. 뉴스 수집/요약과 독립적으로 동작합니다.
