# =============================================================================
# watch_summarize.ps1 - 새 .md 파일 감지 -> 자동 요약 (PowerShell)
# 설명: news\ 폴더를 30초마다 확인하여 새로운 .md 파일을 발견하면
#       Claude를 호출해 요약본을 summaries\ 폴더에 저장합니다.
# 사용법: powershell -ExecutionPolicy Bypass -File scripts\watch_summarize.ps1
# =============================================================================

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

$NewsDir = Join-Path $BaseDir "news"
$SummaryDir = Join-Path $BaseDir "summaries"
$LogFile = Join-Path $BaseDir "logs\watch_summarize.log"

$CheckInterval = 30  # 30초마다 확인

# 디렉토리 생성
foreach ($dir in @($NewsDir, $SummaryDir, (Join-Path $BaseDir "logs"))) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Write-Log {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [summarize] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry -Encoding UTF8
}

Write-Log "=== 문서 요약기를 시작합니다 ==="
Write-Log "감시 대상: $NewsDir (*.md)"
Write-Log "요약 저장: $SummaryDir"
Write-Log "확인 간격: ${CheckInterval}초"

$TotalSummarized = 0

while ($true) {
    $NewFilesFound = 0

    # news\ 폴더의 모든 .md 파일 확인
    $mdFiles = Get-ChildItem -Path $NewsDir -Filter "*.md" -File -ErrorAction SilentlyContinue

    foreach ($mdFile in $mdFiles) {
        $SummaryFile = Join-Path $SummaryDir "summary_$($mdFile.Name)"

        # 이미 요약된 파일은 건너뛰기
        if (Test-Path $SummaryFile) {
            continue
        }

        $NewFilesFound++
        $TotalSummarized++

        Write-Log "새 문서 발견: $($mdFile.Name) - 요약을 시작합니다... (누적 #${TotalSummarized})"

        $prompt = @"
$($mdFile.FullName) 파일을 읽고 다음 형식으로 요약해줘:

# 요약: $($mdFile.Name)
> 원본: $($mdFile.FullName)
> 요약 시각: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 핵심 요약 (3~5줄)
- 포인트 1
- 포인트 2
- ...

## 키워드
- 관련 키워드 나열

결과를 ${SummaryFile} 파일에 저장해줘. 파일 내용만 저장하고 다른 설명은 불필요해.
"@

        try {
            claude -p $prompt 2>> $LogFile

            if (Test-Path $SummaryFile) {
                $FileSize = (Get-Item $SummaryFile).Length
                Write-Log "요약 완료: summary_$($mdFile.Name) ($FileSize bytes)"
            }
            else {
                Write-Log "WARNING: Claude가 직접 저장하지 못했습니다. stdout 리다이렉트로 재시도..."

                # 폴백: 원본 파일 내용을 프롬프트에 포함 + stdout 리다이렉트
                $content = Get-Content -Path $mdFile.FullName -Raw -Encoding UTF8
                $fallbackPrompt = @"
다음 마크다운 문서를 3~5줄로 핵심 요약해줘. 키워드도 추출해줘.
마크다운 형식으로 출력해. 원본 파일명: $($mdFile.Name)

--- 원본 내용 시작 ---
$content
--- 원본 내용 끝 ---
"@

                $result = claude -p $fallbackPrompt 2>> $LogFile
                if ($result) {
                    $result | Out-File -FilePath $SummaryFile -Encoding UTF8
                    $FileSize = (Get-Item $SummaryFile).Length
                    Write-Log "대체 방법으로 요약 완료: summary_$($mdFile.Name) ($FileSize bytes)"
                }
                else {
                    Write-Log "ERROR: 요약 실패 - $($mdFile.Name)"
                }
            }
        }
        catch {
            Write-Log "ERROR: $_ - $($mdFile.Name)"
        }
    }

    if ($NewFilesFound -gt 0) {
        Write-Log "이번 주기: ${NewFilesFound}개 문서 처리 완료"
    }
    else {
        $mdCount = ($mdFiles | Measure-Object).Count
        Write-Log "대기 중... (감시 파일: ${mdCount}개, 요약 완료: ${TotalSummarized}개) 다음 확인: ${CheckInterval}초 후"
    }

    Start-Sleep -Seconds $CheckInterval
}
