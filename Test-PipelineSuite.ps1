<#
.SYNOPSIS
    OpenMontage Pipeline Test Suite Runner
.DESCRIPTION
    Executes Test C (Default), Test B (Custom Text), and Test A (Ollama)
    in process-isolated sandboxes and renders a unified success/failure dashboard.
#>

[CmdletBinding()]
param(
    [string]$OllamaTopic = "Shader Pipelines and Vertex Buffers",
    [string]$CustomText = "Testing the local audio pipeline with customized input text."
)

$ErrorActionPreference = "Continue"

# 1. Activate Environment Context
if (-not $env:VIRTUAL_ENV -and (Test-Path ".\.venv\Scripts\Activate.ps1")) {
    . .\.venv\Scripts\Activate.ps1
}

# 2. Tracking Matrix
$TestSuite = [ordered]@{
    "Test C: Core Smoke Test"   = @{ Args = "-OutputFile test_c_default.mp4"; Target = "test_c_default.mp4"; Status = "PENDING"; Duration = 0 }
    "Test B: Custom Text Input" = @{ Args = "-ScriptText `"$CustomText`" -OutputFile test_b_custom.mp4"; Target = "test_b_custom.mp4"; Status = "PENDING"; Duration = 0 }
    "Test A: Ollama Generation" = @{ Args = "-Topic `"$OllamaTopic`" -OutputFile test_a_ollama.mp4"; Target = "test_a_ollama.mp4"; Status = "PENDING"; Duration = 0 }
}

Write-Host "`n========================================================" -ForegroundColor DarkCyan
Write-Host " OPENMONTAGE LOCAL PIPELINE TEST SUITE" -ForegroundColor White -BackgroundColor DarkCyan
Write-Host "========================================================`n" -ForegroundColor DarkCyan

# 3. Execution Loop
foreach ($TestName in $TestSuite.Keys) {
    $TestConfig = $TestSuite[$TestName]
    
    Write-Host ">>> RUNNING: $TestName" -ForegroundColor Yellow
    Write-Host "    Target Output: $($TestConfig.Target)" -ForegroundColor DarkGray

    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Execute run_local_pipeline.ps1 in an isolated PowerShell child process
    $Process = Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File .\run_local_pipeline.ps1 $($TestConfig.Args)" -NoNewWindow -Wait -PassThru

    $Stopwatch.Stop()
    $Elapsed = [math]::Round($Stopwatch.Elapsed.TotalSeconds, 2)
    $TestConfig.Duration = $Elapsed

    # Verify Exit Code & File Creation
    if ($Process.ExitCode -eq 0 -and (Test-Path $TestConfig.Target)) {
        $TestConfig.Status = "PASSED"
        Write-Host "--> LIVE STATUS: [PASSED] ($($Elapsed)s)`n" -ForegroundColor Green
    } else {
        $TestConfig.Status = "FAILED"
        Write-Host "--> LIVE STATUS: [FAILED] ($($Elapsed)s)`n" -ForegroundColor Red
    }
}

# 4. Final Results Matrix Dashboard
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " TEST SUITE SUMMARY DASHBOARD" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "========================================================" -ForegroundColor Cyan

$PassedCount = 0

foreach ($TestName in $TestSuite.Keys) {
    $Result = $TestSuite[$TestName]
    
    if ($Result.Status -eq "PASSED") {
        $StatusBadge = "[ PASSED ]"
        $BadgeColor  = "Green"
        $PassedCount++
    } else {
        $StatusBadge = "[ FAILED ]"
        $BadgeColor  = "Red"
    }

    Write-Host "$StatusBadge " -NoNewline -ForegroundColor $BadgeColor
    Write-Host "$($TestName.PadRight(28))" -NoNewline -ForegroundColor White
    Write-Host " Time: $($Result.Duration.ToString('0.00').PadLeft(6))s | File: $($Result.Target)" -ForegroundColor Gray
}

Write-Host "`n--------------------------------------------------------" -ForegroundColor DarkCyan
$TotalTests = $TestSuite.Count
if ($PassedCount -eq $TotalTests) {
    Write-Host " OVERALL RESULT: ALL TESTS PASSED ($PassedCount/$TotalTests)" -ForegroundColor Green
} else {
    Write-Host " OVERALL RESULT: $PassedCount/$TotalTests TESTS PASSED" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------------`n" -ForegroundColor DarkCyan
