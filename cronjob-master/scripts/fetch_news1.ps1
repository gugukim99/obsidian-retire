# =============================================================================
# fetch_news.ps1 - 웹 뉴스 수집 -> .md 파일 생성 (PowerShell)
# 설명: Claude를 호출하여 최신 뉴스를 검색하고,
#       결과를 news\ 폴더에 마크다운 파일로 저장합니다.
# 사용법: powershell -ExecutionPolicy Bypass -File scripts\fetch_news.ps1
# =============================================================================

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

$NewsDir = Join-Path $BaseDir "news"
$LogFile = Join-Path $BaseDir "logs\fetch_news.log"

# 디렉토리 생성
foreach ($dir in @($NewsDir, (Join-Path $BaseDir "logs"))) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Write-Log {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [fetch_news] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry -Encoding UTF8
}

Write-Log "=== 뉴스 수집을 시작합니다 ==="

$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$DateDisplay = Get-Date -Format 'yyyy년 MM월 dd일 HH:mm'
$Filename = "news_${Timestamp}.md"
$OutputPath = Join-Path $NewsDir $Filename

Write-Log "뉴스 수집 중..."

$prompt = @"
지금 시각은 ${DateDisplay}입니다.
웹에서 오늘의 최신 주요 뉴스 5건을 검색해서 마크다운 문서로 작성해줘.

다음 형식을 정확히 따라줘:

# 오늘의 주요 뉴스 (${DateDisplay} 수집)

## 1. [뉴스 제목]
- **요약**: 2~3줄 핵심 내용
- **출처**: 언론사명 / URL

## 2. [뉴스 제목]
- **요약**: 2~3줄 핵심 내용
- **출처**: 언론사명 / URL

(5건까지)

---
> 이 문서는 AI가 자동 수집한 뉴스입니다.

결과를 ${OutputPath} 파일에 저장해줘. 파일 내용만 저장하고 다른 설명은 불필요해.
"@

try {
    claude -p $prompt --allowedTools "web_search" 2>> $LogFile

    if (Test-Path $OutputPath) {
        $FileSize = (Get-Item $OutputPath).Length
        Write-Log "뉴스 저장 완료: $Filename ($FileSize bytes)"
    }
    else {
        Write-Log "WARNING: Claude가 직접 저장하지 못했습니다. stdout 리다이렉트로 재시도..."

        $fallbackPrompt = @"
지금 시각은 ${DateDisplay}입니다.
웹에서 오늘의 최신 주요 뉴스 5건을 검색해서 마크다운으로 출력해줘.
형식: # 제목, ## 각 뉴스 제목, 요약 2-3줄, 출처.
마크다운 내용만 출력하고 다른 설명은 하지 마.
"@

        $result = claude -p $fallbackPrompt 2>> $LogFile
        if ($result) {
            $result | Out-File -FilePath $OutputPath -Encoding UTF8
            $FileSize = (Get-Item $OutputPath).Length
            Write-Log "대체 방법으로 저장 완료: $Filename ($FileSize bytes)"
        }
        else {
            Write-Log "ERROR: 뉴스 수집에 실패했습니다."
        }
    }
}
catch {
    Write-Log "ERROR: $_"
}

Write-Log "=== 뉴스 수집 완료 ==="