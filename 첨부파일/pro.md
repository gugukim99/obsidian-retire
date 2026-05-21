# my-tools 실행 흐름 — 전체 경로 가이드

> 예시 발명: **"SU-8 레이저-플라즈마 복합 에칭 장치"**  
> 사용자 발화: `"SU-8 감광막 에칭 장치 발명내용설명서 작성해줘"`  
> 출력 디렉터리: `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\`

---

## 0단계: 설치 (최초 1회)

**무슨 일이 일어나는가**  
`setup.ps1`이 이 프로젝트의 스킬·플러그인·커맨드를 Claude Code 가 읽는 폴더로 복사한다.

| 역할 | 원본 경로 | 복사 대상 경로 |
|------|----------|--------------|
| 설치 진입점 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\setup.ps1` | (실행만 함) |
| 스킬 전체 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\skills\*` | `C:\Users\user\.claude\skills\*` |
| 플러그인 전체 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\plugins\*` | `C:\Users\user\.claude\plugins\cache\my-tools\*` |
| 슬래시 커맨드 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\commands\*.md` | `C:\Users\user\.claude\commands\*.md` |
| 설정 템플릿 렌더러 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\claude-config\apply-config.py` | (실행만 함) |
| settings.json 템플릿 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\claude-config\settings.json.template` | `C:\Users\user\.claude\settings.json` |
| CLAUDE.md 템플릿 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\claude-config\CLAUDE.md.template` | `C:\Users\user\.claude\CLAUDE.md` |

**출력물**: 없음 (배포 완료 상태)

---

## Phase 0: 입력 수집

**무슨 일이 일어나는가**  
Claude Code가 스킬 트리거를 인식하고 `SKILL.md`를 로드한다.  
사용자에게 기술분야·해결과제·핵심아이디어·발명자명을 질문하고 JSON으로 저장한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| 스킬 오케스트레이터 (지휘관) | `C:\Users\user\.claude\skills\patent-incubation-auto\SKILL.md` | 8개 Phase 전체 흐름을 정의한 757줄짜리 지시서. 어떤 에이전트를 언제 어떤 모델로 실행할지 기술 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `invention_manifest.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\invention_manifest.json` | 발명 기본정보(기술분야, 해결과제, 아이디어, 발명자)와 각 Phase 진행 상태를 기록하는 중앙 추적 파일 |

---

## Phase 1: TRIZ 시스템 분석

**무슨 일이 일어나는가**  
Sonnet 모델이 발명을 시스템 관점으로 분해한다.  
구성요소(레이저, 플라즈마, 감광막 등), 기능, 부작용, 기술 파라미터를 추출한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 1 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase1-triz-system.md` | Sonnet에게 "시스템 구성요소를 TRIZ 관점으로 분석하라"고 지시하는 LLM 프롬프트 파일 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `triz_system.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\triz_system.json` | 시스템 구성요소 목록, 각 요소의 기능과 부작용, 개선해야 할 기술 파라미터 목록 |

---

## Phase 2: 모순 도출 + IFR 생성

**무슨 일이 일어나는가**  
Opus 모델이 TRIZ 40가지 발명원리를 참조해 기술 모순·물리 모순을 찾고,  
최종 이상해(IFR, Ideal Final Result)를 최소 10개 생성한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 2 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase2-contradiction-ifr.md` | Opus에게 모순 분석과 IFR 생성을 지시하는 LLM 프롬프트 파일 |
| TRIZ 40원리 참고자료 | `C:\Users\user\.claude\skills\patent-incubation-auto\reference\triz-40-principles.md` | 40가지 TRIZ 발명 원리 설명. 에이전트가 모순 해결책 도출 시 참조 |
| TRIZ 분리원리 참고자료 | `C:\Users\user\.claude\skills\patent-incubation-auto\reference\triz-separation-principles.md` | 물리 모순 해결을 위한 4가지 분리 원리(시간/공간/조건/전체-부분) |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `triz_analysis.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\triz_analysis.json` | 기술 모순 N개, 물리 모순 N개, 각 모순에 적용된 발명원리, IFR 목록(최소 10개)과 각 IFR의 해결 방향 |

