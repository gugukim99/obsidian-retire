#!/bin/bash
# =============================================================================
# fetch_news.sh - 10분마다 웹 뉴스 수집 → .md 파일 생성
# 설명: 10분 간격으로 Claude를 호출하여 최신 뉴스를 검색하고,
#       결과를 news/ 폴더에 마크다운 파일로 저장합니다.
# 사용법: bash scripts/fetch_news.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

NEWS_DIR="$BASE_DIR/news"
LOG_FILE="$BASE_DIR/logs/fetch_news.log"

INTERVAL=600  # 10분 (초 단위)

mkdir -p "$NEWS_DIR" "$BASE_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [fetch_news] $1" | tee -a "$LOG_FILE"
}

log "=== 뉴스 수집기를 시작합니다 ==="
log "수집 간격: ${INTERVAL}초 (10분)"
log "저장 위치: $NEWS_DIR"

# 수집 카운터
COUNT=0

while true; do
  COUNT=$((COUNT + 1))
  TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
  DATE_DISPLAY=$(date '+%Y년 %m월 %d일 %H:%M')
  FILENAME="news_${TIMESTAMP}.md"
  OUTPUT_PATH="$NEWS_DIR/$FILENAME"

  log "[#${COUNT}] 뉴스 수집을 시작합니다..."

  # Claude에게 최신 뉴스 검색 및 마크다운 작성 요청
  claude -p "지금 시각은 ${DATE_DISPLAY}입니다.
웹에서 오늘의 최신 주요 뉴스 5건을 검색해서 마크다운 문서로 작성해줘.

다음 형식을 정확히 따라줘:

---
# 오늘의 주요 뉴스 (${DATE_DISPLAY} 수집)

## 1. [뉴스 제목]
- **요약**: 2~3줄 핵심 내용
- **출처**: 언론사명 / URL

## 2. [뉴스 제목]
...

---
> 이 문서는 AI가 자동 수집한 뉴스입니다.
---

결과를 ${OUTPUT_PATH} 파일에 저장해줘. 파일 내용만 저장하고 다른 설명은 불필요해." \
    2>>"$LOG_FILE"

  # 결과 확인
  if [ -f "$OUTPUT_PATH" ]; then
    FILE_SIZE=$(wc -c < "$OUTPUT_PATH")
    log "[#${COUNT}] 뉴스 저장 완료: $FILENAME (${FILE_SIZE} bytes)"
  else
    log "[#${COUNT}] WARNING: 파일이 생성되지 않았습니다. Claude가 직접 저장하지 못했을 수 있습니다."
    log "[#${COUNT}] 대체 방법: stdout 리다이렉트로 재시도합니다..."

    # 폴백: stdout을 파일로 리다이렉트
    claude -p "지금 시각은 ${DATE_DISPLAY}입니다.
웹에서 오늘의 최신 주요 뉴스 5건을 검색해서 마크다운으로 출력해줘.
형식: # 제목 → ## 각 뉴스 제목 → 요약 2-3줄 → 출처
마크다운 내용만 출력하고 다른 설명은 하지 마." > "$OUTPUT_PATH" 2>>"$LOG_FILE"

    if [ -f "$OUTPUT_PATH" ] && [ -s "$OUTPUT_PATH" ]; then
      FILE_SIZE=$(wc -c < "$OUTPUT_PATH")
      log "[#${COUNT}] 대체 방법으로 저장 완료: $FILENAME (${FILE_SIZE} bytes)"
    else
      rm -f "$OUTPUT_PATH"
      log "[#${COUNT}] ERROR: 뉴스 수집에 실패했습니다."
    fi
  fi

  log "[#${COUNT}] 다음 수집까지 10분 대기..."
  sleep "$INTERVAL"
done
