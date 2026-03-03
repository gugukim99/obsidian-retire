#!/bin/bash
# =============================================================================
# watch.sh - 기본 폴더 감시 스크립트
# 설명: input/ 폴더에 new_task.txt 파일이 생기면 Claude가 분석 후 output/에 저장
# 사용법: bash scripts/watch.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

INPUT_DIR="$BASE_DIR/input"
OUTPUT_DIR="$BASE_DIR/output"
ARCHIVE_DIR="$BASE_DIR/archive"
LOG_FILE="$BASE_DIR/logs/watch.log"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR" "$ARCHIVE_DIR" "$BASE_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [watch] $1" | tee -a "$LOG_FILE"
}

log "폴더 감시를 시작합니다. 감시 대상: $INPUT_DIR"
log "5분 간격으로 new_task.txt 파일을 확인합니다."

while true; do
  if [ -f "$INPUT_DIR/new_task.txt" ]; then
    log "새로운 작업을 발견했습니다. 분석을 시작합니다..."

    claude -p "$INPUT_DIR/new_task.txt 파일을 분석해서 요약본을 $OUTPUT_DIR 폴더에 저장해줘" \
      2>>"$LOG_FILE"

    if [ $? -eq 0 ]; then
      mv "$INPUT_DIR/new_task.txt" "$ARCHIVE_DIR/task_$(date '+%Y%m%d_%H%M%S').txt"
      log "작업이 완료되었습니다. 원본 파일을 archive/로 이동했습니다."
    else
      log "ERROR: Claude 실행 중 오류가 발생했습니다."
    fi
  fi

  sleep 300
done