---

## Phase 3: 사용자 확인 게이트 (중간 검토)

**무슨 일이 일어나는가**  
Claude가 Phase 2 결과를 표로 정리해서 사용자에게 보여준다.  
사용자는 자동 진행 / 피드백 제공 / 재분석 중 선택한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| (별도 파일 없음) | — | SKILL.md 안에 정의된 게이트 로직. 파일 호출 없이 Claude가 직접 표 출력 후 대기 |

**출력물**: 없음 (사용자 결정만 manifest.json에 기록)

---

## Phase 4: IFR 정량 평가

**무슨 일이 일어나는가**  
Sonnet 모델이 10개 이상의 IFR을 3가지 축(창의성, 체계성, 난제해결도)으로 점수 매기고 순위를 정한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 4 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase4-evaluator.md` | Sonnet에게 IFR 정량 평가 방법을 지시하는 프롬프트 파일 |
| 평가 기준표 템플릿 | `C:\Users\user\.claude\skills\patent-incubation-auto\templates\evaluation-matrix.md` | 창의성·체계성·난제해결도 3축의 채점 기준과 가중치 정의 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `evaluation.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\evaluation.json` | IFR별 3축 점수, 총점, 순위. Phase 6 명세서 작성 시 "어떤 IFR을 중심으로 쓸지" 근거 데이터 |

---

## Phase 5: 선행특허 조사

**무슨 일이 일어나는가**  
상위 IFR 키워드로 KIPRIS API를 호출해 국내 특허를 검색한다.  
유사 특허 목록과 신규성 차이를 정리한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 5 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase5-prior-art.md` | Sonnet에게 선행특허 조사 방법을 지시하는 프롬프트 파일 |
| KIPRIS 검색 스크립트 | `C:\Users\user\.claude\skills\patent-incubation-auto\scripts\search_patents_kipris.py` | KIPRIS Plus REST API를 호출하는 Python 스크립트. 키워드·IPC코드·출원인으로 검색 후 CSV 반환 |
| API 키 환경파일 | `C:\Users\user\Claude_Work\.env` | `KIPRIS_REST_AccessKey=...` 가 저장된 환경변수 파일 (프로젝트 외부) |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `prior_art.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\prior_art.json` | 검색된 유사특허 목록(출원번호, 제목, 출원인), 각 특허와 본 발명의 신규성 차이 분석 |
| `kipris_prefetch.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\kipris_prefetch.json` | KIPRIS API 원본 응답 캐시. API 재호출 없이 재분석 가능하도록 보관 |
| `SU-8 레이저-플라즈마 복합 에칭 장치_선행특허분석.md` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\SU-8 레이저-플라즈마 복합 에칭 장치_선행특허분석.md` | 선행특허 분석 결과를 Obsidian 형식으로 정리한 마크다운 보고서 |

---

## Phase 6: 발명내용설명서 본문 작성

**무슨 일이 일어나는가**  
Opus 모델이 §1~§9 본문 9개 섹션과 부록 A·B·C를 작성한다.  
TRIZ 용어는 부록에만 허용, 본문은 평이한 기술 언어로 작성.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 6 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase6-disclosure-writer.md` | Opus에게 9개 섹션 + 3개 부록의 작성 규칙을 지시하는 프롬프트 파일 |
| 발명자 철학 참고자료 | `C:\Users\user\.claude\skills\patent-incubation-auto\reference\user-philosophy.md` | 발명자의 사고 패턴, 선호 표현 방식, 반복되는 기술 접근법 메모 |
| 명세서 구조 템플릿 | `C:\Users\user\.claude\skills\patent-incubation-auto\templates\disclosure-report.md` | §1~§9 + 부록 A·B·C 섹션 헤더와 작성 지침 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `(20260520 미입력) SU-8 레이저-플라즈마 복합 에칭 장치v1.md` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\(20260520 미입력) SU-8 레이저-플라즈마 복합 에칭 장치v1.md` | §1기술분야 §2해결과제 §3선행기술 §4목표 §5구성 §6우수성 §7효과 §8청구범위 §9추가자료 + 부록ABC가 포함된 마크다운 전문 명세서 |

---

## Phase 6b: 기술 도면 생성

**무슨 일이 일어나는가**  
Sonnet 모델이 matplotlib Python 코드를 생성해 실행하고 PNG 도면 3개 이상을 만든다.  
시스템 구성도, 공정 흐름도, 선행기술 비교도가 기본.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 6b 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase6b-diagram-generator.md` | Sonnet에게 matplotlib 도면 코드 생성 규칙과 한글 폰트(Malgun Gothic) 설정을 지시하는 프롬프트 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `diagrams\fig1.png` 등 | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\diagrams\` | 시스템 구성도, 공정 흐름도 등 PNG 도면. §9(추가자료)에 자동 삽입됨. 150 DPI |
| `device.png` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\device.png` | 장치 개념도 (별도 생성된 도면) |

