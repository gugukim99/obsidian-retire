#!/bin/bash
# =============================================================================
# run_all.sh - 전체 AI 자동화 스크립트 동시 실행 런처
# 설명: watch.sh, fetch_news.sh, watch_summarize.sh를 백그라운드로 동시 실행
# 사용법: bash scripts/run_all.sh
# 중지: Ctrl+C (모든 하위 프로세스 자동 정리)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$BASE_DIR/logs/run_all.log"

mkdir -p "$BASE_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [launcher] $1" | tee -a "$LOG_FILE"
}

echo ""
echo "=========================================="
echo "   AI 자동화 시스템"
echo "=========================================="
echo ""

log "=== AI 자동화 시스템을 시작합니다 ==="

# PID 저장용 배열
PIDS=()

# 1. 기본 폴더 감시 (input/new_task.txt → 분석 → output/)
bash "$SCRIPT_DIR/watch.sh" &
PIDS+=($!)
log "[시작] 폴더 감시기     (PID: ${PIDS[-1]}) — input/ 폴더에서 new_task.txt 감시"

# 2. 뉴스 수집기 (10분마다 웹 뉴스 검색 → news/*.md)
bash "$SCRIPT_DIR/fetch_news.sh" &
PIDS+=($!)
log "[시작] 뉴스 수집기     (PID: ${PIDS[-1]}) — 10분마다 최신 뉴스 수집"

# 3. 문서 요약기 (news/*.md 감시 → summaries/summary_*.md)
bash "$SCRIPT_DIR/watch_summarize.sh" &
PIDS+=($!)
log "[시작] 문서 요약기     (PID: ${PIDS[-1]}) — 새 .md 파일 감지 시 자동 요약"

echo ""
echo "--- 실행 중인 스크립트 ---"
echo "  [1] 폴더 감시기      PID: ${PIDS[0]}  (input/ → output/)"
echo "  [2] 뉴스 수집기      PID: ${PIDS[1]}  (web → news/*.md, 10분 간격)"
echo "  [3] 문서 요약기      PID: ${PIDS[2]}  (news/*.md → summaries/)"
echo ""
echo "--- 디렉토리 구조 ---"
echo "  input/      : 작업 파일 입력"
echo "  output/     : 분석 결과 저장"
echo "  archive/    : 처리 완료 파일 보관"
echo "  news/       : 수집된 뉴스 문서 (.md)"
echo "  summaries/  : 뉴스 요약본"
echo "  logs/       : 실행 로그"
echo ""
echo "중지하려면 Ctrl+C 를 누르세요."
echo "=========================================="
echo ""

# 종료 시 모든 하위 프로세스 정리
cleanup() {
  echo ""
  log "종료 신호를 받았습니다. 모든 스크립트를 종료합니다..."
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
      log "프로세스 종료: PID $pid"
    fi
  done
  log "=== AI 자동화 시스템이 종료되었습니다 ==="
  echo ""
  exit 0
}

trap cleanup SIGINT SIGTERM

# 하위 프로세스가 실행 중인 동안 대기
# 하나라도 종료되면 상태 보고
while true; do
  for i in "${!PIDS[@]}"; do
    pid="${PIDS[$i]}"
    if ! kill -0 "$pid" 2>/dev/null; then
      NAMES=("폴더 감시기" "뉴스 수집기" "문서 요약기")
      log "WARNING: ${NAMES[$i]} (PID: $pid)가 예기치 않게 종료되었습니다."
    fi
  done
  sleep 60
done
