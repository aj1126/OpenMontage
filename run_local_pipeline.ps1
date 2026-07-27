<#
.SYNOPSIS
    OpenMontage 100% Offline Local Pipeline
.DESCRIPTION
    Runs Ollama (Scripting), Piper TTS (Audio), faster-whisper (Subtitles), 
    and Remotion (NVENC GPU Video Render) with clean console UI formatting.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Topic,

    [Parameter(Mandatory=$false)]
    [string]$ScriptText,

    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "out.mp4",

    [Parameter(Mandatory=$false)]
    [string]$Composition = "Explainer",

    [Parameter(Mandatory=$false)]
    [string]$OllamaModel = "qwen2.5:7b-instruct-q4_k_m",

    [Parameter(Mandatory=$false)]
    [string]$VoiceModel = "en_US-lessac-medium"
)

$ErrorActionPreference = "Stop"

function Write-Header ($text) {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host " $text" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "========================================================`n" -ForegroundColor Cyan
}

function Write-Step ($stepNum, $stepName) {
    Write-Host "[$stepNum/4] $stepName..." -ForegroundColor Yellow
}

function Write-StatusSuccess ($msg) {
    Write-Host "  [+] SUCCESS: $msg`n" -ForegroundColor Green
}

function Write-StatusFail ($msg) {
    Write-Host "  [-] ERROR: $msg`n" -ForegroundColor Red
    exit 1
}

Write-Header "OpenMontage Local Video Pipeline"

# 0. Environment Activation
if (-not $env:VIRTUAL_ENV -and (Test-Path ".\.venv\Scripts\Activate.ps1")) {
    . .\.venv\Scripts\Activate.ps1
}

# Step 1: Scripting & Planning (Ollama)
Write-Step "1" "Planning & Script Generation"
if ($ScriptText) {
    $NarrationText = $ScriptText
    Write-Host "  Using direct text input." -ForegroundColor Gray
} elseif ($Topic) {
    Write-Host "  Prompting Ollama ($OllamaModel) at http://localhost:11434..." -ForegroundColor Gray
    try {
        $body = @{
            model = $OllamaModel
            prompt = "Write a concise 3-sentence narration script about: $Topic. Return ONLY the raw script text, with no quotes or conversational intro."
            stream = $false
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
        $NarrationText = $response.response.Trim()
    } catch {
        Write-StatusFail "Could not communicate with Ollama. Verify Ollama is running (`ollama serve`)."
    }
} else {
    $NarrationText = "Welcome to OpenMontage. This is an automated local test narration script generated completely offline."
    Write-Host "  No topic provided. Using default offline test phrase." -ForegroundColor DarkGray
}

Write-Host "`n  --- Active Script ---" -ForegroundColor DarkCyan
Write-Host "  `"$NarrationText`"" -ForegroundColor White
Write-Host "  ---------------------`n" -ForegroundColor DarkCyan
Write-StatusSuccess "Script ready ($($NarrationText.Length) chars)"

# Step 2: Speech Synthesis (Piper TTS)
Write-Step "2" "Synthesizing Speech (Piper TTS)"
$WavPath = "narration.wav"

$pyTTSHelper = @'
import json, sys
from tools.audio.piper_tts import PiperTTS

res = PiperTTS().execute({
    'text': sys.argv[1],
    'output_path': sys.argv[2],
    'model': sys.argv[3]
})

print(json.dumps({
    'success': res.success,
    'duration': res.duration_seconds,
    'output': res.data.get('output', ''),
    'error': res.error
}))
'@

try {
    $rawJson = python -c $pyTTSHelper $NarrationText $WavPath $VoiceModel | ConvertFrom-Json
    if ($rawJson.success) {
        Write-StatusSuccess "Audio synthesized in $($rawJson.duration)s -> $($rawJson.output)"
    } else {
        Write-StatusFail "Piper TTS execution failed: $($rawJson.error)"
    }
} catch {
    Write-StatusFail "Failed to execute TTS python module: $_"
}

# Step 3: Subtitle Generation (faster-whisper)
Write-Step "3" "Extracting Subtitles (faster-whisper)"
$pyWhisperHelper = @'
import sys
from faster_whisper import WhisperModel

audio_path = sys.argv[1]
srt_path = "narration.srt"

try:
    model = WhisperModel("base.en", device="cuda", compute_type="float16")
except Exception:
    model = WhisperModel("base.en", device="cpu", compute_type="int8")

segments, _ = model.transcribe(audio_path)

def fmt_time(seconds):
    hrs = int(seconds // 3600)
    mins = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    msecs = int((seconds % 1) * 1000)
    return f"{hrs:02d}:{mins:02d}:{secs:02d},{msecs:03d}"

with open(srt_path, "w", encoding="utf-8") as f:
    for idx, seg in enumerate(segments, start=1):
        f.write(f"{idx}\n{fmt_time(seg.start)} --> {fmt_time(seg.end)}\n{seg.text.strip()}\n\n")
'@

try {
    python -c $pyWhisperHelper $WavPath
    Write-StatusSuccess "Subtitles compiled -> narration.srt"
} catch {
    Write-StatusFail "Subtitle extraction failed: $_"
}

# Step 4: Remotion Video Render
Write-Step "4" "Rendering Video Composition (Remotion + NVENC)"
try {
    Push-Location remotion-composer
    npx remotion render $Composition "..\$OutputFile" --concurrency=4 --gl=angle
    Pop-Location
    Write-StatusSuccess "Video render complete -> $OutputFile"
} catch {
    Pop-Location
    Write-StatusFail "Remotion rendering process failed: $_"
}

Write-Header "Pipeline Completed Successfully!"