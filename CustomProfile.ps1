function Load-Module([string] $name) {
    $path = Join-Path -Path $PSScriptRoot $name
    if (-not [System.IO.File]::Exists($path)) {
        if (-not (Get-Module -ListAvailable -Name $name)) {
            # $name is not installed
            Write-Host "file is not installed"
            Install-Module $name -Force
        }
        Import-Module $name
    } else {
        Import-Module $path
    }
    Write-Color -T "Loading: ", $name, " ✅" -C White, DarkGreen
}

Load-Module PSWriteColor
Load-Module ./utils.psm1
Load-Module ./sudo.psm1
Load-Module DockerCompletion
Load-Module DockerComposeCompletion
Load-Module posh-git

function prompt {
    if ($(git status 2>&1 | Out-Null; $LASTEXITCODE)) {
        Write-Host "📂[" -NoNewline -ForegroundColor DarkBlue
        Write-Host $(Get-ShortPath $pwd) -NoNewline
        Write-Host "]" -NoNewline -ForegroundColor DarkBlue
    } else {
        & $GitPromptScriptBlock
    }
    return " "
}

$GitPromptSettings.DefaultPromptPath = '$(Get-CustomGitPrompt)'
$GitPromptSettings.TruncatedBranchSuffix = '…'