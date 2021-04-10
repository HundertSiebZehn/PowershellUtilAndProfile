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
Load-Module posh-git
Load-Module posh-with
Load-Module ZLocation # needs to be loaded after posh-git, because of the prompt shenanigans
Load-Module ./utils.psm1
Load-Module ./sudo.psm1

function prompt {
    try {Update-ZLocation $(Get-PromptPath)} catch {} # a workaround for ZLocation in combination with posh-git
    if ($(git status 2>&1 | Out-Null; $LASTEXITCODE)) {
        return "📂`e[34m[`e[0m$(Get-ShortPath $(Get-PromptPath))`e[34m]`e[0m "
    }
    return & $GitPromptScriptBlock
}

function global:Write-WithPrompt()
{
    param(
        [string]
        $command
    )

    Write-Host -NoNewline $(prompt)
    Write-Color -NoNewLine -T "with: ", $command, "> " -C DarkBlue, Blue, White
}

$GitPromptSettings.DefaultPromptPath = '$(Get-CustomGitPrompt)'
$GitPromptSettings.TruncatedBranchSuffix = '…'
$GitPromptSettings.FileConflictedText = '🔥'
$GitPromptSettings.LocalWorkingStatusSymbol = '⚡'