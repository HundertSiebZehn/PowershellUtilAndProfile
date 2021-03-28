function Load-Module([string] $name) {
    $path = Join-Path -Path $PSScriptRoot $name
    if (-not [System.IO.File]::Exists($path)) {
        if (-not (Get-Module -ListAvailable -Name $name)) {
            # $name is not installed
            Install-Module $name -Force
        }
        Import-Module $name
    } else {
        Import-Module $path
    }
    Write-Color -T "Loading: ", $name, " ✅" -C White, DarkGreen
}

Load-Module PSWriteColor
Load-Module DockerCompletion
Load-Module DockerComposeCompletion
Load-Module ZLocation
Load-Module posh-with
Load-Module posh-git
Load-Module ./utils.psm1
Load-Module ./sudo.psm1

function Write-Prompt {
    if ($(git status 2>&1 | Out-Null; $LASTEXITCODE)) {
        Write-Host "📂[" -NoNewline -ForegroundColor DarkBlue
        Write-Host $(Get-ShortPath $(Get-PromptPath)) -NoNewline
        Write-Host "]" -NoNewline -ForegroundColor DarkBlue
    } else {
        & $GitPromptScriptBlock
    }
}

function prompt {
    Write-Prompt
    return " "
}
function global:Write-WithPrompt()
{
    param(
        [string]
        $command
    )

    Write-Host -NoNewline $(Write-Prompt)
    Write-Color -NoNewLine -T "with: ", $command, "> " -C DarkBlue, Blue, White
}

$GitPromptSettings.DefaultPromptPath = '$(Get-CustomGitPrompt)'
$GitPromptSettings.TruncatedBranchSuffix = '…'