---

## Phase 6c: 인용문헌 검증 + PDF 수집

**무슨 일이 일어나는가**  
명세서 본문에서 참고문헌을 추출해 실제 존재 여부를 확인한다.  
KR 특허는 KIPRIS API로, 논문은 DOI·OpenAlex로 검증하고 PDF를 다운로드한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 6c 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase6c-reference-verifier.md` | Sonnet에게 인용문헌 파싱→API 검증→PDF 수집→마커 표시 순서를 지시하는 프롬프트 |
| Obsidian References 캐시 | `D:\Zettelkasten\References\` | 이미 다운로드된 논문 PDF 보관소. 여기서 먼저 찾고 없으면 인터넷 다운로드 |

**출력물**

| 파일 | 경로 | 내용 |
|------|------|------|
| `reference\*.pdf` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\reference\` | 검증된 특허·논문 PDF 파일들 |
| `reference_verification.json` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\reference_verification.json` | 각 인용문헌의 검증 결과(정합확인/불일치/수동검토 필요)와 PDF 확보 여부 |

---

## Phase 7: HWPX 변환 (최종 파일 생성)

**무슨 일이 일어나는가**  
Phase 6의 마크다운 명세서를 KIMM 공식 양식 HWPX에 채워 넣는다.  
Python 스크립트가 양식 파일을 열고 §1~§9를 해당 셀에 삽입, 도면 PNG를 §9에 첨부한 후 저장한다.  
최종적으로 hwpx-tools 플러그인의 검증 스크립트로 파일 무결성을 확인한다.

| 역할 | 파일 전체 경로 | 내용 설명 |
|------|--------------|----------|
| Phase 7 에이전트 프롬프트 | `C:\Users\user\.claude\skills\patent-incubation-auto\agents\phase7-hwpx-converter.md` | Sonnet에게 convert_hwpx.py 실행 방법과 에러 처리를 지시하는 프롬프트 |
| HWPX 변환 스크립트 (핵심) | `C:\Users\user\.claude\skills\patent-incubation-auto\scripts\convert_hwpx.py` | 840줄 Python 스크립트. MD를 파싱해 KIMM 양식 HWPX의 각 셀에 텍스트·이미지를 삽입 |
| KIMM 공식 양식 | `C:\Users\user\.claude\skills\patent-incubation-auto\assets\[KIMM]직무발명내용설명서_양식.hwpx` | KIMM 직무발명내용설명서 공식 빈 양식. 이 파일을 복사해서 내용을 채움 |
| 셀 위치 매핑표 | `C:\Users\user\.claude\skills\patent-incubation-auto\reference\kimm-template-mapping.md` | §1이 몇 번 테이블의 몇 행 몇 열인지 좌표 매핑 정보 |
| 네임스페이스 수정 스크립트 | `C:\Users\user\.claude\plugins\cache\my-tools\hwpx-tools\skills\hwpx\fix_namespaces.py` | HWPX XML의 네임스페이스 선언 오류를 자동 수정 (한글에서 열리지 않는 문제 방지) |
| HWPX 구조 검증 스크립트 | `C:\Users\user\.claude\plugins\cache\my-tools\hwpx-tools\skills\hwpx-xml\validate.py` | ZIP 무결성, 필수 파일 존재, XML 형식 정상 여부 확인 |

