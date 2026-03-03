# =============================================================================
# watch.ps1 - 기본 폴더 감시 스크립트 (PowerShell)
# 설명: input\ 폴더에 new_task.txt 파일이 생기면 Claude가 분석 후 output\에 저장
# 사용법: powershell -ExecutionPolicy Bypass -File scripts\watch.ps1
# =============================================================================

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

$InputDir = Join-Path $BaseDir "input"
$OutputDir = Join-Path $BaseDir "output"
$ArchiveDir = Join-Path $BaseDir "archive"
$LogFile = Join-Path $BaseDir "logs\watch.log"

# 디렉토리 생성
foreach ($dir in @($InputDir, $OutputDir, $ArchiveDir, (Join-Path $BaseDir "logs"))) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Write-Log {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [watch] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry -Encoding UTF8
}

Write-Log "폴더 감시를 시작합니다. 감시 대상: $InputDir"
Write-Log "5분 간격으로 new_task.txt 파일을 확인합니다."

while ($true) {
    $taskFile = Join-Path $InputDir "new_task.txt"

    if (Test-Path $taskFile) {
        Write-Log "새로운 작업을 발견했습니다. 분석을 시작합니다..."

        try {
            claude -p "$taskFile 파일을 분석해서 요약본을 $OutputDir 폴더에 저장해줘"
            $archiveName = "task_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            Move-Item -Path $taskFile -Destination (Join-Path $ArchiveDir $archiveName) -Force
            Write-Log "작업이 완료되었습니다. 원본 파일을 archive\로 이동했습니다."
        }
        catch {
            Write-Log "ERROR: Claude 실행 중 오류가 발생했습니다. $_"
        }
    }

    Start-Sleep -Seconds 300
}
