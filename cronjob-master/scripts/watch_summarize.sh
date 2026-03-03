#!/bin/bash
# =============================================================================
# watch_summarize.sh - 새 .md 파일 감지 → 자동 요약
# 설명: news/ 폴더를 30초마다 확인하여 새로운 .md 파일을 발견하면
#       Claude를 호출해 요약본을 summaries/ 폴더에 저장합니다.
# 사용법: bash scripts/watch_summarize.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

NEWS_DIR="$BASE_DIR/news"
SUMMARY_DIR="$BASE_DIR/summaries"
LOG_FILE="$BASE_DIR/logs/watch_summarize.log"

CHECK_INTERVAL=30  # 30초마다 확인

mkdir -p "$NEWS_DIR" "$SUMMARY_DIR" "$BASE_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [summarize] $1" | tee -a "$LOG_FILE"
}

# 요약이 이미 존재하는지 확인
is_summarized() {
  local basename="$1"
  local summary_file="$SUMMARY_DIR/summary_${basename}"
  [ -f "$summary_file" ]
}

log "=== 문서 요약기를 시작합니다 ==="
log "감시 대상: $NEWS_DIR (*.md)"
log "요약 저장: $SUMMARY_DIR"
log "확인 간격: ${CHECK_INTERVAL}초"

TOTAL_SUMMARIZED=0

while true; do
  # news/ 폴더의 모든 .md 파일 확인
  NEW_FILES_FOUND=0

  for md_file in "$NEWS_DIR"/*.md; do
    # glob 매칭 실패 시 (파일 없음) 건너뛰기
    [ -f "$md_file" ] || continue

    BASENAME=$(basename "$md_file")

    # 이미 요약된 파일은 건너뛰기
    if is_summarized "$BASENAME"; then
      continue
    fi

    NEW_FILES_FOUND=$((NEW_FILES_FOUND + 1))
    TOTAL_SUMMARIZED=$((TOTAL_SUMMARIZED + 1))
    SUMMARY_FILE="$SUMMARY_DIR/summary_${BASENAME}"

    log "새 문서 발견: $BASENAME — 요약을 시작합니다... (누적 #${TOTAL_SUMMARIZED})"

    # Claude에게 문서 요약 요청
    claude -p "${md_file} 파일을 읽고 다음 형식으로 요약해줘:

---
# 요약: ${BASENAME}
> 원본: ${md_file}
> 요약 시각: $(date '+%Y-%m-%d %H:%M:%S')

## 핵심 요약 (3~5줄)
- 포인트 1
- 포인트 2
- ...

## 키워드
- 관련 키워드 나열
---

결과를 ${SUMMARY_FILE} 파일에 저장해줘. 파일 내용만 저장하고 다른 설명은 불필요해." \
      2>>"$LOG_FILE"

    # 결과 확인
    if [ -f "$SUMMARY_FILE" ]; then
      FILE_SIZE=$(wc -c < "$SUMMARY_FILE")
      log "요약 완료: summary_${BASENAME} (${FILE_SIZE} bytes)"
    else
      log "WARNING: 요약 파일이 생성되지 않았습니다. stdout 리다이렉트로 재시도..."

      # 폴백: 파일을 읽어서 stdin으로 전달 + stdout 리다이렉트
      claude -p "다음 마크다운 문서를 3~5줄로 핵심 요약해줘. 키워드도 추출해줘.
마크다운 형식으로 출력해. 원본 파일명: ${BASENAME}

--- 원본 내용 시작 ---
$(cat "$md_file")
--- 원본 내용 끝 ---" > "$SUMMARY_FILE" 2>>"$LOG_FILE"

      if [ -f "$SUMMARY_FILE" ] && [ -s "$SUMMARY_FILE" ]; then
        FILE_SIZE=$(wc -c < "$SUMMARY_FILE")
        log "대체 방법으로 요약 완료: summary_${BASENAME} (${FILE_SIZE} bytes)"
      else
        rm -f "$SUMMARY_FILE"
        log "ERROR: 요약 실패 — $BASENAME"
      fi
    fi
  done

  if [ "$NEW_FILES_FOUND" -gt 0 ]; then
    log "이번 주기: ${NEW_FILES_FOUND}개 문서 처리 완료"
  else
    MD_COUNT=$(find "$NEWS_DIR" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l)
    log "대기 중... (감시 파일: ${MD_COUNT}개, 요약 완료: ${TOTAL_SUMMARIZED}개) 다음 확인: ${CHECK_INTERVAL}초 후"
  fi

  sleep "$CHECK_INTERVAL"
done