**출력물 (최종)**

| 파일 | 경로 | 내용 |
|------|------|------|
| `(20260520 미입력) SU-8 레이저-플라즈마 복합 에칭 장치v1.hwpx` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\(20260520 미입력) SU-8 레이저-플라즈마 복합 에칭 장치v1.hwpx` | **한글(HWP)에서 바로 열 수 있는 최종 제출용 발명내용설명서**. §1~§9 + 도면 포함 |
| `CCP_RIE_266laser_SU8_직무발명내용설명서.hwpx` | `D:\0AI_DATA\patent-incubation-auto-KJH\my-tools\Works\Test\CCP_RIE_266laser_SU8_직무발명내용설명서.hwpx` | 동일 발명의 다른 버전 HWPX (별도 생성) |

---

## 전체 흐름 한눈에 보기

```
사용자 발화
    │
    ▼
C:\Users\user\.claude\skills\patent-incubation-auto\SKILL.md  (지휘관)
    │
    ├─ Phase 0 ──────────────────────────────── invention_manifest.json
    │
    ├─ Phase 1  agents\phase1-triz-system.md ── triz_system.json
    │
    ├─ Phase 2  agents\phase2-contradiction-ifr.md
    │           reference\triz-40-principles.md ── triz_analysis.json
    │
    ├─ Phase 3  [사용자 확인 게이트] ────────── (승인/수정/재분석)
    │
    ├─ Phase 4  agents\phase4-evaluator.md
    │           templates\evaluation-matrix.md ── evaluation.json
    │
    ├─ Phase 5  agents\phase5-prior-art.md
    │           scripts\search_patents_kipris.py ── prior_art.json
    │                                               kipris_prefetch.json
    │                                               선행특허분석.md
    │
    ├─ Phase 6  agents\phase6-disclosure-writer.md
    │           reference\user-philosophy.md ── 발명명칭v1.md  ★
    │
    ├─ Phase 6b agents\phase6b-diagram-generator.md ── diagrams\*.png
    │
    ├─ Phase 6c agents\phase6c-reference-verifier.md
    │           Zettelkasten\References\ ── reference\*.pdf
    │                                       reference_verification.json
    │
    └─ Phase 7  agents\phase7-hwpx-converter.md
                scripts\convert_hwpx.py
                assets\[KIMM]직무발명내용설명서_양식.hwpx
                plugins\hwpx-tools\fix_namespaces.py
                plugins\hwpx-tools\validate.py
                    │
                    ▼
             발명명칭v1.hwpx  ★★  (최종 제출 파일)
```

---

## 보조 도구 — 언제 호출되는가

| 플러그인/도구 | 경로 | 호출 시점 |
|-------------|------|----------|
| hwpx-tools (fix_namespaces) | `C:\Users\user\.claude\plugins\cache\my-tools\hwpx-tools\skills\hwpx\fix_namespaces.py` | Phase 7: 모든 HWPX 생성 후 |
| hwpx-xml (validate) | `C:\Users\user\.claude\plugins\cache\my-tools\hwpx-tools\skills\hwpx-xml\validate.py` | Phase 7: HWPX 저장 직후 |
| patent-tools (patent-strategy-pro) | `C:\Users\user\.claude\plugins\cache\my-tools\patent-tools\skills\patent-strategy-pro\SKILL.md` | 독립 호출: "특허 전략 보고서" 요청 시 |
| visual-generator | `C:\Users\user\.claude\plugins\cache\my-tools\visual-generator\` | 독립 호출: "슬라이드 만들어줘" 요청 시 |
| mineru-tools | `C:\Users\user\.claude\plugins\cache\my-tools\mineru-tools\convert_mineru.py` | Phase 5/6c: 특허·논문 PDF 파싱 시 |
