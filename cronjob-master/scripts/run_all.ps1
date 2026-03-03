# =============================================================================
# run_all.ps1 - 전체 AI 자동화 스크립트 동시 실행 런처 (PowerShell)
# 설명: watch.ps1, fetch_news.ps1, watch_summarize.ps1을 각각 별도 창으로 실행
# 사용법: powershell -ExecutionPolicy Bypass -File scripts\run_all.ps1
# 중지: 이 창을 닫으면 모든 하위 프로세스 자동 종료
# =============================================================================

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir
$LogFile = Join-Path $BaseDir "logs\run_all.log"

# 디렉토리 생성
$dirs = @("input", "output", "archive", "news", "summaries", "logs")
foreach ($dir in $dirs) {
    $path = Join-Path $BaseDir $dir
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}

function Write-Log {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [launcher] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry -Encoding UTF8
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AI 자동화 시스템 (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "=== AI 자동화 시스템을 시작합니다 ==="

# 각 스크립트를 별도 PowerShell 프로세스로 실행
$processes = @()

# 1. 기본 폴더 감시
$p1 = Start-Process powershell -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", "& { `$host.UI.RawUI.WindowTitle = '[AI] 폴더 감시기'; & '$ScriptDir\watch.ps1' }"
) -PassThru
$processes += $p1
Write-Log "[시작] 폴더 감시기     (PID: $($p1.Id)) - input\ 폴더에서 new_task.txt 감시"

# 2. 뉴스 수집기
$p2 = Start-Process powershell -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", "& { `$host.UI.RawUI.WindowTitle = '[AI] 뉴스 수집기'; & '$ScriptDir\fetch_news.ps1' }"
) -PassThru
$processes += $p2
Write-Log "[시작] 뉴스 수집기     (PID: $($p2.Id)) - 10분마다 최신 뉴스 수집"

# 3. 문서 요약기
$p3 = Start-Process powershell -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", "& { `$host.UI.RawUI.WindowTitle = '[AI] 문서 요약기'; & '$ScriptDir\watch_summarize.ps1' }"
) -PassThru
$processes += $p3
Write-Log "[시작] 문서 요약기     (PID: $($p3.Id)) - 새 .md 파일 감지 시 자동 요약"

Write-Host ""
Write-Host "--- 실행 중인 스크립트 ---" -ForegroundColor Yellow
Write-Host "  [1] 폴더 감시기      PID: $($p1.Id)  (input\ -> output\)"
Write-Host "  [2] 뉴스 수집기      PID: $($p2.Id)  (web -> news\*.md, 10분 간격)"
Write-Host "  [3] 문서 요약기      PID: $($p3.Id)  (news\*.md -> summaries\)"
Write-Host ""
Write-Host "--- 디렉토리 구조 ---" -ForegroundColor Yellow
Write-Host "  input\      : 작업 파일 입력"
Write-Host "  output\     : 분석 결과 저장"
Write-Host "  archive\    : 처리 완료 파일 보관"
Write-Host "  news\       : 수집된 뉴스 문서 (.md)"
Write-Host "  summaries\  : 뉴스 요약본"
Write-Host "  logs\       : 실행 로그"
Write-Host ""
Write-Host "중지하려면 Ctrl+C 를 누르세요." -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Ctrl+C 종료 시 모든 하위 프로세스 정리
try {
    while ($true) {
        # 프로세스 상태 확인
        $names = @("폴더 감시기", "뉴스 수집기", "문서 요약기")
        for ($i = 0; $i -lt $processes.Count; $i++) {
            if ($processes[$i].HasExited) {
                Write-Log "WARNING: $($names[$i]) (PID: $($processes[$i].Id))가 예기치 않게 종료되었습니다."
            }
        }
        Start-Sleep -Seconds 60
    }
}
finally {
    Write-Log "종료 신호를 받았습니다. 모든 스크립트를 종료합니다..."
    foreach ($proc in $processes) {
        if (-not $proc.HasExited) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            Write-Log "프로세스 종료: PID $($proc.Id)"
        }
    }
    Write-Log "=== AI 자동화 시스템이 종료되었습니다 ==="
    Write-Host ""
    Write-Host "모든 스크립트가 종료되었습니다." -ForegroundColor Green
}
